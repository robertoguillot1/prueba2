import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';
import '../models/cattle.dart';
import '../models/cattle_weight_record.dart';

class CattleWeightFormScreen extends StatefulWidget {
  final Farm farm;
  final Cattle? selectedCattle;

  const CattleWeightFormScreen({
    super.key,
    required this.farm,
    this.selectedCattle,
  });

  @override
  State<CattleWeightFormScreen> createState() => _CattleWeightFormScreenState();
}

class _CattleWeightFormScreenState extends State<CattleWeightFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  Cattle? _selectedCattle;
  DateTime _recordDate = DateTime.now();
  late TextEditingController _weightController;
  late TextEditingController _notesController;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _selectedCattle = widget.selectedCattle;
    _weightController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCattle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un animal')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final farmProvider = Provider.of<FarmProvider>(context, listen: false);
      final recordId = DateTime.now().millisecondsSinceEpoch.toString();
      
      final record = CattleWeightRecord(
        id: recordId,
        cattleId: _selectedCattle!.id,
        farmId: widget.farm.id,
        recordDate: _recordDate,
        weight: double.parse(_weightController.text),
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      await farmProvider.addCattleWeightRecord(record);
      
      // Actualizar el peso del animal
      final updatedCattle = _selectedCattle!.copyWith(
        currentWeight: double.parse(_weightController.text),
      );
      await farmProvider.updateCattle(updatedCattle);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registro de peso guardado exitosamente'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Registrar Peso'),
        centerTitle: true,
        backgroundColor: widget.farm.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Selección de animal
            DropdownButtonFormField<Cattle>(
              value: _selectedCattle,
              decoration: const InputDecoration(
                labelText: 'Animal *',
                prefixIcon: Icon(Icons.pets),
                border: OutlineInputBorder(),
              ),
              items: widget.farm.cattle.map((cattle) {
                return DropdownMenuItem<Cattle>(
                  value: cattle,
                  child: Text('${cattle.name ?? cattle.identification ?? "Sin ID"} (${cattle.currentWeight.toStringAsFixed(0)} kg)'),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedCattle = value),
              validator: (value) {
                if (value == null) return 'Selecciona un animal';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Fecha
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Fecha del registro'),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(_recordDate)),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _recordDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => _recordDate = date);
                  }
                },
              ),
            ),
            const SizedBox(height: 16),

            // Peso
            TextFormField(
              controller: _weightController,
              decoration: const InputDecoration(
                labelText: 'Peso (kg) *',
                prefixIcon: Icon(Icons.monitor_weight),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El peso es requerido';
                }
                final weight = double.tryParse(value);
                if (weight == null || weight <= 0) {
                  return 'Ingrese un peso válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Notas
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notas (opcional)',
                prefixIcon: Icon(Icons.note),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Botón de guardar
            ElevatedButton(
              onPressed: _isProcessing ? null : _saveRecord,
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
                  : const Text('Guardar', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
























