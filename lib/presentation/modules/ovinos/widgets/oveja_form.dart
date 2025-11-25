import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../domain/entities/ovinos/oveja.dart';
import '../../../../presentation/widgets/custom_text_field.dart';
import '../../../../presentation/widgets/custom_date_picker.dart';
import '../../../../presentation/widgets/custom_dropdown.dart';
import '../../../../presentation/widgets/form_section.dart';
import '../../../../core/validators/form_validators.dart';

/// Widget reutilizable para formulario de Oveja
class OvejaForm extends StatefulWidget {
  final Oveja? initialOveja;
  final String farmId;
  final GlobalKey<FormState> formKey;
  final Function(Oveja) onSave;

  const OvejaForm({
    super.key,
    this.initialOveja,
    required this.farmId,
    required this.formKey,
    required this.onSave,
  });

  @override
  State<OvejaForm> createState() => _OvejaFormState();
}

class _OvejaFormState extends State<OvejaForm> {
  late TextEditingController _identificationController;
  late TextEditingController _nameController;
  late TextEditingController _weightController;
  late TextEditingController _notesController;

  DateTime? _birthDate;
  DateTime? _fechaMonta;
  DateTime? _fechaProbableParto;
  OvejaGender _gender = OvejaGender.female;
  EstadoReproductivoOveja? _estadoReproductivo;
  int? _partosPrevios;
  late TextEditingController _partosController;

  @override
  void initState() {
    super.initState();
    final oveja = widget.initialOveja;
    _identificationController = TextEditingController(text: oveja?.identification);
    _nameController = TextEditingController(text: oveja?.name);
    _weightController = TextEditingController(
      text: oveja?.currentWeight?.toStringAsFixed(1),
    );
    _notesController = TextEditingController(text: oveja?.notes);
    _partosController = TextEditingController(
      text: oveja?.partosPrevios?.toString() ?? '',
    );

    if (oveja != null) {
      _birthDate = oveja.birthDate;
      _fechaMonta = oveja.fechaMonta;
      _fechaProbableParto = oveja.fechaProbableParto;
      _gender = oveja.gender;
      _estadoReproductivo = oveja.estadoReproductivo;
      _partosPrevios = oveja.partosPrevios;
    } else {
      _birthDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _identificationController.dispose();
    _nameController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    _partosController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (!widget.formKey.currentState!.validate()) {
      return;
    }

    final oveja = Oveja(
      id: widget.initialOveja?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      farmId: widget.farmId,
      identification: _identificationController.text.trim(),
      name: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
      birthDate: _birthDate!,
      currentWeight: _weightController.text.isNotEmpty
          ? double.tryParse(_weightController.text) ?? 0.0
          : null,
      gender: _gender,
      estadoReproductivo: _estadoReproductivo,
      fechaMonta: _fechaMonta,
      fechaProbableParto: _fechaProbableParto,
      partosPrevios: _partosPrevios,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      createdAt: widget.initialOveja?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    widget.onSave(oveja);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FormSection(
            title: 'Información Básica',
            children: [
              const SizedBox(height: 8),
              CustomTextField(
                label: 'Identificación *',
                controller: _identificationController,
                hint: 'Ej: OV-001',
                validator: (value) {
                  return FormValidators.required(value, fieldName: 'La identificación') ??
                      FormValidators.identification(value);
                },
                prefixIcon: Icons.tag,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Nombre',
                controller: _nameController,
                hint: 'Ej: Oveja 1',
                validator: (value) => FormValidators.name(value),
                prefixIcon: Icons.pets,
              ),
              const SizedBox(height: 16),
              CustomDatePicker(
                label: 'Fecha de Nacimiento *',
                selectedDate: _birthDate ?? DateTime.now(),
                onDateSelected: (date) {
                  setState(() {
                    _birthDate = date;
                  });
                },
                lastDate: DateTime.now(),
                validator: (date) {
                  if (date == null) {
                    return 'La fecha de nacimiento es obligatoria';
                  }
                  return FormValidators.notFuture(date, fieldName: 'La fecha de nacimiento') ??
                      FormValidators.reasonableAge(date, animalType: 'oveja');
                },
              ),
              const SizedBox(height: 16),
              CustomDropdown<OvejaGender>(
                label: 'Género *',
                value: _gender,
                items: OvejaGender.values.map((gender) {
                  return DropdownMenuItem(
                    value: gender,
                    child: Text(gender == OvejaGender.female ? 'Hembra' : 'Macho'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _gender = value;
                    });
                  }
                },
                prefixIcon: Icons.wc,
              ),
            ],
          ),
          FormSection(
            title: 'Peso',
            children: [
              const SizedBox(height: 8),
              CustomTextField(
                label: 'Peso Actual (kg)',
                controller: _weightController,
                hint: 'Ej: 45.5',
                keyboardType: TextInputType.number,
                validator: (value) => FormValidators.animalWeight(
                  value,
                  animalType: 'oveja',
                ),
                prefixIcon: Icons.monitor_weight,
              ),
            ],
          ),
          FormSection(
            title: 'Estado Reproductivo',
            children: [
              const SizedBox(height: 8),
              CustomDropdown<EstadoReproductivoOveja?>(
                label: 'Estado',
                value: _estadoReproductivo,
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('No especificado'),
                  ),
                  ...EstadoReproductivoOveja.values.map((estado) {
                    return DropdownMenuItem(
                      value: estado,
                      child: Text(_getEstadoString(estado)),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _estadoReproductivo = value;
                  });
                },
                prefixIcon: Icons.favorite,
              ),
              const SizedBox(height: 16),
              CustomDatePicker(
                label: 'Fecha de Monta',
                selectedDate: _fechaMonta ?? DateTime.now(),
                onDateSelected: (date) {
                  setState(() {
                    _fechaMonta = date;
                    if (date != null && _estadoReproductivo == null) {
                      _estadoReproductivo = EstadoReproductivoOveja.gestante;
                    }
                  });
                },
                lastDate: DateTime.now(),
              ),
              const SizedBox(height: 16),
              CustomDatePicker(
                label: 'Fecha Probable de Parto',
                selectedDate: _fechaProbableParto ?? DateTime.now(),
                onDateSelected: (date) {
                  setState(() {
                    _fechaProbableParto = date;
                  });
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Partos Previos',
                controller: _partosController,
                hint: 'Ej: 2',
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _partosPrevios = value.isEmpty ? null : int.tryParse(value);
                },
                validator: (value) => FormValidators.positiveInteger(
                  value,
                  fieldName: 'Partos previos',
                ),
                prefixIcon: Icons.numbers,
              ),
            ],
          ),
          FormSection(
            title: 'Notas',
            children: [
              const SizedBox(height: 8),
              CustomTextField(
                label: 'Notas Adicionales',
                controller: _notesController,
                hint: 'Información adicional sobre la oveja...',
                maxLines: 4,
                prefixIcon: Icons.note,
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _handleSave,
            icon: const Icon(Icons.save),
            label: Text(widget.initialOveja == null ? 'Guardar' : 'Guardar Cambios'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  String _getEstadoString(EstadoReproductivoOveja estado) {
    switch (estado) {
      case EstadoReproductivoOveja.vacia:
        return 'Vacía';
      case EstadoReproductivoOveja.gestante:
        return 'Gestante';
      case EstadoReproductivoOveja.lactante:
        return 'Lactante';
    }
  }
}

