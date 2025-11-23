import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';
import '../models/cattle.dart';
import '../models/cattle_vaccine.dart';

class CattleVaccineFormScreen extends StatefulWidget {
  final Farm farm;
  final Cattle? selectedCattle;

  const CattleVaccineFormScreen({
    super.key,
    required this.farm,
    this.selectedCattle,
  });

  @override
  State<CattleVaccineFormScreen> createState() => _CattleVaccineFormScreenState();
}

class _CattleVaccineFormScreenState extends State<CattleVaccineFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _vaccineNameController;
  DateTime _applicationDate = DateTime.now();
  DateTime? _nextDoseDate;
  late TextEditingController _administeredByController;
  late TextEditingController _observationsController;
  Cattle? _selectedCattle;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Buscar el animal en la lista de la finca para asegurar que sea la misma instancia
    // Esto es necesario porque el DropdownButton compara objetos por referencia
    if (widget.selectedCattle != null) {
      try {
        _selectedCattle = widget.farm.cattle.firstWhere(
          (c) => c.id == widget.selectedCattle!.id,
        );
      } catch (e) {
        // Si no se encuentra, usar null para que el usuario seleccione manualmente
        _selectedCattle = null;
      }
    }
    _vaccineNameController = TextEditingController();
    _administeredByController = TextEditingController();
    _observationsController = TextEditingController();
  }

  @override
  void dispose() {
    _vaccineNameController.dispose();
    _administeredByController.dispose();
    _observationsController.dispose();
    super.dispose();
  }

  Future<void> _saveVaccine() async {
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
      final vaccineId = DateTime.now().millisecondsSinceEpoch.toString();
      
      final vaccine = CattleVaccine(
        id: vaccineId,
        cattleId: _selectedCattle!.id,
        farmId: widget.farm.id,
        date: _applicationDate,
        vaccineName: _vaccineNameController.text,
        nextDoseDate: _nextDoseDate,
        administeredBy: _administeredByController.text.isEmpty ? null : _administeredByController.text,
        observations: _observationsController.text.isEmpty ? null : _observationsController.text,
      );

      await farmProvider.addCattleVaccine(vaccine);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vacuna registrada exitosamente'),
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
        title: const Text('💉 Registrar Vacuna'),
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
                  child: Text(cattle.name ?? cattle.identification ?? 'Sin ID'),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedCattle = value),
              validator: (value) {
                if (value == null) return 'Selecciona un animal';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Nombre de la vacuna
            TextFormField(
              controller: _vaccineNameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la vacuna *',
                hintText: 'Ej: Triple viral, Brucella, etc.',
                prefixIcon: Icon(Icons.medical_services),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El nombre de la vacuna es requerido';
                }
                return null;
              },
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
                hintText: 'Notas adicionales',
                prefixIcon: Icon(Icons.note),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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


