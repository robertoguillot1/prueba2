import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';
import '../models/cattle.dart';
import '../models/cattle_transfer.dart';
import '../models/cattle_trip.dart';

class CattleTransferFormScreen extends StatefulWidget {
  final Farm farm;

  const CattleTransferFormScreen({super.key, required this.farm});

  @override
  State<CattleTransferFormScreen> createState() => _CattleTransferFormScreenState();
}

class _CattleTransferFormScreenState extends State<CattleTransferFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  bool _isLote = false; // true para lote, false para animal individual
  Cattle? _selectedCattle;
  List<String> _selectedCattleIds = [];
  String? _selectedDestFarmId;
  DateTime _transferDate = DateTime.now();
  TransferReason _reason = TransferReason.otro;
  late TextEditingController _transporterNameController;
  late TextEditingController _vehicleInfoController;
  late TextEditingController _notesController;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _transporterNameController = TextEditingController();
    _vehicleInfoController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _transporterNameController.dispose();
    _vehicleInfoController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveTransfer() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDestFarmId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una finca destino')),
      );
      return;
    }
    if (!_isLote && _selectedCattle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un animal')),
      );
      return;
    }
    if (_isLote && _selectedCattleIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos un animal')),
      );
      return;
    }
    if (_selectedDestFarmId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una finca destino')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final farmProvider = Provider.of<FarmProvider>(context, listen: false);
      final tripId = DateTime.now().millisecondsSinceEpoch.toString();
      
      final trip = CattleTrip(
        id: tripId,
        farmId: widget.farm.id,
        tripDate: _transferDate,
        destination: _selectedDestFarmId ?? '',
        purpose: _reason.displayName,
        cattleIds: _isLote ? _selectedCattleIds : [_selectedCattle!.id],
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      await farmProvider.addCattleTrip(trip);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transferencia registrada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final farmProvider = Provider.of<FarmProvider>(context);
    final availableFarms = farmProvider.farms.where((f) => f.id != widget.farm.id).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('🚚 Nueva Transferencia'),
        centerTitle: true,
        backgroundColor: widget.farm.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Opción de selección: animal individual o lote
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tipo de transferencia', style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile(
                            title: const Text('Animal individual'),
                            value: false,
                            groupValue: _isLote,
                            onChanged: (value) {
                              setState(() {
                                _isLote = false;
                                _selectedCattleIds.clear();
                                _selectedCattle = null;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile(
                            title: const Text('Lote'),
                            value: true,
                            groupValue: _isLote,
                            onChanged: (value) {
                              setState(() {
                                _isLote = true;
                                _selectedCattleIds.clear();
                                _selectedCattle = null;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Selección de animal(es)
            if (!_isLote)
              // Animal individual
              DropdownButtonFormField<Cattle>(
                value: _selectedCattle,
                hint: const Text('Selecciona un animal'),
                decoration: const InputDecoration(
                  labelText: 'Animal *',
                  prefixIcon: Icon(Icons.pets),
                  border: OutlineInputBorder(),
                ),
                items: widget.farm.cattle.map((cattle) {
                  return DropdownMenuItem<Cattle>(
                    value: cattle,
                    child: Text(cattle.name ?? cattle.identification ?? 'Sin ID'),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedCattle = value),
                validator: (value) {
                  if (!_isLote && value == null) return 'Selecciona un animal';
                  return null;
                },
              )
            else
              // Selección múltiple de animales
              ExpansionTile(
                title: Text('Seleccionar animales del lote (${_selectedCattleIds.length} seleccionados)'),
                leading: const Icon(Icons.list),
                children: widget.farm.cattle.map((cattle) {
                  final isSelected = _selectedCattleIds.contains(cattle.id);
                  return CheckboxListTile(
                    title: Text(cattle.name ?? cattle.identification ?? 'Sin ID'),
                    subtitle: Text('${cattle.categoryString} - ${cattle.currentWeight.toStringAsFixed(1)} kg'),
                    value: isSelected,
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          _selectedCattleIds.add(cattle.id);
                        } else {
                          _selectedCattleIds.remove(cattle.id);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            const SizedBox(height: 16),

            // Finca destino
            if (availableFarms.isEmpty)
              Card(
                color: Colors.orange[50],
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'No hay otras fincas disponibles para transferir',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              DropdownButtonFormField<String>(
                value: _selectedDestFarmId,
                hint: const Text('Selecciona una finca'),
                decoration: const InputDecoration(
                  labelText: 'Finca destino *',
                  prefixIcon: Icon(Icons.home),
                  border: OutlineInputBorder(),
                ),
                items: availableFarms.map((farm) {
                  return DropdownMenuItem<String>(
                    value: farm.id,
                    child: Text(farm.name),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedDestFarmId = value),
                validator: (value) {
                  if (value == null) return 'Selecciona una finca destino';
                  return null;
                },
              ),
            const SizedBox(height: 16),

            // Motivo de transferencia
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Motivo', style: TextStyle(fontWeight: FontWeight.bold)),
                    RadioListTile(
                      title: const Text('Venta'),
                      value: TransferReason.venta,
                      groupValue: _reason,
                      onChanged: (value) => setState(() => _reason = value!),
                    ),
                    RadioListTile(
                      title: const Text('Préstamo'),
                      value: TransferReason.prestamo,
                      groupValue: _reason,
                      onChanged: (value) => setState(() => _reason = value!),
                    ),
                    RadioListTile(
                      title: const Text('Reproducción'),
                      value: TransferReason.reproduccion,
                      groupValue: _reason,
                      onChanged: (value) => setState(() => _reason = value!),
                    ),
                    RadioListTile(
                      title: const Text('Tratamiento'),
                      value: TransferReason.tratamiento,
                      groupValue: _reason,
                      onChanged: (value) => setState(() => _reason = value!),
                    ),
                    RadioListTile(
                      title: const Text('Otro'),
                      value: TransferReason.otro,
                      groupValue: _reason,
                      onChanged: (value) => setState(() => _reason = value!),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Fecha de transferencia
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Fecha de transferencia'),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(_transferDate)),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _transferDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => _transferDate = date);
                  }
                },
              ),
            ),
            const SizedBox(height: 16),

            // Información de transporte
            TextFormField(
              controller: _transporterNameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del transportista (opcional)',
                hintText: 'Quien transportó los animales',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _vehicleInfoController,
              decoration: const InputDecoration(
                labelText: 'Información del vehículo (opcional)',
                hintText: 'Ej: Placa, modelo del vehículo',
                prefixIcon: Icon(Icons.directions_car),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Notas
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notas (opcional)',
                hintText: 'Información adicional',
                prefixIcon: Icon(Icons.note),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Botón de guardar
            ElevatedButton(
              onPressed: _isProcessing ? null : _saveTransfer,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.farm.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isProcessing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Guardar Transferencia', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}