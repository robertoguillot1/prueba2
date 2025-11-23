import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';
import '../models/pig.dart';
import '../models/pig_vaccine.dart';

class PigVaccineFormScreen extends StatefulWidget {
  final Farm farm;
  final Pig? selectedPig;
  final PigVaccine? vaccineToEdit;

  const PigVaccineFormScreen({
    super.key,
    required this.farm,
    this.selectedPig,
    this.vaccineToEdit,
  });

  @override
  State<PigVaccineFormScreen> createState() => _PigVaccineFormScreenState();
}

class _PigVaccineFormScreenState extends State<PigVaccineFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _vaccineNameController;
  late TextEditingController _batchNumberController;
  DateTime _applicationDate = DateTime.now();
  DateTime? _nextDoseDate;
  late TextEditingController _administeredByController;
  late TextEditingController _observationsController;
  late TextEditingController _notesController;
  Pig? _selectedPig;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    if (widget.vaccineToEdit != null) {
      _initializeWithVaccine();
    } else {
      if (widget.selectedPig != null) {
        try {
          _selectedPig = widget.farm.pigs.firstWhere(
            (p) => p.id == widget.selectedPig!.id,
          );
        } catch (e) {
          _selectedPig = null;
        }
      }
      _vaccineNameController = TextEditingController();
      _batchNumberController = TextEditingController();
      _administeredByController = TextEditingController();
      _observationsController = TextEditingController();
      _notesController = TextEditingController();
    }
  }

  void _initializeWithVaccine() {
    final vaccine = widget.vaccineToEdit!;
    try {
      _selectedPig = widget.farm.pigs.firstWhere(
        (p) => p.id == vaccine.pigId,
      );
    } catch (e) {
      _selectedPig = null;
    }
    _vaccineNameController = TextEditingController(text: vaccine.vaccineName);
    _batchNumberController = TextEditingController(text: vaccine.batchNumber ?? '');
    _applicationDate = vaccine.date;
    _nextDoseDate = vaccine.nextDoseDate;
    _administeredByController = TextEditingController(text: vaccine.administeredBy ?? '');
    _observationsController = TextEditingController(text: vaccine.observations ?? '');
    _notesController = TextEditingController(text: vaccine.notes ?? '');
  }

  @override
  void dispose() {
    _vaccineNameController.dispose();
    _batchNumberController.dispose();
    _administeredByController.dispose();
    _observationsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveVaccine() async {
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
      final vaccineId = widget.vaccineToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
      
      final vaccine = PigVaccine(
        id: vaccineId,
        pigId: _selectedPig!.id,
        farmId: widget.farm.id,
        date: _applicationDate,
        vaccineName: _vaccineNameController.text.trim(),
        batchNumber: _batchNumberController.text.trim().isEmpty ? null : _batchNumberController.text.trim(),
        nextDoseDate: _nextDoseDate,
        administeredBy: _administeredByController.text.trim().isEmpty ? null : _administeredByController.text.trim(),
        observations: _observationsController.text.trim().isEmpty ? null : _observationsController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      if (widget.vaccineToEdit == null) {
        await farmProvider.addPigVaccine(vaccine, farmId: widget.farm.id);
      } else {
        await farmProvider.updatePigVaccine(vaccine, farmId: widget.farm.id);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.vaccineToEdit == null
                ? 'Vacuna registrada exitosamente'
                : 'Vacuna actualizada exitosamente'),
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

  Future<void> _deleteVaccine() async {
    if (widget.vaccineToEdit == null) return;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Vacuna'),
        content: const Text('¿Está seguro de que desea eliminar este registro de vacuna?'),
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

    if (confirm == true) {
      setState(() => _isProcessing = true);
      try {
        final farmProvider = Provider.of<FarmProvider>(context, listen: false);
        await farmProvider.deletePigVaccine(widget.vaccineToEdit!.id, farmId: widget.farm.id);
        
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vacuna eliminada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: $e'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vaccineToEdit == null ? '💉 Registrar Vacuna' : '💉 Editar Vacuna'),
        centerTitle: true,
        backgroundColor: widget.farm.primaryColor,
        foregroundColor: Colors.white,
        actions: widget.vaccineToEdit != null
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _isProcessing ? null : _deleteVaccine,
                ),
              ]
            : null,
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
                labelText: 'Cerdo *',
                prefixIcon: Icon(Icons.pets),
                border: OutlineInputBorder(),
              ),
              items: widget.farm.pigs.map((pig) {
                return DropdownMenuItem<Pig>(
                  value: pig,
                  child: Text(pig.identification ?? 'Sin ID'),
                );
              }).toList(),
              onChanged: widget.vaccineToEdit == null
                  ? (value) => setState(() => _selectedPig = value)
                  : null,
              validator: (value) {
                if (value == null) return 'Selecciona un cerdo';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Nombre de la vacuna
            TextFormField(
              controller: _vaccineNameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la vacuna *',
                hintText: 'Ej: Peste porcina, Parvovirus, etc.',
                prefixIcon: Icon(Icons.medical_services),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre de la vacuna es requerido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Número de lote
            TextFormField(
              controller: _batchNumberController,
              decoration: const InputDecoration(
                labelText: 'Número de lote (opcional)',
                hintText: 'Lote de la vacuna',
                prefixIcon: Icon(Icons.numbers),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Fecha de aplicación
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Fecha de aplicación'),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(_applicationDate)),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _applicationDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => _applicationDate = date);
                  }
                },
              ),
            ),
            const SizedBox(height: 16),

            // Próxima dosis
            Card(
              child: ListTile(
                leading: const Icon(Icons.schedule),
                title: const Text('Próxima dosis (opcional)'),
                subtitle: Text(
                  _nextDoseDate != null
                      ? DateFormat('dd/MM/yyyy').format(_nextDoseDate!)
                      : 'No especificada',
                ),
                trailing: _nextDoseDate != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _nextDoseDate = null),
                      )
                    : null,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _applicationDate.add(const Duration(days: 180)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (date != null) {
                    setState(() => _nextDoseDate = date);
                  }
                },
              ),
            ),
            const SizedBox(height: 16),

            // Administrado por
            TextFormField(
              controller: _administeredByController,
              decoration: const InputDecoration(
                labelText: 'Administrado por (opcional)',
                hintText: 'Veterinario o encargado',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Observaciones
            TextFormField(
              controller: _observationsController,
              decoration: const InputDecoration(
                labelText: 'Observaciones (opcional)',
                hintText: 'Notas adicionales sobre la aplicación',
                prefixIcon: Icon(Icons.note),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Notas
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notas (opcional)',
                hintText: 'Información adicional',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // Botón de guardar
            ElevatedButton(
              onPressed: _isProcessing ? null : _saveVaccine,
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


