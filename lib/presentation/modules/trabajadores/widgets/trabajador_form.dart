import 'package:flutter/material.dart';
import '../../../../domain/entities/trabajadores/trabajador.dart';
import '../../../../presentation/widgets/custom_text_field.dart';
import '../../../../presentation/widgets/custom_date_picker.dart';
import '../../../../presentation/widgets/custom_dropdown.dart';
import '../../../../presentation/widgets/form_section.dart';
import '../../../../core/validators/form_validators.dart';

/// Widget reutilizable para formulario de Trabajador
class TrabajadorForm extends StatefulWidget {
  final Trabajador? initialTrabajador;
  final String farmId;
  final GlobalKey<FormState> formKey;
  final Function(Trabajador) onSave;

  const TrabajadorForm({
    super.key,
    this.initialTrabajador,
    required this.farmId,
    required this.formKey,
    required this.onSave,
  });

  @override
  State<TrabajadorForm> createState() => _TrabajadorFormState();
}

class _TrabajadorFormState extends State<TrabajadorForm> {
  late TextEditingController _fullNameController;
  late TextEditingController _identificationController;
  late TextEditingController _positionController;
  late TextEditingController _salaryController;
  late TextEditingController _laborDescriptionController;

  DateTime? _startDate;
  WorkerType _workerType = WorkerType.fijo;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final trabajador = widget.initialTrabajador;
    _fullNameController = TextEditingController(text: trabajador?.fullName);
    _identificationController = TextEditingController(text: trabajador?.identification);
    _positionController = TextEditingController(text: trabajador?.position);
    _salaryController = TextEditingController(
      text: trabajador?.salary.toStringAsFixed(0),
    );
    _laborDescriptionController = TextEditingController(
      text: trabajador?.laborDescription,
    );

    if (trabajador != null) {
      _startDate = trabajador.startDate;
      _workerType = trabajador.workerType;
      _isActive = trabajador.isActive;
    } else {
      _startDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _identificationController.dispose();
    _positionController.dispose();
    _salaryController.dispose();
    _laborDescriptionController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (!widget.formKey.currentState!.validate()) {
      return;
    }

    final trabajador = Trabajador(
      id: widget.initialTrabajador?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      farmId: widget.farmId,
      fullName: _fullNameController.text.trim(),
      identification: _identificationController.text.trim(),
      position: _positionController.text.trim(),
      salary: double.tryParse(_salaryController.text) ?? 0.0,
      startDate: _startDate!,
      isActive: _isActive,
      workerType: _workerType,
      laborDescription: _workerType == WorkerType.porLabor
          ? (_laborDescriptionController.text.trim().isEmpty
              ? null
              : _laborDescriptionController.text.trim())
          : null,
      createdAt: widget.initialTrabajador?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    widget.onSave(trabajador);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FormSection(
            title: 'Información Personal',
            children: [
              const SizedBox(height: 8),
              CustomTextField(
                label: 'Nombre Completo *',
                controller: _fullNameController,
                hint: 'Ej: Juan Pérez',
                validator: (value) {
                  return FormValidators.required(value, fieldName: 'El nombre') ??
                      FormValidators.name(value, fieldName: 'El nombre');
                },
                prefixIcon: Icons.person,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Identificación *',
                controller: _identificationController,
                hint: 'Ej: 1234567890',
                validator: (value) {
                  return FormValidators.required(value, fieldName: 'La identificación') ??
                      FormValidators.minLength(value, 7, fieldName: 'La identificación');
                },
                prefixIcon: Icons.badge,
              ),
            ],
          ),
          FormSection(
            title: 'Información Laboral',
            children: [
              const SizedBox(height: 8),
              CustomTextField(
                label: 'Cargo *',
                controller: _positionController,
                hint: 'Ej: Ordeñador, Veterinario, etc.',
                validator: (value) => FormValidators.required(
                  value,
                  fieldName: 'El cargo',
                ),
                prefixIcon: Icons.work,
              ),
              const SizedBox(height: 16),
              CustomDropdown<WorkerType>(
                label: 'Tipo de Trabajador *',
                value: _workerType,
                items: WorkerType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type == WorkerType.fijo ? 'Fijo' : 'Por Labor'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _workerType = value;
                    });
                  }
                },
                prefixIcon: Icons.category,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Salario *',
                controller: _salaryController,
                hint: 'Ej: 1000000',
                keyboardType: TextInputType.number,
                validator: (value) {
                  return FormValidators.required(value, fieldName: 'El salario') ??
                      FormValidators.positiveNumber(value, fieldName: 'El salario');
                },
                prefixIcon: Icons.attach_money,
              ),
              const SizedBox(height: 16),
              CustomDatePicker(
                label: 'Fecha de Contratación *',
                selectedDate: _startDate ?? DateTime.now(),
                onDateSelected: (date) {
                  setState(() {
                    _startDate = date;
                  });
                },
                lastDate: DateTime.now(),
                validator: (date) {
                  if (date == null) {
                    return 'La fecha de contratación es obligatoria';
                  }
                  return FormValidators.notFuture(date, fieldName: 'La fecha de contratación');
                },
              ),
              if (_workerType == WorkerType.porLabor) ...[
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Descripción de Labor *',
                  controller: _laborDescriptionController,
                  hint: 'Ej: Ordeño diario, Alimentación, etc.',
                  maxLines: 3,
                  validator: (value) {
                    if (_workerType == WorkerType.porLabor) {
                      return FormValidators.required(
                        value,
                        fieldName: 'La descripción de labor',
                      );
                    }
                    return null;
                  },
                  prefixIcon: Icons.description,
                ),
              ],
            ],
          ),
          FormSection(
            title: 'Estado',
            children: [
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Trabajador Activo'),
                subtitle: Text(_isActive ? 'Actualmente activo' : 'Inactivo'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
                secondary: Icon(
                  _isActive ? Icons.check_circle : Icons.cancel,
                  color: _isActive ? Colors.green : Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _handleSave,
            icon: const Icon(Icons.save),
            label: Text(widget.initialTrabajador == null ? 'Guardar' : 'Guardar Cambios'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}

