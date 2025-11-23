import 'package:flutter/material.dart';
import '../../../../domain/entities/avicultura/gallina.dart';
import '../../../../presentation/widgets/custom_text_field.dart';
import '../../../../presentation/widgets/custom_date_picker.dart';
import '../../../../presentation/widgets/custom_dropdown.dart';
import '../../../../presentation/widgets/form_section.dart';
import '../../../../core/validators/form_validators.dart';

/// Widget reutilizable para formulario de Gallina
class GallinaForm extends StatefulWidget {
  final Gallina? initialGallina;
  final String farmId;
  final GlobalKey<FormState> formKey;
  final Function(Gallina) onSave;

  const GallinaForm({
    super.key,
    this.initialGallina,
    required this.farmId,
    required this.formKey,
    required this.onSave,
  });

  @override
  State<GallinaForm> createState() => _GallinaFormState();
}

class _GallinaFormState extends State<GallinaForm> {
  late TextEditingController _identificationController;
  late TextEditingController _nameController;
  late TextEditingController _razaController;
  late TextEditingController _loteIdController;
  late TextEditingController _notesController;

  DateTime? _fechaNacimiento;
  DateTime? _fechaIngresoLote;
  GallinaGender _gender = GallinaGender.female;
  EstadoGallina _estado = EstadoGallina.activa;

  @override
  void initState() {
    super.initState();
    final gallina = widget.initialGallina;
    _identificationController = TextEditingController(text: gallina?.identification);
    _nameController = TextEditingController(text: gallina?.name);
    _razaController = TextEditingController(text: gallina?.raza);
    _loteIdController = TextEditingController(text: gallina?.loteId);
    _notesController = TextEditingController(text: gallina?.notes);

    if (gallina != null) {
      _fechaNacimiento = gallina.fechaNacimiento;
      _fechaIngresoLote = gallina.fechaIngresoLote;
      _gender = gallina.gender;
      _estado = gallina.estado;
    } else {
      _fechaNacimiento = DateTime.now();
    }
  }

  @override
  void dispose() {
    _identificationController.dispose();
    _nameController.dispose();
    _razaController.dispose();
    _loteIdController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (!widget.formKey.currentState!.validate()) {
      return;
    }

    final gallina = Gallina(
      id: widget.initialGallina?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      farmId: widget.farmId,
      identification: _identificationController.text.trim().isEmpty
          ? null
          : _identificationController.text.trim(),
      name: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
      fechaNacimiento: _fechaNacimiento!,
      raza: _razaController.text.trim().isEmpty ? null : _razaController.text.trim(),
      gender: _gender,
      estado: _estado,
      fechaIngresoLote: _fechaIngresoLote,
      loteId: _loteIdController.text.trim().isEmpty ? null : _loteIdController.text.trim(),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      createdAt: widget.initialGallina?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    widget.onSave(gallina);
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
                label: 'Identificación',
                controller: _identificationController,
                hint: 'Ej: GAL-001',
                prefixIcon: Icons.tag,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Nombre',
                controller: _nameController,
                hint: 'Ej: Gallina 1',
                prefixIcon: Icons.pets,
              ),
              const SizedBox(height: 16),
              CustomDatePicker(
                label: 'Fecha de Nacimiento *',
                selectedDate: _fechaNacimiento ?? DateTime.now(),
                onDateSelected: (date) {
                  setState(() {
                    _fechaNacimiento = date;
                  });
                },
                lastDate: DateTime.now(),
                validator: (date) {
                  if (date == null) {
                    return 'La fecha de nacimiento es obligatoria';
                  }
                  return FormValidators.notFuture(date, fieldName: 'La fecha de nacimiento') ??
                      FormValidators.reasonableAge(date, animalType: 'gallina');
                },
              ),
              const SizedBox(height: 16),
              CustomDropdown<GallinaGender>(
                label: 'Género *',
                value: _gender,
                items: GallinaGender.values.map((gender) {
                  return DropdownMenuItem(
                    value: gender,
                    child: Text(gender == GallinaGender.female ? 'Hembra' : 'Macho'),
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
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Raza',
                controller: _razaController,
                hint: 'Ej: Leghorn',
                prefixIcon: Icons.agriculture,
              ),
            ],
          ),
          FormSection(
            title: 'Estado',
            children: [
              const SizedBox(height: 8),
              CustomDropdown<EstadoGallina>(
                label: 'Estado *',
                value: _estado,
                items: EstadoGallina.values.map((estado) {
                  return DropdownMenuItem(
                    value: estado,
                    child: Text(_getEstadoString(estado)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _estado = value;
                    });
                  }
                },
                prefixIcon: Icons.health_and_safety,
              ),
            ],
          ),
          FormSection(
            title: 'Lote',
            children: [
              const SizedBox(height: 8),
              CustomTextField(
                label: 'ID del Lote',
                controller: _loteIdController,
                hint: 'Ej: LOTE-001',
                prefixIcon: Icons.group,
              ),
              const SizedBox(height: 16),
              CustomDatePicker(
                label: 'Fecha de Ingreso al Lote',
                selectedDate: _fechaIngresoLote ?? DateTime.now(),
                onDateSelected: (date) {
                  setState(() {
                    _fechaIngresoLote = date;
                  });
                },
                lastDate: DateTime.now(),
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
                hint: 'Información adicional sobre la gallina...',
                maxLines: 4,
                prefixIcon: Icons.note,
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _handleSave,
            icon: const Icon(Icons.save),
            label: Text(widget.initialGallina == null ? 'Guardar' : 'Guardar Cambios'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  String _getEstadoString(EstadoGallina estado) {
    switch (estado) {
      case EstadoGallina.activa:
        return 'Activa';
      case EstadoGallina.enferma:
        return 'Enferma';
      case EstadoGallina.muerta:
        return 'Muerta';
      case EstadoGallina.descartada:
        return 'Descartada';
    }
  }
}

