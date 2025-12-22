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

/// Pantalla para visualizar una foto en pantalla completa
class BovinoPhotoViewerScreen extends StatefulWidget {
  final String photoUrl;
  final BovineEntity bovine;
  final String farmId;

  const BovinoPhotoViewerScreen({
    super.key,
    required this.photoUrl,
    required this.bovine,
    required this.farmId,
  });

  @override
  State<BovinoPhotoViewerScreen> createState() => _BovinoPhotoViewerScreenState();
}

class _BovinoPhotoViewerScreenState extends State<BovinoPhotoViewerScreen> {
  final PhotoService _photoService = PhotoService();
  final TransformationController _transformationController = TransformationController();

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<BovinoFormCubit>(),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _showEditOptions,
              tooltip: 'Editar foto',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _showDeleteConfirmation,
              tooltip: 'Eliminar foto',
            ),
          ],
        ),
        body: BlocListener<BovinoFormCubit, BovinoFormState>(
          listener: (context, state) {
            if (state is BovinoFormSuccess) {
              Navigator.pop(context, true); // Retornar true para indicar cambio
            } else if (state is BovinoFormError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: Center(
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: 0.5,
              maxScale: 4.0,
              child: _buildPhoto(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoto() {
    // En web, las fotos pueden ser URLs de blob o http
    if (kIsWeb) {
      if (widget.photoUrl.startsWith('blob:') || widget.photoUrl.startsWith('http') || widget.photoUrl.startsWith('data:')) {
        return Image.network(
          widget.photoUrl,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image,
                  size: 100,
                  color: Colors.white54,
                ),
                SizedBox(height: 16),
                Text(
                  'Error al cargar la imagen',
                  style: TextStyle(color: Colors.white54),
                ),
              ],
            );
          },
        );
      }
      // Si no es una URL válida, mostrar error
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            size: 100,
            color: Colors.white54,
          ),
          SizedBox(height: 16),
          Text(
            'Foto no encontrada',
            style: TextStyle(color: Colors.white54),
          ),
        ],
      );
    }
    
    // Para móvil/desktop, usar File
    if (kIsWeb) {
      // En web, mostrar directamente desde URL
      return Image.network(
        widget.photoUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(Icons.error, size: 48, color: Colors.red),
          );
        },
      );
    }
    // Solo en móvil/desktop, crear File usando helper
    final file = _createFile(widget.photoUrl);
    final exists = _fileExistsSync(file);

    if (!exists) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            size: 100,
            color: Colors.white54,
          ),
          SizedBox(height: 16),
          Text(
            'Foto no encontrada',
            style: TextStyle(color: Colors.white54),
          ),
        ],
      );
    }

    return Image.file(
      file,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image,
              size: 100,
              color: Colors.white54,
            ),
            SizedBox(height: 16),
            Text(
              'Error al cargar la imagen',
              style: TextStyle(color: Colors.white54),
            ),
          ],
        );
      },
    );
  }

  void _showEditOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade900,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.white),
              title: const Text('Tomar nueva foto', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _handlePhotoSelection(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.white),
              title: const Text('Seleccionar de galería', style: TextStyle(color: Colors.white)),
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

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text('Eliminar foto', style: TextStyle(color: Colors.white)),
        content: const Text(
          '¿Estás seguro de que deseas eliminar esta foto?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deletePhoto();
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

  Future<void> _handlePhotoSelection(ImageSource source) async {
    dynamic photo;
    if (source == ImageSource.camera) {
      photo = await _photoService.takePhoto();
    } else {
      photo = await _photoService.pickFromGallery();
    }

    if (photo == null) return;

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final compressed = await _photoService.compressImage(photo);
      if (compressed == null) {
        if (!mounted) return;
        Navigator.pop(context);
        _showError('Error al comprimir la imagen');
        return;
      }

      final savedPath = await _photoService.savePhoto(compressed, widget.bovine.id, 'cattle');
      if (savedPath == null) {
        if (!mounted) return;
        Navigator.pop(context);
        _showError('Error al guardar la foto');
        return;
      }

      final cubit = context.read<BovinoFormCubit>();
      await cubit.updatePhoto(widget.bovine, widget.farmId, savedPath);

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showError('Error al procesar la foto: $e');
    }
  }

  Future<void> _deletePhoto() async {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await _photoService.deletePhoto(widget.photoUrl);
      final cubit = context.read<BovinoFormCubit>();
      await cubit.updatePhoto(widget.bovine, widget.farmId, null);

      if (!mounted) return;
      Navigator.pop(context);
      Navigator.pop(context, true); // Cerrar visualizador y retornar true
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showError('Error al eliminar la foto: $e');
    }
  }

  // Helpers para trabajar con archivos sin problemas de import condicional
  dynamic _createFile(String path) {
    if (kIsWeb) return null;
    // En móvil/desktop, crear File usando un método que funcione
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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}

