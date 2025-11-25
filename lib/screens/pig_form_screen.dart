import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';
import '../models/pig.dart';

class PigFormScreen extends StatefulWidget {
  final Farm farm;
  final Pig? pigToEdit;

  const PigFormScreen({
    super.key,
    required this.farm,
    this.pigToEdit,
  });

  @override
  State<PigFormScreen> createState() => _PigFormScreenState();
}

class _PigFormScreenState extends State<PigFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _identificationController;
  late PigGender _gender;
  DateTime? _birthDate;
  late TextEditingController _weightController;
  late FeedingStage _feedingStage;
  late TextEditingController _notesController;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _identificationController = TextEditingController(
      text: widget.pigToEdit?.identification ?? '',
    );
    _gender = widget.pigToEdit?.gender ?? PigGender.male;
    _birthDate = widget.pigToEdit?.birthDate;
    _weightController = TextEditingController(
      text: widget.pigToEdit?.currentWeight.toString() ?? '',
    );
    // Calcular etapa de alimentación basada en el peso
    if (widget.pigToEdit != null) {
      _feedingStage = _calculateFeedingStageFromWeight(widget.pigToEdit!.currentWeight);
    } else {
      _feedingStage = FeedingStage.inicio;
    }
    _notesController = TextEditingController(
      text: widget.pigToEdit?.notes ?? '',
    );
    
    // Listener para actualizar etapa cuando cambia el peso
    _weightController.addListener(_onWeightChanged);
  }
  
  void _onWeightChanged() {
    final weightText = _weightController.text;
    if (weightText.isNotEmpty) {
      final weight = double.tryParse(weightText);
      if (weight != null && weight > 0) {
        setState(() {
          _feedingStage = _calculateFeedingStageFromWeight(weight);
        });
      }
    }
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

  @override
  void dispose() {
    _identificationController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _savePig() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    try {
      final farmProvider = Provider.of<FarmProvider>(context, listen: false);
      final pigId = widget.pigToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
      
      final pig = Pig(
        id: pigId,
        farmId: widget.farm.id,
        identification: _identificationController.text.isEmpty ? null : _identificationController.text,
        gender: _gender,
        birthDate: _birthDate ?? DateTime.now(),
        currentWeight: double.parse(_weightController.text),
        feedingStage: _feedingStage,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        updatedAt: DateTime.now(),
      );

      if (widget.pigToEdit == null) {
        await farmProvider.addPig(pig);
      } else {
        await farmProvider.updatePig(pig);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.pigToEdit == null
                ? 'Cerdo agregado exitosamente'
                : 'Cerdo actualizado exitosamente'),
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

  Future<void> _deletePig() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Está seguro de eliminar este cerdo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && widget.pigToEdit != null) {
      final farmProvider = Provider.of<FarmProvider>(context, listen: false);
      await farmProvider.deletePig(widget.pigToEdit!.id);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cerdo eliminado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pigToEdit == null ? 'Agregar Cerdo' : 'Editar Cerdo'),
        centerTitle: true,
        backgroundColor: widget.farm.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (widget.pigToEdit != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deletePig,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Identificación
            TextFormField(
              controller: _identificationController,
              decoration: const InputDecoration(
                labelText: 'Identificación (opcional)',
                hintText: 'Nombre o ID único del cerdo',
                prefixIcon: Icon(Icons.label),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Género
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Género'),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<PigGender>(
                            title: const Text('Macho'),
                            value: PigGender.male,
                            groupValue: _gender,
                            onChanged: (value) => setState(() => _gender = value!),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<PigGender>(
                            title: const Text('Hembra'),
                            value: PigGender.female,
                            groupValue: _gender,
                            onChanged: (value) => setState(() => _gender = value!),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Fecha de nacimiento
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Fecha de nacimiento'),
                subtitle: Text(
                  _birthDate != null
                      ? DateFormat('dd/MM/yyyy').format(_birthDate!)
                      : 'No especificada',
                ),
                trailing: _birthDate != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _birthDate = null),
                      )
                    : null,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _birthDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => _birthDate = date);
                  }
                },
              ),
            ),
            const SizedBox(height: 16),

            // Peso actual
            TextFormField(
              controller: _weightController,
              decoration: const InputDecoration(
                labelText: 'Peso actual (kg)',
                hintText: 'Ingrese el peso',
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

            // Etapa de alimentación
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Etapa de alimentación'),
                    RadioListTile<FeedingStage>(
                      title: const Text('Inicio'),
                      value: FeedingStage.inicio,
                      groupValue: _feedingStage,
                      onChanged: (value) => setState(() => _feedingStage = value!),
                    ),
                    RadioListTile<FeedingStage>(
                      title: const Text('Levante'),
                      value: FeedingStage.levante,
                      groupValue: _feedingStage,
                      onChanged: (value) => setState(() => _feedingStage = value!),
                    ),
                    RadioListTile<FeedingStage>(
                      title: const Text('Engorde'),
                      value: FeedingStage.engorde,
                      groupValue: _feedingStage,
                      onChanged: (value) => setState(() => _feedingStage = value!),
                    ),
                  ],
                ),
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
              onPressed: _isProcessing ? null : _savePig,
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

