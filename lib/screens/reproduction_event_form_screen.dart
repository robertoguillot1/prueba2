import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';
import '../models/cattle.dart';
import '../models/reproduction_event.dart';
import '../utils/constants.dart';

class ReproductionEventFormScreen extends StatefulWidget {
  final Farm farm;
  final Cattle cattle;
  final ReproductionEventType eventType;

  const ReproductionEventFormScreen({
    super.key,
    required this.farm,
    required this.cattle,
    required this.eventType,
  });

  @override
  State<ReproductionEventFormScreen> createState() => _ReproductionEventFormScreenState();
}

class _ReproductionEventFormScreenState extends State<ReproductionEventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  DateTime _eventDate = DateTime.now();
  Cattle? _father;
  Cattle? _selectedChild; // Hijo existente a vincular
  bool _calfBorn = true;
  CattleGender? _calfGender;
  late TextEditingController _calfWeightController;
  late TextEditingController _notesController;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _calfWeightController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _calfWeightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Solo fecundación requiere padre (parto es opcional por inseminación)
    if (widget.eventType == ReproductionEventType.insemination) {
      if (_father == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecciona el padre')),
        );
        return;
      }
    }

    setState(() => _isProcessing = true);

    try {
      final farmProvider = Provider.of<FarmProvider>(context, listen: false);
      final eventId = DateTime.now().millisecondsSinceEpoch.toString();
      
      final event = ReproductionEvent(
        id: eventId,
        cattleId: widget.cattle.id,
        farmId: widget.farm.id,
        eventType: widget.eventType,
        eventDate: _eventDate,
        fatherId: _father?.id,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        calfBorn: widget.eventType == ReproductionEventType.calving ? _calfBorn : null,
        calfGender: _calfBorn && _calfGender != null ? _calfGender.toString() : null,
        calfWeight: _calfBorn && _calfWeightController.text.isNotEmpty 
            ? double.tryParse(_calfWeightController.text) 
            : null,
        relatedCattleId: widget.eventType == ReproductionEventType.calving && _selectedChild != null
            ? _selectedChild!.id
            : null,
      );

      await farmProvider.addReproductionEvent(event, farmId: widget.farm.id);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Evento registrado exitosamente'),
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
        title: Text(widget.eventType.eventTypeString),
        centerTitle: true,
        backgroundColor: widget.farm.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Fecha
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Fecha'),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(_eventDate)),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _eventDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => _eventDate = date);
                  }
                },
              ),
            ),
            const SizedBox(height: 16),

            // Padre (solo para fecundación y parto)
            if (widget.eventType == ReproductionEventType.insemination || 
                widget.eventType == ReproductionEventType.calving)
              DropdownButtonFormField<Cattle>(
                value: _father,
                decoration: InputDecoration(
                  labelText: widget.eventType == ReproductionEventType.calving 
                      ? 'Padre (opcional)' 
                      : 'Padre *',
                  hintText: widget.eventType == ReproductionEventType.calving
                      ? 'Selecciona el padre (opcional si fue por inseminación)'
                      : 'Selecciona el padre',
                  prefixIcon: const Icon(Icons.male),
                  border: const OutlineInputBorder(),
                ),
                items: [
                  // Opción para dejar en blanco (solo para parto)
                  if (widget.eventType == ReproductionEventType.calving)
                    const DropdownMenuItem<Cattle>(
                      value: null,
                      child: Text('Sin padre (inseminación artificial)'),
                    ),
                  ...widget.farm.cattle
                      .where((c) => c.gender == CattleGender.male)
                      .fold<Map<String, Cattle>>({}, (map, cow) {
                        map[cow.id] = cow;
                        return map;
                      })
                      .values
                      .toList()
                      .map((cow) {
                    return DropdownMenuItem<Cattle>(
                      value: cow,
                      child: Text(cow.name ?? cow.identification ?? 'Sin ID'),
                    );
                  }).toList(),
                ],
                onChanged: (value) => setState(() => _father = value),
                validator: (value) {
                  // Solo fecundación requiere padre obligatorio
                  if (widget.eventType == ReproductionEventType.insemination && 
                      value == null) {
                    return 'Selecciona el padre';
                  }
                  return null;
                },
              ),

            // Parto: ¿Nació cría?
            if (widget.eventType == ReproductionEventType.calving) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('¿Nació cría?', style: TextStyle(fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<bool>(
                              title: const Text('Sí'),
                              value: true,
                              groupValue: _calfBorn,
                              onChanged: (value) => setState(() => _calfBorn = value!),
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<bool>(
                              title: const Text('No'),
                              value: false,
                              groupValue: _calfBorn,
                              onChanged: (value) => setState(() => _calfBorn = value!),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Si nació cría, preguntar género y peso
            if (widget.eventType == ReproductionEventType.calving && _calfBorn) ...[
              const SizedBox(height: 16),
              
              // Vincular hijo existente (opcional)
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.link, color: Colors.blue.shade700, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Vincular Hijo Existente',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Si el hijo ya está registrado, puedes vincularlo directamente.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<Cattle>(
                        value: _selectedChild,
                        decoration: const InputDecoration(
                          labelText: 'Hijo existente (opcional)',
                          hintText: 'Buscar y seleccionar el hijo',
                          prefixIcon: Icon(Icons.child_care),
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: [
                          const DropdownMenuItem<Cattle>(
                            value: null,
                            child: Text('No vincular hijo'),
                          ),
                          ..._getPotentialChildren().map((child) {
                            return DropdownMenuItem<Cattle>(
                              value: child,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    child.name ?? child.identification ?? 'Sin ID',
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    'Nació: ${DateFormat('dd/MM/yyyy').format(child.birthDate)} - ${child.genderString}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedChild = value;
                            // Si se selecciona un hijo, auto-completar datos
                            if (value != null) {
                              _calfGender = value.gender;
                              // Actualizar fecha del parto con la fecha de nacimiento del hijo
                              _eventDate = value.birthDate;
                              if (value.currentWeight > 0) {
                                _calfWeightController.text = value.currentWeight.toStringAsFixed(1);
                              }
                            } else {
                              // Si se deselecciona, limpiar campos
                              _calfGender = null;
                              _calfWeightController.clear();
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Género de la cría'),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<CattleGender>(
                              title: const Text('Macho'),
                              value: CattleGender.male,
                              groupValue: _calfGender,
                              onChanged: _selectedChild == null
                                  ? (value) => setState(() => _calfGender = value)
                                  : null, // Deshabilitado si hay hijo vinculado
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<CattleGender>(
                              title: const Text('Hembra'),
                              value: CattleGender.female,
                              groupValue: _calfGender,
                              onChanged: _selectedChild == null
                                  ? (value) => setState(() => _calfGender = value)
                                  : null, // Deshabilitado si hay hijo vinculado
                            ),
                          ),
                        ],
                      ),
                      if (_selectedChild != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'El género se tomó del hijo vinculado',
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _calfWeightController,
                decoration: InputDecoration(
                  labelText: 'Peso de la cría (kg)',
                  hintText: _selectedChild != null 
                      ? 'Peso del hijo vinculado: ${_selectedChild!.currentWeight.toStringAsFixed(1)} kg'
                      : 'Peso al nacer',
                  prefixIcon: const Icon(Icons.monitor_weight),
                  border: const OutlineInputBorder(),
                  filled: _selectedChild != null,
                  fillColor: _selectedChild != null ? Colors.blue.shade50 : null,
                ),
                keyboardType: TextInputType.number,
                enabled: _selectedChild == null, // Deshabilitado si hay hijo vinculado
              ),
              if (_selectedChild != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 16.0),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
                      const SizedBox(width: 4),
                      Text(
                        'Puedes editar el peso del hijo en su perfil',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],

            const SizedBox(height: 16),

            // Notas
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notas (opcional)',
                hintText: 'Observaciones',
                prefixIcon: Icon(Icons.note),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Botón de guardar
            ElevatedButton(
              onPressed: _isProcessing ? null : _saveEvent,
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

  /// Obtiene los animales que podrían ser hijos de esta vaca
  /// Basado en la fecha de nacimiento cercana a la fecha del parto
  List<Cattle> _getPotentialChildren() {
    // Filtrar animales que no sean la misma vaca
    final candidates = widget.farm.cattle
        .where((cow) => 
            cow.id != widget.cattle.id && // No puede ser la misma vaca
            (cow.birthDate.difference(_eventDate).inDays).abs() <= 
                (AppConstants.childBirthDateToleranceDays * 4)) // Amplio rango para búsqueda
        .toList();

    // Ordenar por cercanía a la fecha del parto
    candidates.sort((a, b) {
      final diffA = (a.birthDate.difference(_eventDate).inDays).abs();
      final diffB = (b.birthDate.difference(_eventDate).inDays).abs();
      return diffA.compareTo(diffB);
    });

    return candidates;
  }
}

extension ReproductionEventTypeExtension on ReproductionEventType {
  String get eventTypeString {
    switch (this) {
      case ReproductionEventType.heat:
        return 'Celo';
      case ReproductionEventType.insemination:
        return 'Fecundación';
      case ReproductionEventType.calving:
        return 'Parto';
      case ReproductionEventType.pregnancy:
        return 'Chequeo';
      case ReproductionEventType.abortion:
        return 'Aborto';
    }
  }
}


