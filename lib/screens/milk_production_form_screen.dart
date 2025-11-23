import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';
import '../models/cattle.dart';
import '../models/milk_production.dart';

class MilkProductionFormScreen extends StatefulWidget {
  final Farm farm;
  final Cattle? selectedCattle;
  final MilkProduction? recordToEdit;

  const MilkProductionFormScreen({
    super.key,
    required this.farm,
    this.selectedCattle,
    this.recordToEdit,
  });

  @override
  State<MilkProductionFormScreen> createState() => _MilkProductionFormScreenState();
}

class _MilkProductionFormScreenState extends State<MilkProductionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  Cattle? _selectedCattle;
  DateTime _recordDate = DateTime.now();
  late TextEditingController _litersController;
  late TextEditingController _notesController;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _selectedCattle = widget.selectedCattle;
    
    // Si estamos editando, cargar los datos existentes
    if (widget.recordToEdit != null) {
      final cattle = widget.farm.cattle.firstWhere((c) => c.id == widget.recordToEdit!.cattleId, orElse: () => widget.farm.cattle.first);
      _selectedCattle = cattle;
      _recordDate = widget.recordToEdit!.recordDate;
      _litersController = TextEditingController(text: widget.recordToEdit!.litersProduced.toString());
      _notesController = TextEditingController(text: widget.recordToEdit!.notes ?? '');
    } else {
      _litersController = TextEditingController();
      _notesController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _litersController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _deleteRecord() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Está seguro de eliminar este registro?'),
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

    if (confirm == true && widget.recordToEdit != null) {
      try {
        final farmProvider = Provider.of<FarmProvider>(context, listen: false);
        await farmProvider.deleteMilkProductionRecord(widget.recordToEdit!.id, farmId: widget.farm.id);
        
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registro eliminado exitosamente'),
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
      }
    }
  }

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCattle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una vaca')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final farmProvider = Provider.of<FarmProvider>(context, listen: false);
      
      final record = MilkProduction(
        id: widget.recordToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        cattleId: _selectedCattle!.id,
        farmId: widget.farm.id,
        recordDate: _recordDate,
        litersProduced: double.parse(_litersController.text),
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      if (widget.recordToEdit == null) {
        await farmProvider.addMilkProductionRecord(record, farmId: widget.farm.id);
      } else {
        await farmProvider.updateMilkProductionRecord(record, farmId: widget.farm.id);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.recordToEdit == null
                ? 'Producción de leche registrada exitosamente'
                : 'Registro actualizado exitosamente'),
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
    // Filtrar solo hembras para producción de leche
    final femaleCattle = widget.farm.cattle.where((c) => c.gender == CattleGender.female).toList();

    if (femaleCattle.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('🥛 Registro de Leche'),
          centerTitle: true,
          backgroundColor: widget.farm.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pets, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No hay vacas registradas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Las hembras son necesarias para registrar producción de leche',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recordToEdit == null ? '🥛 Registro de Leche' : '🥛 Editar Registro'),
        centerTitle: true,
        backgroundColor: widget.farm.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (widget.recordToEdit != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteRecord,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Selección de vaca
            DropdownButtonFormField<Cattle>(
              value: _selectedCattle,
              hint: const Text('Selecciona una vaca'),
              decoration: const InputDecoration(
                labelText: 'Vaca *',
                prefixIcon: Icon(Icons.pets),
                border: OutlineInputBorder(),
              ),
              items: femaleCattle.map((cattle) {
                return DropdownMenuItem<Cattle>(
                  value: cattle,
                  child: Text(cattle.name ?? cattle.identification ?? 'Sin ID'),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedCattle = value),
              validator: (value) {
                if (value == null) return 'Selecciona una vaca';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Fecha de registro
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Fecha'),
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

            // Litros producidos
            TextFormField(
              controller: _litersController,
              decoration: const InputDecoration(
                labelText: 'Litros producidos *',
                hintText: 'Cantidad en litros',
                prefixIcon: Icon(Icons.water_drop),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Los litros son requeridos';
                }
                final liters = double.tryParse(value);
                if (liters == null || liters <= 0) {
                  return 'Ingrese una cantidad válida';
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
                hintText: 'Observaciones adicionales',
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
                  : const Text('Guardar Registro', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

