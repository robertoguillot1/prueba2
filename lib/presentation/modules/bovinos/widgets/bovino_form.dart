import 'package:flutter/material.dart';
import '../../../../domain/entities/bovinos/bovino.dart';
import '../../../../presentation/widgets/custom_text_field.dart';
import '../../../../presentation/widgets/custom_date_picker.dart';
import '../../../../presentation/widgets/custom_dropdown.dart';
import '../../../../presentation/widgets/form_section.dart';
import '../../../../core/validators/form_validators.dart';
import 'cattle_selector_field.dart';

/// Widget reutilizable para formulario de Bovino
class BovinoForm extends StatefulWidget {
  final Bovino? initialBovino;
  final String farmId;
  final GlobalKey<FormState> formKey;
  final Function(Bovino) onSave;
  final List<Bovino>? availableBovinos; // Lista de bovinos disponibles para selección de padres

  const BovinoForm({
    super.key,
    this.initialBovino,
    required this.farmId,
    required this.formKey,
    required this.onSave,
    this.availableBovinos,
  });

  @override
  State<BovinoForm> createState() => _BovinoFormState();
}

class _BovinoFormState extends State<BovinoForm> {
  late TextEditingController _identificationController;
  late TextEditingController _nameController;
  late TextEditingController _weightController;
  late TextEditingController _razaController;
  late TextEditingController _notesController;
  late TextEditingController _partosController;

  DateTime? _birthDate;
  DateTime? _lastHeatDate;
  DateTime? _inseminationDate;
  DateTime? _expectedCalvingDate;
  BovinoCategory _category = BovinoCategory.vaca;
  BovinoGender _gender = BovinoGender.female;
  ProductionStage _productionStage = ProductionStage.levante;
  HealthStatus _healthStatus = HealthStatus.sano;
  BreedingStatus? _breedingStatus;
  int? _previousCalvings;
  Bovino? _selectedPadre;
  Bovino? _selectedMadre;

  @override
  void initState() {
    super.initState();
    final bovino = widget.initialBovino;
    _identificationController = TextEditingController(text: bovino?.identification);
    _nameController = TextEditingController(text: bovino?.name);
    _weightController = TextEditingController(
      text: bovino?.currentWeight.toStringAsFixed(1),
    );
    _razaController = TextEditingController(text: bovino?.raza);
    _notesController = TextEditingController(text: bovino?.notes);
    _partosController = TextEditingController(
      text: bovino?.previousCalvings?.toString() ?? '',
    );

    if (bovino != null) {
      _birthDate = bovino.birthDate;
      _lastHeatDate = bovino.lastHeatDate;
      _inseminationDate = bovino.inseminationDate;
      _expectedCalvingDate = bovino.expectedCalvingDate;
      _category = bovino.category;
      _gender = bovino.gender;
      _productionStage = bovino.productionStage;
      _healthStatus = bovino.healthStatus;
      _breedingStatus = bovino.breedingStatus;
      _previousCalvings = bovino.previousCalvings;
      
      // Cargar padres si existen (buscarlos en la lista disponible)
      if (widget.availableBovinos != null && widget.availableBovinos!.isNotEmpty) {
        if (bovino.idPadre != null) {
          try {
            _selectedPadre = widget.availableBovinos!
                .firstWhere((b) => b.id == bovino.idPadre);
            // Verificar que no sea el mismo animal
            if (_selectedPadre?.id == bovino.id) {
              _selectedPadre = null;
            }
          } catch (e) {
            // Si no se encuentra en la lista, crear un bovino temporal con los datos guardados
            if (bovino.nombrePadre != null) {
              _selectedPadre = Bovino(
                id: bovino.idPadre!,
                farmId: bovino.farmId,
                identification: bovino.nombrePadre,
                name: bovino.nombrePadre,
                category: BovinoCategory.toro,
                gender: BovinoGender.male,
                currentWeight: 0,
                birthDate: DateTime.now(),
                productionStage: ProductionStage.levante,
                healthStatus: HealthStatus.sano,
              );
            }
          }
        }
        if (bovino.idMadre != null) {
          try {
            _selectedMadre = widget.availableBovinos!
                .firstWhere((b) => b.id == bovino.idMadre);
            // Verificar que no sea el mismo animal
            if (_selectedMadre?.id == bovino.id) {
              _selectedMadre = null;
            }
          } catch (e) {
            // Si no se encuentra en la lista, crear un bovino temporal con los datos guardados
            if (bovino.nombreMadre != null) {
              _selectedMadre = Bovino(
                id: bovino.idMadre!,
                farmId: bovino.farmId,
                identification: bovino.nombreMadre,
                name: bovino.nombreMadre,
                category: BovinoCategory.vaca,
                gender: BovinoGender.female,
                currentWeight: 0,
                birthDate: DateTime.now(),
                productionStage: ProductionStage.levante,
                healthStatus: HealthStatus.sano,
              );
            }
          }
        }
      }
    } else {
      _birthDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _identificationController.dispose();
    _nameController.dispose();
    _weightController.dispose();
    _razaController.dispose();
    _notesController.dispose();
    _partosController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (!widget.formKey.currentState!.validate()) {
      return;
    }

    final bovino = Bovino(
      id: widget.initialBovino?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      farmId: widget.farmId,
      identification: _identificationController.text.trim().isEmpty
          ? null
          : _identificationController.text.trim(),
      name: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
      category: _category,
      gender: _gender,
      currentWeight: double.tryParse(_weightController.text) ?? 0.0,
      birthDate: _birthDate!,
      productionStage: _productionStage,
      healthStatus: _healthStatus,
      breedingStatus: _breedingStatus,
      lastHeatDate: _lastHeatDate,
      inseminationDate: _inseminationDate,
      expectedCalvingDate: _expectedCalvingDate,
      previousCalvings: _partosController.text.isEmpty
          ? null
          : int.tryParse(_partosController.text),
      raza: _razaController.text.trim().isEmpty ? null : _razaController.text.trim(),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      idPadre: _selectedPadre?.id,
      nombrePadre: _selectedPadre?.name ?? _selectedPadre?.identification,
      idMadre: _selectedMadre?.id,
      nombreMadre: _selectedMadre?.name ?? _selectedMadre?.identification,
      createdAt: widget.initialBovino?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    widget.onSave(bovino);
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
                hint: 'Ej: BOV-001',
                prefixIcon: Icons.tag,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Nombre',
                controller: _nameController,
                hint: 'Ej: Vaca 1',
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
              ),
              const SizedBox(height: 16),
              CustomDropdown<BovinoCategory>(
                label: 'Categoría *',
                value: _category,
                items: BovinoCategory.values.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(_getCategoryString(category)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _category = value;
                    });
                  }
                },
                prefixIcon: Icons.category,
              ),
              const SizedBox(height: 16),
              CustomDropdown<BovinoGender>(
                label: 'Género *',
                value: _gender,
                items: BovinoGender.values.map((gender) {
                  return DropdownMenuItem(
                    value: gender,
                    child: Text(gender == BovinoGender.female ? 'Hembra' : 'Macho'),
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
                hint: 'Ej: Holstein',
                prefixIcon: Icons.agriculture,
              ),
            ],
          ),
          // Sección de Genealogía
          if (widget.availableBovinos != null && widget.availableBovinos!.isNotEmpty)
            FormSection(
              title: 'Genealogía (Padres)',
              children: [
                const SizedBox(height: 8),
                Text(
                  'Vincula los padres de este animal si están registrados en el inventario.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 16),
                CattleSelectorField(
                  label: 'Padre (Sire)',
                  hint: 'Selecciona el padre',
                  prefixIcon: Icons.male,
                  selectedBovino: _selectedPadre,
                  availableBovinos: widget.availableBovinos!,
                  sexFilter: SexFilter.male,
                  excludeBovinoId: widget.initialBovino?.id,
                  onSelect: (bovino) {
                    setState(() {
                      _selectedPadre = bovino;
                    });
                  },
                ),
                const SizedBox(height: 16),
                CattleSelectorField(
                  label: 'Madre (Dam)',
                  hint: 'Selecciona la madre',
                  prefixIcon: Icons.female,
                  selectedBovino: _selectedMadre,
                  availableBovinos: widget.availableBovinos!,
                  sexFilter: SexFilter.female,
                  excludeBovinoId: widget.initialBovino?.id,
                  onSelect: (bovino) {
                    setState(() {
                      _selectedMadre = bovino;
                    });
                  },
                ),
              ],
            ),
          FormSection(
            title: 'Peso y Etapa',
            children: [
              const SizedBox(height: 8),
              CustomTextField(
                label: 'Peso Actual (kg) *',
                controller: _weightController,
                hint: 'Ej: 450.5',
                keyboardType: TextInputType.number,
                validator: (value) {
                  return FormValidators.required(value, fieldName: 'El peso') ??
                      FormValidators.animalWeight(value, animalType: 'bovino');
                },
                prefixIcon: Icons.monitor_weight,
              ),
              const SizedBox(height: 16),
              CustomDropdown<ProductionStage>(
                label: 'Etapa de Producción *',
                value: _productionStage,
                items: ProductionStage.values.map((stage) {
                  return DropdownMenuItem(
                    value: stage,
                    child: Text(_getProductionStageString(stage)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _productionStage = value;
                    });
                  }
                },
                prefixIcon: Icons.timeline,
              ),
            ],
          ),
          FormSection(
            title: 'Salud',
            children: [
              const SizedBox(height: 8),
              CustomDropdown<HealthStatus>(
                label: 'Estado de Salud *',
                value: _healthStatus,
                items: HealthStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(_getHealthString(status)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _healthStatus = value;
                    });
                  }
                },
                prefixIcon: Icons.health_and_safety,
              ),
            ],
          ),
          FormSection(
            title: 'Estado Reproductivo',
            children: [
              const SizedBox(height: 8),
              CustomDropdown<BreedingStatus?>(
                label: 'Estado',
                value: _breedingStatus,
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('No especificado'),
                  ),
                  ...BreedingStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(_getBreedingStatusString(status)),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _breedingStatus = value;
                  });
                },
                prefixIcon: Icons.favorite,
              ),
              const SizedBox(height: 16),
              CustomDatePicker(
                label: 'Última Fecha de Celo',
                selectedDate: _lastHeatDate ?? DateTime.now(),
                onDateSelected: (date) {
                  setState(() {
                    _lastHeatDate = date;
                  });
                },
                lastDate: DateTime.now(),
              ),
              const SizedBox(height: 16),
              CustomDatePicker(
                label: 'Fecha de Inseminación',
                selectedDate: _inseminationDate ?? DateTime.now(),
                onDateSelected: (date) {
                  setState(() {
                    _inseminationDate = date;
                    if (date != null && _breedingStatus == null) {
                      _breedingStatus = BreedingStatus.prenada;
                    }
                  });
                },
                lastDate: DateTime.now(),
              ),
              const SizedBox(height: 16),
              CustomDatePicker(
                label: 'Fecha Esperada de Parto',
                selectedDate: _expectedCalvingDate ?? DateTime.now(),
                onDateSelected: (date) {
                  setState(() {
                    _expectedCalvingDate = date;
                  });
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Partos Previos',
                controller: _partosController,
                hint: 'Ej: 3',
                keyboardType: TextInputType.number,
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
                hint: 'Información adicional sobre el bovino...',
                maxLines: 4,
                prefixIcon: Icons.note,
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _handleSave,
            icon: const Icon(Icons.save),
            label: Text(widget.initialBovino == null ? 'Guardar' : 'Guardar Cambios'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryString(BovinoCategory category) {
    switch (category) {
      case BovinoCategory.vaca:
        return 'Vaca';
      case BovinoCategory.toro:
        return 'Toro';
      case BovinoCategory.ternero:
        return 'Ternero';
      case BovinoCategory.novilla:
        return 'Novilla';
    }
  }

  String _getProductionStageString(ProductionStage stage) {
    switch (stage) {
      case ProductionStage.levante:
        return 'Levante';
      case ProductionStage.desarrollo:
        return 'Desarrollo';
      case ProductionStage.produccion:
        return 'Producción';
      case ProductionStage.descarte:
        return 'Descarte';
    }
  }

  String _getHealthString(HealthStatus status) {
    switch (status) {
      case HealthStatus.sano:
        return 'Sano';
      case HealthStatus.enfermo:
        return 'Enfermo';
      case HealthStatus.tratamiento:
        return 'En Tratamiento';
    }
  }

  String _getBreedingStatusString(BreedingStatus status) {
    switch (status) {
      case BreedingStatus.vacia:
        return 'Vacía';
      case BreedingStatus.enCelo:
        return 'En Celo';
      case BreedingStatus.prenada:
        return 'Prenada';
      case BreedingStatus.lactante:
        return 'Lactante';
      case BreedingStatus.seca:
        return 'Seca';
    }
  }
}

