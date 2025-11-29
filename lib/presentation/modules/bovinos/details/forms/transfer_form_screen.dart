import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/di/dependency_injection.dart' as di;
import '../../../../../features/cattle/domain/entities/bovine_entity.dart';
import '../../../../../features/cattle/domain/entities/transfer_entity.dart';
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
  final _toLocationController = TextEditingController();
  final _transporterNameController = TextEditingController();
  final _vehicleInfoController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _transferDate = DateTime.now();
  TransferReason _selectedReason = TransferReason.otro;
  String? _selectedToFarmId;

  bool get isEditMode => widget.transfer != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode && widget.transfer != null) {
      // Modo edición: cargar datos existentes
      final transfer = widget.transfer!;
      _fromLocationController.text = transfer.fromLocation;
      _toLocationController.text = transfer.toLocation;
      _transporterNameController.text = transfer.transporterName ?? '';
      _vehicleInfoController.text = transfer.vehicleInfo ?? '';
      _notesController.text = transfer.notes ?? '';
      _transferDate = transfer.transferDate;
      _selectedReason = transfer.reason;
      _selectedToFarmId = transfer.toFarmId;
    } else {
      // Modo creación: pre-llenar origen
      _fromLocationController.text = 'Finca Actual';
    }
  }

  @override
  void dispose() {
    _fromLocationController.dispose();
    _toLocationController.dispose();
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true); // Retornar true para indicar éxito
          } else if (state is TransferError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
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
                    onPressed: isLoading ? null : _handleSave,
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
                    TextFormField(
                      controller: _fromLocationController,
                      decoration: const InputDecoration(
                        labelText: 'Origen',
                        hintText: 'Ej: Finca Principal, Pasto 1, etc.',
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor ingresa el origen';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _toLocationController,
                      decoration: const InputDecoration(
                        labelText: 'Destino',
                        hintText: 'Ej: Finca Secundaria, Pasto 2, etc.',
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor ingresa el destino';
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
                        onPressed: isLoading ? null : _handleSave,
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

  void _handleSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (isEditMode && widget.transfer != null) {
      // Modo edición: actualizar transferencia existente
      final updatedTransfer = TransferEntity(
        id: widget.transfer!.id,
        bovineId: widget.bovine.id,
        farmId: widget.farmId,
        toFarmId: _selectedToFarmId,
        transferDate: _transferDate,
        fromLocation: _fromLocationController.text.trim(),
        toLocation: _toLocationController.text.trim(),
        reason: _selectedReason,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        transporterName: _transporterNameController.text.trim().isEmpty
            ? null
            : _transporterNameController.text.trim(),
        vehicleInfo: _vehicleInfoController.text.trim().isEmpty
            ? null
            : _vehicleInfoController.text.trim(),
        createdAt: widget.transfer!.createdAt,
        updatedAt: DateTime.now(),
      );

      context.read<TransferCubit>().updateTransfer(updatedTransfer);
    } else {
      // Modo creación: agregar nueva transferencia
      context.read<TransferCubit>().addTransfer(
            farmId: widget.farmId,
            bovineId: widget.bovine.id,
            fromLocation: _fromLocationController.text.trim(),
            toLocation: _toLocationController.text.trim(),
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
          );
    }
  }
}

