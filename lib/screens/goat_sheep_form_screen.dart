import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';
import '../models/goat_sheep.dart';

class GoatSheepFormScreen extends StatefulWidget {
  final Farm farm;
  final GoatSheep? animalToEdit;

  const GoatSheepFormScreen({
    super.key,
    required this.farm,
    this.animalToEdit,
  });

  @override
  State<GoatSheepFormScreen> createState() => _GoatSheepFormScreenState();
}

class _GoatSheepFormScreenState extends State<GoatSheepFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _identificationController;
  late TextEditingController _nameController;
  late GoatSheepType _type;
  late GoatSheepGender _gender;
  DateTime? _birthDate;
  TextEditingController? _weightController;
  EstadoReproductivo? _estadoReproductivo;
  DateTime? _fechaMonta;
  DateTime? _fechaProbableParto;
  late TextEditingController _partosPreviosController;
  late TextEditingController _notesController;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _identificationController = TextEditingController(
      text: widget.animalToEdit?.identification ?? '',
    );
    _nameController = TextEditingController(
      text: widget.animalToEdit?.name ?? '',
    );
    _type = widget.animalToEdit?.type ?? GoatSheepType.oveja;
    _gender = widget.animalToEdit?.gender ?? GoatSheepGender.female;
    _birthDate = widget.animalToEdit?.birthDate;
    _weightController = TextEditingController(
      text: widget.animalToEdit?.currentWeight?.toString() ?? '',
    );
    _estadoReproductivo = widget.animalToEdit?.estadoReproductivo;
    _fechaMonta = widget.animalToEdit?.fechaMonta;
    _fechaProbableParto = widget.animalToEdit?.fechaProbableParto;
    _partosPreviosController = TextEditingController(
      text: widget.animalToEdit?.partosPrevios?.toString() ?? '',
    );
    _notesController = TextEditingController(
      text: widget.animalToEdit?.notes ?? '',
    );
    
    // Si hay fecha de monta pero no fecha probable de parto, calcularla
    if (_fechaMonta != null && _fechaProbableParto == null) {
      _fechaProbableParto = _fechaMonta!.add(const Duration(days: 150));
    }
  }

  @override
  void dispose() {
    _identificationController.dispose();
    _nameController.dispose();
    _weightController?.dispose();
    _partosPreviosController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _calculateFechaProbableParto() {
    if (_fechaMonta != null) {
      setState(() {
        _fechaProbableParto = _fechaMonta!.add(const Duration(days: 150));
      });
    }
  }

  Future<void> _saveAnimal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    try {
      final farmProvider = Provider.of<FarmProvider>(context, listen: false);
      final animalId = widget.animalToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
      
      final animal = GoatSheep(
        id: animalId,
        farmId: widget.farm.id,
        type: _type,
        gender: _gender,
        identification: _identificationController.text.isEmpty ? null : _identificationController.text,
        name: _nameController.text.isEmpty ? null : _nameController.text,
        birthDate: _birthDate ?? DateTime.now(),
        currentWeight: _weightController?.text.isEmpty ?? true
            ? null
            : double.tryParse(_weightController!.text),
        estadoReproductivo: _gender == GoatSheepGender.female ? _estadoReproductivo : null,
        fechaMonta: _gender == GoatSheepGender.female && _estadoReproductivo == EstadoReproductivo.gestante
            ? _fechaMonta
            : null,
        fechaProbableParto: _gender == GoatSheepGender.female && _estadoReproductivo == EstadoReproductivo.gestante
            ? _fechaProbableParto
            : null,
        partosPrevios: _partosPreviosController.text.isEmpty
            ? null
            : int.tryParse(_partosPreviosController.text),
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        createdAt: widget.animalToEdit?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.animalToEdit == null) {
        await farmProvider.addGoatSheep(animal, farmId: widget.farm.id);
      } else {
        await farmProvider.updateGoatSheep(animal, farmId: widget.farm.id);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.animalToEdit == null
                ? 'Animal agregado exitosamente'
                : 'Animal actualizado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar el animal: $e'),
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

  Future<void> _deleteAnimal() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Animal'),
        content: const Text('¿Está seguro de que desea eliminar este animal?'),
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

    if (confirm == true && widget.animalToEdit != null) {
      setState(() => _isProcessing = true);
      try {
        final farmProvider = Provider.of<FarmProvider>(context, listen: false);
        await farmProvider.deleteGoatSheep(widget.animalToEdit!.id, farmId: widget.farm.id);
        
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Animal eliminado exitosamente'),
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
    final isFemale = _gender == GoatSheepGender.female;
    final isGestante = _estadoReproductivo == EstadoReproductivo.gestante;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.animalToEdit == null ? 'Nuevo Animal' : 'Editar Animal'),
        backgroundColor: widget.farm.primaryColor,
        foregroundColor: Colors.white,
        actions: widget.animalToEdit != null
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _isProcessing ? null : _deleteAnimal,
                ),
              ]
            : null,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Tipo
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tipo'),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<GoatSheepType>(
                            title: const Text('Chivo'),
                            value: GoatSheepType.chivo,
                            groupValue: _type,
                            onChanged: (value) => setState(() => _type = value!),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<GoatSheepType>(
                            title: const Text('Oveja'),
                            value: GoatSheepType.oveja,
                            groupValue: _type,
                            onChanged: (value) => setState(() => _type = value!),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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
                          child: RadioListTile<GoatSheepGender>(
                            title: const Text('Macho'),
                            value: GoatSheepGender.male,
                            groupValue: _gender,
                            onChanged: (value) {
                              setState(() {
                                _gender = value!;
                                if (_gender == GoatSheepGender.male) {
                                  _estadoReproductivo = null;
                                  _fechaMonta = null;
                                  _fechaProbableParto = null;
                                }
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<GoatSheepGender>(
                            title: const Text('Hembra'),
                            value: GoatSheepGender.female,
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

            // Identificación
            TextFormField(
              controller: _identificationController,
              decoration: const InputDecoration(
                labelText: 'ID o Identificación (opcional)',
                hintText: 'Identificación única del animal',
                prefixIcon: Icon(Icons.credit_card),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Nombre
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre o Alias (opcional)',
                hintText: 'Nombre del animal',
                prefixIcon: Icon(Icons.label),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Fecha de nacimiento
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Fecha de nacimiento *'),
                subtitle: Text(
                  _birthDate != null
                      ? DateFormat('dd/MM/yyyy').format(_birthDate!)
                      : 'Seleccionar fecha',
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
                    firstDate: DateTime(2010),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => _birthDate = date);
                  }
                },
              ),
            ),
            const SizedBox(height: 16),

            // Peso actual (opcional)
            TextFormField(
              controller: _weightController,
              decoration: const InputDecoration(
                labelText: 'Peso actual (kg) - Opcional',
                hintText: 'Ingrese el peso',
                prefixIcon: Icon(Icons.monitor_weight),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final weight = double.tryParse(value);
                  if (weight == null || weight <= 0) {
                    return 'Ingrese un peso válido';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Estado reproductivo (solo para hembras)
            if (isFemale) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Estado Reproductivo'),
                      RadioListTile<EstadoReproductivo?>(
                        title: const Text('Vacía'),
                        value: EstadoReproductivo.vacia,
                        groupValue: _estadoReproductivo,
                        onChanged: (value) {
                          setState(() {
                            _estadoReproductivo = value;
                            if (value != EstadoReproductivo.gestante) {
                              _fechaMonta = null;
                              _fechaProbableParto = null;
                            }
                          });
                        },
                      ),
                      RadioListTile<EstadoReproductivo?>(
                        title: const Text('Gestante'),
                        value: EstadoReproductivo.gestante,
                        groupValue: _estadoReproductivo,
                        onChanged: (value) {
                          setState(() {
                            _estadoReproductivo = value;
                            if (value == EstadoReproductivo.gestante && _fechaMonta == null) {
                              _fechaMonta = DateTime.now();
                              _fechaProbableParto = _fechaMonta!.add(const Duration(days: 150));
                            }
                          });
                        },
                      ),
                      RadioListTile<EstadoReproductivo?>(
                        title: const Text('Lactante'),
                        value: EstadoReproductivo.lactante,
                        groupValue: _estadoReproductivo,
                        onChanged: (value) {
                          setState(() {
                            _estadoReproductivo = value;
                            if (value != EstadoReproductivo.gestante) {
                              _fechaMonta = null;
                              _fechaProbableParto = null;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Fecha de monta (solo para gestantes)
              if (isGestante) ...[
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Fecha de Monta'),
                    subtitle: Text(
                      _fechaMonta != null
                          ? DateFormat('dd/MM/yyyy').format(_fechaMonta!)
                          : 'Seleccionar fecha',
                    ),
                    trailing: _fechaMonta != null
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _fechaMonta = null;
                                _fechaProbableParto = null;
                              });
                            },
                          )
                        : null,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _fechaMonta ?? DateTime.now(),
                        firstDate: DateTime(2010),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          _fechaMonta = date;
                          _fechaProbableParto = date.add(const Duration(days: 150));
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Fecha probable de parto (calculada automáticamente)
                if (_fechaProbableParto != null)
                  Card(
                    color: Colors.blue[50],
                    child: ListTile(
                      leading: Icon(Icons.pregnant_woman, color: Colors.blue[700]),
                      title: const Text('Fecha Probable de Parto'),
                      subtitle: Text(
                        DateFormat('dd/MM/yyyy').format(_fechaProbableParto!),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                      trailing: Text(
                        _fechaProbableParto!.difference(DateTime.now()).inDays >= 0
                            ? '${_fechaProbableParto!.difference(DateTime.now()).inDays} días'
                            : 'Pasado',
                        style: TextStyle(
                          color: _fechaProbableParto!.difference(DateTime.now()).inDays >= 0 &&
                                  _fechaProbableParto!.difference(DateTime.now()).inDays <= 10
                              ? Colors.orange[700]
                              : _fechaProbableParto!.difference(DateTime.now()).inDays < 0
                                  ? Colors.red[700]
                                  : Colors.blue[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
              ],

              // Partos previos
              TextFormField(
                controller: _partosPreviosController,
                decoration: const InputDecoration(
                  labelText: 'Partos Previos (opcional)',
                  hintText: 'Número de partos anteriores',
                  prefixIcon: Icon(Icons.numbers),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final partos = int.tryParse(value);
                    if (partos == null || partos < 0) {
                      return 'Ingrese un número válido';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
            ],

            // Observaciones
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Observaciones (opcional)',
                hintText: 'Notas adicionales sobre el animal',
                prefixIcon: Icon(Icons.note),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Botón guardar
            ElevatedButton(
              onPressed: _isProcessing ? null : _saveAnimal,
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
                  : const Text(
                      'Guardar',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

