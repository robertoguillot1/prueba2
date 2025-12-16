import 'package:flutter/material.dart';
import '../../../../domain/entities/porcinos/cerdo.dart';
import '../../../../presentation/widgets/custom_text_field.dart';
import '../../../../presentation/widgets/custom_date_picker.dart';
import '../../../../presentation/widgets/custom_dropdown.dart';
import '../../../../presentation/widgets/form_section.dart';
import '../../../../core/validators/form_validators.dart';

/// Widget reutilizable para formulario de Cerdo
class CerdoForm extends StatefulWidget {
  final Cerdo? initialCerdo;
  final String farmId;
  final GlobalKey<FormState> formKey;
  final Function(Cerdo) onSave;

  const CerdoForm({
    super.key,
    this.initialCerdo,
    required this.farmId,
    required this.formKey,
    required this.onSave,
  });

  @override
  State<CerdoForm> createState() => _CerdoFormState();
}

class _CerdoFormState extends State<CerdoForm> {
  late TextEditingController _identificationController;
  late TextEditingController _weightController;
  late TextEditingController _notesController;

  DateTime? _birthDate;
  CerdoGender _gender = CerdoGender.female;
  FeedingStage _feedingStage = FeedingStage.inicio;

  @override
  void initState() {
    super.initState();
    final cerdo = widget.initialCerdo;
    _identificationController = TextEditingController(text: cerdo?.identification);
    _weightController = TextEditingController(
      text: cerdo?.currentWeight.toStringAsFixed(1),
    );
    _notesController = TextEditingController(text: cerdo?.notes);

    if (cerdo != null) {
      _birthDate = cerdo.birthDate;
      _gender = cerdo.gender;
      _feedingStage = cerdo.feedingStage;
    } else {
      _birthDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _identificationController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (!widget.formKey.currentState!.validate()) {
      return;
    }

    final cerdo = Cerdo(
      id: widget.initialCerdo?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      farmId: widget.farmId,
      identification: _identificationController.text.trim().isEmpty
          ? null
          : _identificationController.text.trim(),
      gender: _gender,
      birthDate: _birthDate!,
      currentWeight: double.tryParse(_weightController.text) ?? 0.0,
      feedingStage: _feedingStage,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      updatedAt: DateTime.now(),
    );

    widget.onSave(cerdo);
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
                hint: 'Ej: CER-001',
                prefixIcon: Icons.tag,
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
                      FormValidators.reasonableAge(date, animalType: 'cerdo');
                },
              ),
              const SizedBox(height: 16),
              CustomDropdown<CerdoGender>(
                label: 'Género *',
                value: _gender,
                items: CerdoGender.values.map((gender) {
                  return DropdownMenuItem(
                    value: gender,
                    child: Text(gender == CerdoGender.female ? 'Hembra' : 'Macho'),
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
            title: 'Peso y Alimentación',
            children: [
              const SizedBox(height: 8),
              CustomTextField(
                label: 'Peso Actual (kg) *',
                controller: _weightController,
                hint: 'Ej: 25.5',
                keyboardType: TextInputType.number,
                validator: (value) {
                  return FormValidators.required(value, fieldName: 'El peso') ??
                      FormValidators.animalWeight(value, animalType: 'cerdo');
                },
                prefixIcon: Icons.monitor_weight,
              ),
              const SizedBox(height: 16),
              CustomDropdown<FeedingStage>(
                label: 'Etapa de Alimentación *',
                value: _feedingStage,
                items: FeedingStage.values.map((stage) {
                  return DropdownMenuItem(
                    value: stage,
                    child: Text(_getStageString(stage)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _feedingStage = value;
                    });
                  }
                },
                prefixIcon: Icons.restaurant,
              ),
              if (_weightController.text.isNotEmpty && _birthDate != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Consumo Estimado Diario',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _calculateEstimatedConsumption(),
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          FormSection(
            title: 'Notas',
            children: [
              const SizedBox(height: 8),
              CustomTextField(
                label: 'Notas Adicionales',
                controller: _notesController,
                hint: 'Información adicional sobre el cerdo...',
                maxLines: 4,
                prefixIcon: Icons.note,
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _handleSave,
            icon: const Icon(Icons.save),
            label: Text(widget.initialCerdo == null ? 'Guardar' : 'Guardar Cambios'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  String _getStageString(FeedingStage stage) {
    switch (stage) {
      case FeedingStage.inicio:
        return 'Inicio';
      case FeedingStage.levante:
        return 'Levante';
      case FeedingStage.engorde:
        return 'Engorde';
    }
  }

  String _calculateEstimatedConsumption() {
    final weight = double.tryParse(_weightController.text);
    if (weight == null || weight <= 0) return 'Ingrese el peso';
    
    double baseConsumption = weight * 0.04;
    double consumption;
    switch (_feedingStage) {
      case FeedingStage.inicio:
        consumption = baseConsumption * 0.8;
        break;
      case FeedingStage.levante:
        consumption = baseConsumption;
        break;
      case FeedingStage.engorde:
        consumption = baseConsumption * 1.2;
        break;
    }
    
    return '${consumption.toStringAsFixed(2)} kg/día';
  }
}

