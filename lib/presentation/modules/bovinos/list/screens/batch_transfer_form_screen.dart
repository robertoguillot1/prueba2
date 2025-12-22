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
import '../../details/cubits/transfer_cubit.dart';
import '../../details/cubits/transfer_state.dart';

/// Pantalla de formulario para registrar transferencia de lote
class BatchTransferFormScreen extends StatefulWidget {
  final List<BovineEntity> bovines;
  final String farmId;

  const BatchTransferFormScreen({
    super.key,
    required this.bovines,
    required this.farmId,
  });

  @override
  State<BatchTransferFormScreen> createState() => _BatchTransferFormScreenState();
}

class _BatchTransferFormScreenState extends State<BatchTransferFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fromLocationController = TextEditingController();
  final _transporterNameController = TextEditingController();
  final _vehicleInfoController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _transferDate = DateTime.now();
  TransferReason _selectedReason = TransferReason.otro;
  String? _selectedToFarmId;
  int _transfersCreated = 0;
  int _transfersTotal = 0;
  
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

  @override
  void initState() {
    super.initState();
    _transfersTotal = widget.bovines.length;
    _loadFarms();
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
        } else {
          _fromLocationController.text = 'Finca Actual';
        }
      });
    } catch (e) {
      print('❌ [BatchTransferFormScreen] Error al cargar fincas: $e');
      setState(() {
        _loadingFarms = false;
        _fromLocationController.text = 'Finca Actual';
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
          if (state is TransferOperationSuccess) {
            setState(() {
              _transfersCreated++;
            });
          } else if (state is TransferError) {
            // Solo mostrar error si no estamos en proceso de lote
            if (_transfersCreated == 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        builder: (context, state) {
          final isLoading = state is TransferLoading;

          return Scaffold(
            appBar: AppBar(
              title: Text('Transferencia de Lote (${widget.bovines.length})'),
              actions: [
                if (isLoading)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        if (_transfersCreated > 0)
                          Text(
                            '$_transfersCreated/$_transfersTotal',
                            style: const TextStyle(fontSize: 12),
                          ),
                      ],
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
                    // Información del lote
                    _buildBatchInfoCard(context),
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
                        label: Text(
                          isLoading
                              ? 'Guardando... ($_transfersCreated/$_transfersTotal)'
                              : 'Guardar Transferencia de Lote',
                        ),
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

  Widget _buildBatchInfoCard(BuildContext context) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.list, size: 40, color: Colors.blue.shade700),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transferencia de Lote',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        '${widget.bovines.length} bovino${widget.bovines.length > 1 ? 's' : ''} seleccionado${widget.bovines.length > 1 ? 's' : ''}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade700,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Bovinos incluidos:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            ...widget.bovines.take(5).map((bovine) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        bovine.gender == BovineGender.female
                            ? Icons.female
                            : Icons.male,
                        size: 16,
                        color: bovine.gender == BovineGender.female
                            ? Colors.pink
                            : Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${bovine.identifier}${bovine.name?.isNotEmpty == true ? ' - ${bovine.name}' : ''}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                )),
            if (widget.bovines.length > 5)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '... y ${widget.bovines.length - 5} más',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade600,
                      ),
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

  Future<void> _handleSave(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validar que se haya seleccionado un destino
    if (_selectedToFarmId == null || _selectedToFarmId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona una finca destino'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Resetear contador
    setState(() {
      _transfersCreated = 0;
    });

    // Usar el contexto del builder que tiene acceso al BlocProvider
    final cubit = context.read<TransferCubit>();
    
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
      print('⚠️ [BatchTransferFormScreen] Finca destino no encontrada, usando fallback: $destinationName');
    }

    // Subir foto si hay una nueva (la misma foto se aplicará a todas las transferencias)
    String? photoUrl = _mobilizationGuidePhotoUrl;
    if (_mobilizationGuidePhoto != null || _mobilizationGuidePhotoBytes != null) {
      setState(() {
        _uploadingPhoto = true;
      });

      try {
        // Usar un ID temporal para el lote
        final batchId = 'batch_${DateTime.now().millisecondsSinceEpoch}';
        final storagePath = _storageService.generateMobilizationGuidePath(
          batchId,
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

        if (photoUrl == null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al subir la foto. Continuando sin la foto...'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        print('❌ [BatchTransferFormScreen] Error al subir foto: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al subir la foto: $e'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 2),
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
    
    int completed = 0;
    int errors = 0;

    // Crear una transferencia para cada bovino
    for (final bovine in widget.bovines) {
      try {
        // Crear la transferencia
        cubit.addTransfer(
          farmId: widget.farmId,
          bovineId: bovine.id,
          fromLocation: _fromLocationController.text.trim(),
          toLocation: destinationName,
          reason: _selectedReason,
          transferDate: _transferDate,
          toFarmId: _selectedToFarmId,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          transporterName: _transporterNameController.text.trim().isEmpty
              ? null
              : _transporterNameController.text.trim(),
          vehicleInfo: _vehicleInfoController.text.trim().isEmpty
              ? null
              : _vehicleInfoController.text.trim(),
          mobilizationGuidePhotoUrl: photoUrl,
        );

        // Esperar un poco para que se procese
        await Future.delayed(const Duration(milliseconds: 500));
        completed++;
        
        // Actualizar contador en la UI
        if (mounted) {
          setState(() {
            _transfersCreated = completed;
          });
        }
      } catch (e) {
        errors++;
        print('❌ Error al crear transferencia para ${bovine.identifier}: $e');
      }
    }

    // Esperar un poco más para asegurar que todas se completen
    await Future.delayed(const Duration(seconds: 1));

    // Mostrar resultado final
    if (mounted) {
      if (completed == widget.bovines.length) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Transferencia de lote completada: ${widget.bovines.length} bovino${widget.bovines.length > 1 ? 's' : ''} transferido${widget.bovines.length > 1 ? 's' : ''}',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.pop(context, true);
      } else if (completed > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '⚠️ Se crearon $completed de ${widget.bovines.length} transferencias${errors > 0 ? ' ($errors errores)' : ''}',
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ No se pudo crear ninguna transferencia'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
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

