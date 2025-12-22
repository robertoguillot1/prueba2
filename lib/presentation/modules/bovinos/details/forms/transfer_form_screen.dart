import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'dart:io' if (dart.library.html) 'dart:html' as io;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import '../../../../../core/di/dependency_injection.dart' as di;
import '../../../../../core/di/dependency_injection.dart' show sl;
import '../../../../../features/cattle/domain/entities/bovine_entity.dart';
import '../../../../../features/cattle/domain/entities/transfer_entity.dart';
import '../../../../../domain/entities/farm/farm.dart';
import '../../../../../domain/repositories/farm_repository.dart';
import '../../../../../presentation/cubits/auth/auth_cubit.dart';
import '../../../../../presentation/cubits/auth/auth_state.dart';
import '../../../../../core/services/photo_service.dart';
import '../../../../../core/services/storage_service.dart';
import '../../../../../core/services/file_helper_stub.dart' if (dart.library.html) '../../../../../core/services/file_helper_stub_web.dart' as file_helper;
import '../cubits/transfer_cubit.dart';
import '../cubits/transfer_state.dart';

/// Pantalla de formulario para registrar o editar una transferencia
class TransferFormScreen extends StatefulWidget {
  final BovineEntity bovine;
  final String farmId;
  final TransferEntity? transfer; // Si se proporciona, modo edición

  const TransferFormScreen({
    super.key,
    required this.bovine,
    required this.farmId,
    this.transfer, // Opcional para modo edición
  });

  @override
  State<TransferFormScreen> createState() => _TransferFormScreenState();
}

class _TransferFormScreenState extends State<TransferFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fromLocationController = TextEditingController();
  final _transporterNameController = TextEditingController();
  final _vehicleInfoController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _transferDate = DateTime.now();
  TransferReason _selectedReason = TransferReason.otro;
  String? _selectedToFarmId;
  
  // Foto de guía de movilización (solo en móvil/desktop, null en web)
  dynamic _mobilizationGuidePhoto;
  Uint8List? _mobilizationGuidePhotoBytes;
  String? _mobilizationGuidePhotoUrl;
  bool _uploadingPhoto = false;
  
  // Servicios
  final PhotoService _photoService = PhotoService();
  final StorageService _storageService = StorageService();
  final ImagePicker _imagePicker = ImagePicker();
  
  // Datos de fincas
  List<Farm> _availableFarms = [];
  Farm? _currentFarm;
  bool _loadingFarms = true;

  bool get isEditMode => widget.transfer != null;

  @override
  void initState() {
    super.initState();
    _loadFarms();
    if (isEditMode && widget.transfer != null) {
      // Modo edición: cargar datos existentes
      final transfer = widget.transfer!;
      _fromLocationController.text = transfer.fromLocation;
      _transporterNameController.text = transfer.transporterName ?? '';
      _vehicleInfoController.text = transfer.vehicleInfo ?? '';
      _notesController.text = transfer.notes ?? '';
      _transferDate = transfer.transferDate;
      _selectedReason = transfer.reason;
      _selectedToFarmId = transfer.toFarmId;
      _mobilizationGuidePhotoUrl = transfer.mobilizationGuidePhotoUrl;
    }
  }

  Future<void> _loadFarms() async {
    setState(() {
      _loadingFarms = true;
    });

    try {
      // Obtener userId del AuthCubit
      final authState = context.read<AuthCubit>().state;
      if (authState is! Authenticated) {
        setState(() {
          _loadingFarms = false;
        });
        return;
      }

      final userId = authState.user.id;
      final farmRepository = sl<FarmRepository>();

      // Obtener todas las fincas del usuario
      final allFarms = await farmRepository.getFarms(userId);
      
      // Obtener la finca actual
      final currentFarm = await farmRepository.getFarmById(userId, widget.farmId);

      // Filtrar fincas disponibles (excluir la actual)
      final availableFarms = allFarms.where((farm) => farm.id != widget.farmId).toList();

      setState(() {
        _currentFarm = currentFarm;
        _availableFarms = availableFarms;
        _loadingFarms = false;
        
        // Pre-llenar origen con el nombre de la finca actual
        if (currentFarm != null) {
          _fromLocationController.text = currentFarm.name;
        }
        
        // En modo edición, si hay un toFarmId pero no está en la lista disponible,
        // agregarlo temporalmente para que se muestre en el dropdown
        if (isEditMode && widget.transfer != null && widget.transfer!.toFarmId != null) {
          final toFarmId = widget.transfer!.toFarmId!;
          if (!availableFarms.any((f) => f.id == toFarmId)) {
            // Buscar la finca destino en todas las fincas
            try {
              final destFarm = allFarms.firstWhere(
                (f) => f.id == toFarmId,
              );
              _availableFarms.add(destFarm);
            } catch (e) {
              // Si no se encuentra, crear una finca temporal con datos mínimos
              // Usar el tipo correcto (Farm es la entidad base)
              final tempFarm = Farm(
                id: toFarmId,
                ownerId: userId,
                name: 'Finca Desconocida',
                primaryColor: Colors.grey.value,
                createdAt: DateTime.now(),
              );
              _availableFarms.add(tempFarm);
            }
          }
        }
      });
    } catch (e) {
      print('❌ [TransferFormScreen] Error al cargar fincas: $e');
      setState(() {
        _loadingFarms = false;
        // Fallback: usar texto genérico
        if (!isEditMode) {
          _fromLocationController.text = 'Finca Actual';
        }
      });
    }
  }

  @override
  void dispose() {
    _fromLocationController.dispose();
    _transporterNameController.dispose();
    _vehicleInfoController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.DependencyInjection.createTransferCubit(),
      child: BlocConsumer<TransferCubit, TransferState>(
        listener: (context, state) {
          print('📡 [TransferFormScreen] Estado recibido: ${state.runtimeType}');
          
          if (state is TransferOperationSuccess) {
            print('✅ [TransferFormScreen] Transferencia guardada exitosamente');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            // Cerrar la pantalla y retornar true
            if (context.mounted) {
              print('🚪 [TransferFormScreen] Cerrando pantalla...');
              Navigator.pop(context, true);
            }
          } else if (state is TransferError) {
            print('❌ [TransferFormScreen] Error: ${state.message}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is TransferLoading) {
            print('⏳ [TransferFormScreen] Guardando...');
          }
        },
        builder: (context, state) {
          final isLoading = state is TransferLoading;

          return Scaffold(
            appBar: AppBar(
              title: Text(isEditMode ? 'Editar Transferencia' : 'Registrar Transferencia'),
              actions: [
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: isLoading ? null : () => _handleSave(context),
                    tooltip: 'Guardar',
                  ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Información del bovino
                    _buildAnimalInfoCard(context),
                    const SizedBox(height: 24),

                    // Motivo de transferencia
                    Text(
                      'Motivo de Transferencia',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    _buildReasonSelector(),
                    const SizedBox(height: 24),

                    // Fecha de transferencia
                    Text(
                      'Fecha de Transferencia',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    _buildDateField(),
                    const SizedBox(height: 24),

                    // Ubicaciones
                    Text(
                      'Ubicaciones',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    // Origen: Solo lectura (finca actual)
                    TextFormField(
                      controller: _fromLocationController,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: 'Origen',
                        hintText: 'Cargando...',
                        prefixIcon: const Icon(Icons.location_on),
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        helperText: 'Finca desde la cual se realiza la transferencia',
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Destino: Selector de fincas disponibles
                    if (_loadingFarms)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_availableFarms.isEmpty)
                      Card(
                        color: Colors.orange.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.orange.shade700),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'No hay otras fincas disponibles para transferir',
                                  style: TextStyle(color: Colors.orange.shade700),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      DropdownButtonFormField<String>(
                        value: _selectedToFarmId,
                        decoration: const InputDecoration(
                          labelText: 'Destino',
                          hintText: 'Selecciona la finca destino',
                          prefixIcon: Icon(Icons.location_on),
                          border: OutlineInputBorder(),
                        ),
                        items: _availableFarms.map((farm) {
                          return DropdownMenuItem<String>(
                            value: farm.id,
                            child: Text(farm.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedToFarmId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor selecciona una finca destino';
                          }
                          return null;
                        },
                      ),
                    const SizedBox(height: 24),

                    // Información de transporte (opcional)
                    Text(
                      'Información de Transporte (Opcional)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _transporterNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del Transportista',
                        hintText: 'Ej: Juan Pérez',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _vehicleInfoController,
                      decoration: const InputDecoration(
                        labelText: 'Información del Vehículo',
                        hintText: 'Ej: Placa ABC-123, Tipo: Camión',
                        prefixIcon: Icon(Icons.local_shipping),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Foto de guía de movilización
                    Text(
                      'Guía de Movilización (Opcional)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    _buildMobilizationGuidePhotoUploader(),
                    const SizedBox(height: 24),

                    // Notas
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notas (Opcional)',
                        hintText: 'Información adicional sobre la transferencia',
                        prefixIcon: Icon(Icons.notes),
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),

                    // Botón de guardar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isLoading ? null : () => _handleSave(context),
                        icon: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.save),
                        label: Text(isLoading ? 'Guardando...' : 'Guardar Transferencia'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimalInfoCard(BuildContext context) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.pets, size: 40, color: Colors.blue.shade700),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.bovine.identifier,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (widget.bovine.name != null)
                    Text(
                      widget.bovine.name!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                    ),
                  Text(
                    '${widget.bovine.breed} • ${widget.bovine.ageDisplay}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: TransferReason.values.map((reason) {
        final isSelected = _selectedReason == reason;
        return FilterChip(
          label: Text(reason.displayName),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _selectedReason = reason;
              });
            }
          },
          selectedColor: Colors.blue.shade100,
          checkmarkColor: Colors.blue.shade700,
        );
      }).toList(),
    );
  }

  Widget _buildDateField() {
    final dateFormat = DateFormat('dd/MM/yyyy');
    return InkWell(
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: _transferDate,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
          locale: const Locale('es', 'ES'),
        );
        if (pickedDate != null) {
          setState(() {
            _transferDate = pickedDate;
          });
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Fecha de Transferencia',
          prefixIcon: Icon(Icons.calendar_today),
          border: OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(dateFormat.format(_transferDate)),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Widget _buildMobilizationGuidePhotoUploader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: _mobilizationGuidePhoto != null || _mobilizationGuidePhotoBytes != null
              ? Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: kIsWeb && _mobilizationGuidePhotoBytes != null
                          ? Image.memory(
                              _mobilizationGuidePhotoBytes!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            )
                          : !kIsWeb && _mobilizationGuidePhoto != null
                              ? Image.file(
                                  _mobilizationGuidePhoto as dynamic,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                )
                              : _buildEmptyPhotoPlaceholder(),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _mobilizationGuidePhoto = null;
                            _mobilizationGuidePhotoBytes = null;
                          });
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                )
              : _mobilizationGuidePhotoUrl != null
                  ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            _mobilizationGuidePhotoUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildEmptyPhotoPlaceholder();
                            },
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                _mobilizationGuidePhotoUrl = null;
                              });
                            },
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    )
                  : _buildEmptyPhotoPlaceholder(),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _uploadingPhoto ? null : _pickPhotoFromGallery,
                icon: const Icon(Icons.photo_library),
                label: const Text('Desde Galería'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _uploadingPhoto ? null : _takePhoto,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Tomar Foto'),
              ),
            ),
          ],
        ),
        if (_uploadingPhoto)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyPhotoPlaceholder() {
    return InkWell(
      onTap: _showPhotoOptions,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              'Toca para agregar foto\nde la guía de movilización',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Desde Galería'),
              onTap: () {
                Navigator.pop(context);
                _pickPhotoFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar Foto'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      
      if (photo != null && mounted) {
        final bytes = await photo.readAsBytes();
        setState(() {
          _mobilizationGuidePhotoUrl = null;
          if (kIsWeb) {
            _mobilizationGuidePhotoBytes = bytes;
            _mobilizationGuidePhoto = null;
          } else {
            _mobilizationGuidePhoto = _createFile(photo.path);
            _mobilizationGuidePhotoBytes = null;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al tomar foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickPhotoFromGallery() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      
      if (photo != null && mounted) {
        final bytes = await photo.readAsBytes();
        setState(() {
          _mobilizationGuidePhotoUrl = null;
          if (kIsWeb) {
            _mobilizationGuidePhotoBytes = bytes;
            _mobilizationGuidePhoto = null;
          } else {
            _mobilizationGuidePhoto = _createFile(photo.path);
            _mobilizationGuidePhotoBytes = null;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Helper para parseo seguro de números (precios, cantidades, etc.)
  double _parseSafeNumber(String text) {
    if (text.trim().isEmpty) return 0.0;
    // Elimina todo lo que no sea número o punto decimal
    String clean = text.replaceAll(RegExp(r'[^0-9.]'), '');
    // Si hay múltiples puntos, mantener solo el primero
    final parts = clean.split('.');
    if (parts.length > 2) {
      clean = '${parts[0]}.${parts.sublist(1).join()}';
    }
    return double.tryParse(clean) ?? 0.0;
  }

  Future<void> _handleSave(BuildContext context) async {
    print('🔵 [TransferFormScreen] Iniciando guardado de transferencia...');
    
    if (!_formKey.currentState!.validate()) {
      print('❌ [TransferFormScreen] Validación del formulario falló');
      return;
    }

    // Validar que se haya seleccionado un destino
    if (_selectedToFarmId == null || _selectedToFarmId!.isEmpty) {
      print('❌ [TransferFormScreen] No se seleccionó una finca destino');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona una finca destino'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validar que el bovino tenga ID
    if (widget.bovine.id.isEmpty) {
      print('❌ [TransferFormScreen] Bovino sin ID válido');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: El bovino no tiene un ID válido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Obtener el nombre de la finca destino de forma segura
    String destinationName;
    try {
      final selectedFarm = _availableFarms.firstWhere(
        (f) => f.id == _selectedToFarmId,
      );
      destinationName = selectedFarm.name;
    } catch (e) {
      // Si no se encuentra, usar el nombre de la finca actual como fallback
      destinationName = _currentFarm?.name ?? 'Finca Desconocida';
      print('⚠️ [TransferFormScreen] Finca destino no encontrada, usando fallback: $destinationName');
    }

    print('✅ [TransferFormScreen] Datos válidos. Bovino ID: ${widget.bovine.id}');
    print('📝 [TransferFormScreen] Origen: ${_fromLocationController.text}');
    print('📝 [TransferFormScreen] Destino: $destinationName');
    print('📝 [TransferFormScreen] Motivo: ${_selectedReason.displayName}');

    // Subir foto si hay una nueva
    String? photoUrl = _mobilizationGuidePhotoUrl;
    if (_mobilizationGuidePhoto != null || _mobilizationGuidePhotoBytes != null) {
      setState(() {
        _uploadingPhoto = true;
      });

      try {
        // Generar un ID temporal para la transferencia si estamos creando
        final transferId = isEditMode && widget.transfer != null
            ? widget.transfer!.id
            : 'temp_${DateTime.now().millisecondsSinceEpoch}';
        
        final storagePath = _storageService.generateMobilizationGuidePath(
          transferId,
          widget.farmId,
        );
        
        if (kIsWeb && _mobilizationGuidePhotoBytes != null) {
          // En web, subir desde bytes
          photoUrl = await _storageService.uploadImageFromBytes(
            _mobilizationGuidePhotoBytes!,
            storagePath,
          );
        } else if (!kIsWeb && _mobilizationGuidePhoto != null) {
            // En móvil, subir desde archivo
            photoUrl = await _storageService.uploadImage(
              _mobilizationGuidePhoto,
              storagePath,
            );
        }

        if (photoUrl == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error al subir la foto. ¿Deseas continuar sin la foto?'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
          }
        }
      } catch (e) {
        print('❌ [TransferFormScreen] Error al subir foto: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al subir la foto: $e'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _uploadingPhoto = false;
          });
        }
      }
    }

    // Mostrar feedback de guardado
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 16),
              Text('Guardando transferencia...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );
    }

    try {
      if (isEditMode && widget.transfer != null) {
      // Modo edición: actualizar transferencia existente
      final updatedTransfer = TransferEntity(
        id: widget.transfer!.id,
        bovineId: widget.bovine.id,
        farmId: widget.farmId,
        toFarmId: _selectedToFarmId,
        transferDate: _transferDate,
        fromLocation: _fromLocationController.text.trim(),
        toLocation: destinationName,
        reason: _selectedReason,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        transporterName: _transporterNameController.text.trim().isEmpty
            ? null
            : _transporterNameController.text.trim(),
        vehicleInfo: _vehicleInfoController.text.trim().isEmpty
            ? null
            : _vehicleInfoController.text.trim(),
        mobilizationGuidePhotoUrl: photoUrl,
        createdAt: widget.transfer!.createdAt,
        updatedAt: DateTime.now(),
      );

        print('✏️ [TransferFormScreen] Modo edición - Llamando a updateTransfer...');
        context.read<TransferCubit>().updateTransfer(updatedTransfer);
      } else {
        // Modo creación: agregar nueva transferencia
        print('➕ [TransferFormScreen] Modo creación - Llamando a addTransfer...');
        context.read<TransferCubit>().addTransfer(
              farmId: widget.farmId,
              bovineId: widget.bovine.id,
            fromLocation: _fromLocationController.text.trim(),
            toLocation: destinationName,
              reason: _selectedReason,
              transferDate: _transferDate,
              toFarmId: _selectedToFarmId,
              notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
              transporterName: _transporterNameController.text.trim().isEmpty
                  ? null
                  : _transporterNameController.text.trim(),
              vehicleInfo: _vehicleInfoController.text.trim().isEmpty
                  ? null
                  : _vehicleInfoController.text.trim(),
              mobilizationGuidePhotoUrl: photoUrl,
            );
      }
    } catch (e, stackTrace) {
      print('❌ [TransferFormScreen] Error inesperado al guardar: $e');
      print('Stack trace: $stackTrace');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Helper para crear File sin problemas de import condicional
  dynamic _createFile(String path) {
    if (kIsWeb) return null;
    // En móvil/desktop, crear File usando un método que funcione
    // Usar un cast dinámico para evitar problemas de compilación
    return _createNativeFile(path);
  }
  
  dynamic _createNativeFile(String path) {
    // Usar el helper que funciona en ambas plataformas
    return file_helper.FileHelperStub.createFile(path);
  }
}

