import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/di/dependency_injection.dart' as di;
import '../../../../../features/cattle/domain/entities/bovine_entity.dart';
import '../../../../../features/cattle/domain/entities/transfer_entity.dart';
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
  final _toLocationController = TextEditingController();
  final _transporterNameController = TextEditingController();
  final _vehicleInfoController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _transferDate = DateTime.now();
  TransferReason _selectedReason = TransferReason.otro;
  String? _selectedToFarmId;
  int _transfersCreated = 0;
  int _transfersTotal = 0;

  @override
  void initState() {
    super.initState();
    _fromLocationController.text = 'Finca Actual';
    _transfersTotal = widget.bovines.length;
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

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Resetear contador
    setState(() {
      _transfersCreated = 0;
    });

    final cubit = context.read<TransferCubit>();
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
          toLocation: _toLocationController.text.trim(),
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
}

