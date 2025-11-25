import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';
import '../models/pig.dart';
import '../models/weight_record.dart';

class WeightRecordFormScreen extends StatefulWidget {
  final Farm farm;
  final Pig? selectedPig;

  const WeightRecordFormScreen({
    super.key,
    required this.farm,
    this.selectedPig,
  });

  @override
  State<WeightRecordFormScreen> createState() => _WeightRecordFormScreenState();
}

class _WeightRecordFormScreenState extends State<WeightRecordFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  Pig? _selectedPig;
  DateTime _recordDate = DateTime.now();
  late TextEditingController _weightController;
  String? _notes;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _selectedPig = widget.selectedPig;
    _weightController = TextEditingController();
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPig == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un cerdo')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final farmProvider = Provider.of<FarmProvider>(context, listen: false);
      final recordId = DateTime.now().millisecondsSinceEpoch.toString();
      
      final record = WeightRecord(
        id: recordId,
        pigId: _selectedPig!.id,
        farmId: widget.farm.id,
        recordDate: _recordDate,
        weight: double.parse(_weightController.text),
        notes: _notes,
      );

      await farmProvider.addWeightRecord(record);
      
      // Calcular nueva etapa de alimentación basada en el nuevo peso
      final newWeight = double.parse(_weightController.text);
      final newFeedingStage = _calculateFeedingStageFromWeight(newWeight);
      
      // Actualizar el peso y la etapa de alimentación del cerdo
      final updatedPig = _selectedPig!.copyWith(
        currentWeight: newWeight,
        feedingStage: newFeedingStage,
      );
      await farmProvider.updatePig(updatedPig);
      
      // Mostrar mensaje si cambió la etapa
      if (_selectedPig!.feedingStage != newFeedingStage) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Etapa de alimentación actualizada a: ${_getStageName(newFeedingStage)}'),
              backgroundColor: Colors.blue,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }

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
            // Selección de cerdo
            DropdownButtonFormField<Pig>(
              value: _selectedPig,
              decoration: const InputDecoration(
                labelText: 'Cerdo',
                prefixIcon: Icon(Icons.pets),
                border: OutlineInputBorder(),
              ),
              items: widget.farm.pigs.map((pig) {
                return DropdownMenuItem<Pig>(
                  value: pig,
                  child: Text(pig.identification ?? 'Sin ID'),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedPig = value),
              validator: (value) {
                if (value == null) return 'Selecciona un cerdo';
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
                labelText: 'Peso (kg)',
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
              initialValue: _notes,
              decoration: const InputDecoration(
                labelText: 'Notas (opcional)',
                prefixIcon: Icon(Icons.note),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onSaved: (value) => _notes = value?.isEmpty == true ? null : value,
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
  
  FeedingStage _calculateFeedingStageFromWeight(double weight) {
    if (weight <= 24) {
      return FeedingStage.inicio;
    } else if (weight >= 25 && weight <= 69) {
      return FeedingStage.levante;
    } else if (weight >= 70) {
      return FeedingStage.engorde;
    }
    return FeedingStage.inicio;
  }
  
  String _getStageName(FeedingStage stage) {
    switch (stage) {
      case FeedingStage.inicio:
        return 'Inicio';
      case FeedingStage.levante:
        return 'Levante';
      case FeedingStage.engorde:
        return 'Engorde';
    }
  }
}
























