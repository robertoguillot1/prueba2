import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' if (dart.library.html) 'dart:html' as io;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../features/cattle/domain/entities/bovine_entity.dart';
import '../../../../core/di/dependency_injection.dart' as di;
import '../../../../core/services/photo_service.dart';
import '../../../../core/services/file_helper_stub.dart' if (dart.library.html) '../../../../core/services/file_helper_stub_web.dart' as file_helper;
import '../cubits/form/bovino_form_cubit.dart';
import '../cubits/form/bovino_form_state.dart';
import 'bovino_photo_viewer_screen.dart';

/// Pantalla de galería de fotos para un bovino
class BovinoPhotoGalleryScreen extends StatefulWidget {
  final BovineEntity bovine;
  final String farmId;

  const BovinoPhotoGalleryScreen({
    super.key,
    required this.bovine,
    required this.farmId,
  });

  @override
  State<BovinoPhotoGalleryScreen> createState() => _BovinoPhotoGalleryScreenState();
}

class _BovinoPhotoGalleryScreenState extends State<BovinoPhotoGalleryScreen> {
  final PhotoService _photoService = PhotoService();
  String? _currentPhotoUrl;

  @override
  void initState() {
    super.initState();
    _currentPhotoUrl = widget.bovine.photoUrl;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<BovinoFormCubit>(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Fotos de ${widget.bovine.name ?? widget.bovine.identifier}'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_photo_alternate),
              onPressed: _showPhotoOptions,
              tooltip: 'Agregar foto',
            ),
          ],
        ),
        body: BlocListener<BovinoFormCubit, BovinoFormState>(
          listener: (context, state) {
            if (state is BovinoFormSuccess) {
              setState(() {
                _currentPhotoUrl = state.bovine.photoUrl;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Foto actualizada exitosamente'),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is BovinoFormError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_currentPhotoUrl == null || _currentPhotoUrl!.isEmpty) {
      return _buildEmptyState();
    }

    return _buildGallery();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 100,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 24),
            Text(
              'No hay fotos',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Agrega fotos del bovino para tener un registro visual completo',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade500,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _showPhotoOptions,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Agregar Primera Foto'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGallery() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: 1, // Por ahora solo una foto, pero preparado para múltiples
      itemBuilder: (context, index) {
        return _buildPhotoCard(_currentPhotoUrl!);
      },
    );
  }

  Widget _buildPhotoCard(String photoUrl) {
    // En web, las fotos pueden ser URLs de blob o http
    if (kIsWeb) {
      // En web, verificar si es una URL válida
      if (photoUrl.startsWith('blob:') || photoUrl.startsWith('http') || photoUrl.startsWith('data:')) {
        return _buildWebPhotoCard(photoUrl);
      }
      // Si no es una URL válida, mostrar placeholder
      return _buildWebPhotoCard(photoUrl);
    }
    
    // Para móvil/desktop, usar File
    if (kIsWeb) {
      return _buildWebPhotoCard(photoUrl);
    }
    // Solo en móvil/desktop, crear File usando helper
    final file = _createFile(photoUrl);
    final exists = _fileExistsSync(file);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: exists
                ? Image.file(
                    file,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildErrorPlaceholder();
                    },
                  )
                : _buildErrorPlaceholder(),
          ),
          // Overlay con acciones
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _viewPhoto(photoUrl),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.3),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Botones de acción
          Positioned(
            top: 8,
            right: 8,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Botón de editar
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.blue.withValues(alpha: 0.9),
                  child: IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    color: Colors.white,
                    onPressed: () => _showEditPhotoOptions(photoUrl),
                    padding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(width: 8),
                // Botón de eliminar
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.red.withValues(alpha: 0.9),
                  child: IconButton(
                    icon: const Icon(Icons.delete, size: 18),
                    color: Colors.white,
                    onPressed: () => _showDeleteConfirmation(photoUrl),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
          // Indicador de foto principal
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, size: 14, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'Principal',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            'Foto no encontrada',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _viewPhoto(String photoUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BovinoPhotoViewerScreen(
          photoUrl: photoUrl,
          bovine: widget.bovine,
          farmId: widget.farmId,
        ),
      ),
    ).then((_) {
      // Recargar si se hizo algún cambio
      setState(() {
        _currentPhotoUrl = widget.bovine.photoUrl;
      });
    });
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar foto'),
              onTap: () {
                Navigator.pop(context);
                _handlePhotoSelection(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Seleccionar de galería'),
              onTap: () {
                Navigator.pop(context);
                _handlePhotoSelection(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditPhotoOptions(String currentPhotoUrl) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar nueva foto'),
              onTap: () {
                Navigator.pop(context);
                _handlePhotoSelection(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Seleccionar de galería'),
              onTap: () {
                Navigator.pop(context);
                _handlePhotoSelection(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Eliminar foto', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(currentPhotoUrl);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePhotoSelection(ImageSource source) async {
    dynamic photo;
    if (source == ImageSource.camera) {
      photo = await _photoService.takePhoto();
    } else {
      photo = await _photoService.pickFromGallery();
    }

    if (photo == null) return;

    // Mostrar indicador de carga
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Verificar que el archivo existe antes de procesarlo (solo en móvil/desktop)
      if (!kIsWeb) {
        if (!await _fileExists(photo)) {
          if (!mounted) return;
          Navigator.pop(context);
          _showError('El archivo seleccionado no existe. Por favor, intenta nuevamente.');
          return;
        }
      }

      final compressed = await _photoService.compressImage(photo);
      if (compressed == null) {
        if (!mounted) return;
        Navigator.pop(context);
        _showError('Error al comprimir la imagen. Por favor, intenta con otra foto.');
        return;
      }

      // En web, verificar que el archivo comprimido existe (puede ser el mismo archivo)
      if (!kIsWeb) {
        if (!await _fileExists(compressed)) {
          if (!mounted) return;
          Navigator.pop(context);
          _showError('El archivo comprimido no existe. Por favor, intenta nuevamente.');
          return;
        }
      }

      final savedPath = await _photoService.savePhoto(compressed, widget.bovine.id, 'cattle');
      if (savedPath == null) {
        if (!mounted) return;
        Navigator.pop(context);
        // Mejorar el mensaje de error según la plataforma
        if (kIsWeb) {
          _showError('Error al guardar la foto en web. Esta funcionalidad requiere Firebase Storage para persistencia completa.');
        } else {
          _showError('Error al guardar la foto. Verifica los permisos de almacenamiento de la aplicación.');
        }
        return;
      }

      // Actualizar el bovino con la nueva foto
      final cubit = context.read<BovinoFormCubit>();
      await cubit.updatePhoto(widget.bovine, widget.farmId, savedPath);

      if (!mounted) return;
      Navigator.pop(context); // Cerrar diálogo de carga
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Cerrar diálogo de carga
      _showError('Error al procesar la foto: ${e.toString()}');
    }
  }

  void _showDeleteConfirmation(String photoUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar foto'),
        content: const Text('¿Estás seguro de que deseas eliminar esta foto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deletePhoto(photoUrl);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePhoto(String photoUrl) async {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Eliminar archivo físico
      await _photoService.deletePhoto(photoUrl);

      // Actualizar el bovino sin foto
      final cubit = context.read<BovinoFormCubit>();
      await cubit.updatePhoto(widget.bovine, widget.farmId, null);

      if (!mounted) return;
      Navigator.pop(context); // Cerrar diálogo de carga

      setState(() {
        _currentPhotoUrl = null;
      });
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Cerrar diálogo de carga
      _showError('Error al eliminar la foto: $e');
    }
  }

  Widget _buildWebPhotoCard(String photoUrl) {
    // En web, si es una URL de blob o http, mostrar la imagen directamente
    if (photoUrl.startsWith('blob:') || photoUrl.startsWith('http') || photoUrl.startsWith('data:')) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                photoUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildErrorPlaceholder();
                },
              ),
            ),
            // Overlay y botones (igual que en _buildPhotoCard)
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _viewPhoto(photoUrl),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.3),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.blue.withValues(alpha: 0.9),
                    child: IconButton(
                      icon: const Icon(Icons.edit, size: 18),
                      color: Colors.white,
                      onPressed: () => _showEditPhotoOptions(photoUrl),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.red.withValues(alpha: 0.9),
                    child: IconButton(
                      icon: const Icon(Icons.delete, size: 18),
                      color: Colors.white,
                      onPressed: () => _showDeleteConfirmation(photoUrl),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 14, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Principal',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    // Si no es una URL válida, mostrar placeholder
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade200,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              'Foto guardada',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '(Web)',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helpers para trabajar con archivos sin problemas de import condicional
  dynamic _createFile(String path) {
    if (kIsWeb) return null;
    // En móvil/desktop, usar el helper que funciona correctamente
    return _createNativeFile(path);
  }
  
  dynamic _createNativeFile(String path) {
    // Usar el helper que funciona en ambas plataformas
    return file_helper.FileHelperStub.createFile(path);
  }

  bool _fileExistsSync(dynamic file) {
    if (kIsWeb || file == null) return false;
    try {
      return (file as dynamic).existsSync();
    } catch (e) {
      return false;
    }
  }

  Future<bool> _fileExists(dynamic file) async {
    if (kIsWeb || file == null) return false;
    try {
      return await (file as dynamic).exists();
    } catch (e) {
      return false;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

