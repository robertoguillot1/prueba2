import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../features/cattle/domain/entities/bovine_entity.dart';
import '../../../../features/cattle/domain/usecases/get_cattle_list.dart';
import '../../../../core/di/dependency_injection.dart' as di;
import '../cubits/form/bovino_form_cubit.dart';
import '../cubits/form/bovino_form_state.dart';
import '../widgets/bovine_selector_field.dart';

/// Pantalla de formulario para crear o editar un Bovino
class BovinoFormScreen extends StatelessWidget {
  final BovineEntity? bovine; // null = crear, no null = editar
  final String farmId;
  final String? initialMotherId; // Pre-llenar madre (para crías desde parto)
  final DateTime? initialBirthDate; // Pre-llenar fecha de nacimiento

  const BovinoFormScreen({
    super.key,
    this.bovine,
    required this.farmId,
    this.initialMotherId,
    this.initialBirthDate,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<BovinoFormCubit>()
        ..initialize(bovine),
      child: _BovinoFormContent(
        bovine: bovine,
        farmId: farmId,
        initialMotherId: initialMotherId,
        initialBirthDate: initialBirthDate,
      ),
    );
  }
}

class _BovinoFormContent extends StatefulWidget {
  final BovineEntity? bovine;
  final String farmId;
  final String? initialMotherId;
  final DateTime? initialBirthDate;

  const _BovinoFormContent({
    this.bovine,
    required this.farmId,
    this.initialMotherId,
    this.initialBirthDate,
  });

  @override
  State<_BovinoFormContent> createState() => _BovinoFormContentState();
}

class _BovinoFormContentState extends State<_BovinoFormContent> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();

  BovineGender _selectedGender = BovineGender.female;
  BovinePurpose _selectedPurpose = BovinePurpose.meat;
  BovineStatus _selectedStatus = BovineStatus.active;
  DateTime _selectedBirthDate = DateTime.now().subtract(const Duration(days: 365));
  
  // Genealogía
  String? _motherId;
  String? _fatherId;
  BovineEntity? _selectedMother;
  BovineEntity? _selectedFather;
  List<BovineEntity> _availableBovines = [];
  bool _isLoadingBovines = false;

  // Nuevos campos
  int _previousCalvings = 0;
  HealthStatus _healthStatus = HealthStatus.healthy;
  ProductionStage _productionStage = ProductionStage.raising;
  BreedingStatus? _breedingStatus;
  DateTime? _lastHeatDate;
  DateTime? _inseminationDate;
  DateTime? _expectedCalvingDate;

  bool get isEditMode => widget.bovine != null;

  @override
  void initState() {
    super.initState();
    
    // Pre-llenar con datos iniciales (cría desde parto)
    if (widget.initialMotherId != null) {
      _motherId = widget.initialMotherId;
    }
    if (widget.initialBirthDate != null) {
      _selectedBirthDate = widget.initialBirthDate!;
    }
    
    // Cargar lista de bovinos disponibles para genealogía
    _loadAvailableBovines();
    
    if (isEditMode) {
      _loadBovineData();
    } else {
      // Si es MACHO, forzar propósito a CARNE
      if (_selectedGender == BovineGender.male) {
        _selectedPurpose = BovinePurpose.meat;
      }
    }
  }

  /// Carga la lista de bovinos disponibles para selección de padres
  Future<void> _loadAvailableBovines() async {
    setState(() {
      _isLoadingBovines = true;
    });

    try {
      final getCattleList = di.sl<GetCattleList>();
      final result = await getCattleList(GetCattleListParams(farmId: widget.farmId));

      result.fold(
        (failure) {
          // Si hay error, continuar sin la lista (no es crítico)
          setState(() {
            _isLoadingBovines = false;
            _availableBovines = [];
          });
        },
        (bovines) {
          setState(() {
            _availableBovines = bovines;
            _isLoadingBovines = false;
          });

          // Si estamos editando y tenemos IDs de padres, buscar los bovinos correspondientes
          if (isEditMode && (_motherId != null || _fatherId != null)) {
            _loadSelectedParents();
          } else if (widget.initialMotherId != null) {
            // Si hay initialMotherId, buscar la madre
            try {
              final mother = _availableBovines.firstWhere(
                (b) => b.id == widget.initialMotherId,
              );
              setState(() {
                _selectedMother = mother;
                _motherId = mother.id;
              });
            } catch (e) {
              // Madre no encontrada en la lista
            }
          }
        },
      );
    } catch (e) {
      setState(() {
        _isLoadingBovines = false;
        _availableBovines = [];
      });
    }
  }

  /// Carga los bovinos seleccionados como padre y madre
  void _loadSelectedParents() {
    if (_fatherId != null) {
      try {
        final father = _availableBovines.firstWhere((b) => b.id == _fatherId);
        setState(() {
          _selectedFather = father;
        });
      } catch (e) {
        // Padre no encontrado en la lista
      }
    }

    if (_motherId != null) {
      try {
        final mother = _availableBovines.firstWhere((b) => b.id == _motherId);
        setState(() {
          _selectedMother = mother;
        });
      } catch (e) {
        // Madre no encontrada en la lista
      }
    }
  }

  void _loadBovineData() {
    final bovine = widget.bovine!;
    _identifierController.text = bovine.identifier;
    _nameController.text = bovine.name ?? '';
    _breedController.text = bovine.breed;
    _weightController.text = bovine.weight.toString();
    _notesController.text = bovine.notes ?? '';
    _selectedGender = bovine.gender;
    _selectedPurpose = bovine.purpose;
    _selectedStatus = bovine.status;
    _selectedBirthDate = bovine.birthDate;
    _motherId = bovine.motherId;
    _fatherId = bovine.fatherId;
    _previousCalvings = bovine.previousCalvings;
    _healthStatus = bovine.healthStatus;
    _productionStage = bovine.productionStage;
    _breedingStatus = bovine.breedingStatus;
    _lastHeatDate = bovine.lastHeatDate;
    _inseminationDate = bovine.inseminationDate;
    _expectedCalvingDate = bovine.expectedCalvingDate;
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _nameController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<BovinoFormCubit>().submit(
            farmId: widget.farmId,
            identifier: _identifierController.text.trim(),
            name: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
            breed: _breedController.text.trim(),
            gender: _selectedGender,
            birthDate: _selectedBirthDate,
            weight: double.parse(_weightController.text.trim()),
            purpose: _selectedPurpose,
            status: _selectedStatus,
            motherId: _motherId,
            fatherId: _fatherId,
            previousCalvings: _previousCalvings,
            healthStatus: _healthStatus,
            productionStage: _productionStage,
            breedingStatus: _breedingStatus,
            lastHeatDate: _lastHeatDate,
            inseminationDate: _inseminationDate,
            expectedCalvingDate: _expectedCalvingDate,
            notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          );
    }
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate,
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
    );

    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<BovinoFormCubit, BovinoFormState>(
      listener: (context, state) {
        if (state is BovinoFormSuccess) {
          final message = state.isEdit
              ? 'Bovino actualizado exitosamente'
              : 'Bovino creado exitosamente';
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
            ),
          );
          
          Navigator.pop(context, true); // Retornar true para indicar éxito
        }

        if (state is BovinoFormError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is BovinoFormLoading;

        return Scaffold(
          appBar: AppBar(
            title: Text(isEditMode ? 'Editar Bovino' : 'Nuevo Bovino'),
            centerTitle: true,
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Sección: Identificación
                _buildSectionTitle('Identificación', Icons.badge),
                const SizedBox(height: 12),
                _buildIdentifierField(),
                const SizedBox(height: 16),
                _buildNameField(),
                const SizedBox(height: 16),
                _buildBreedField(),

                const SizedBox(height: 24),

                // Sección: Genealogía
                _buildSectionTitle('Genealogía', Icons.family_restroom),
                const SizedBox(height: 12),
                if (_isLoadingBovines)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_availableBovines.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'No hay bovinos registrados. Registra algunos bovinos antes de asignar padres.',
                            style: TextStyle(
                              color: Colors.orange.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  _buildGenealogySection(),

                const SizedBox(height: 24),

                // Sección: Características
                _buildSectionTitle('Características', Icons.pets),
                const SizedBox(height: 12),
                _buildCategoryBadge(),
                const SizedBox(height: 16),
                _buildGenderSelector(),
                const SizedBox(height: 16),
                _buildPurposeSelector(),

                const SizedBox(height: 24),

                // Sección: Datos Físicos
                _buildSectionTitle('Datos Físicos', Icons.monitor_weight),
                const SizedBox(height: 12),
                _buildBirthDateField(context),
                const SizedBox(height: 16),
                _buildWeightField(),

                const SizedBox(height: 24),

                // Sección: Salud y Producción
                _buildSectionTitle('Salud y Producción', Icons.local_hospital),
                const SizedBox(height: 12),
                _buildHealthStatusSelector(),
                const SizedBox(height: 16),
                _buildProductionStageSelector(),
                const SizedBox(height: 16),
                _buildStatusSelector(),

                const SizedBox(height: 24),

                // Sección: Estado Reproductivo (solo hembras)
                if (_selectedGender == BovineGender.female) ...[
                  _buildSectionTitle('Estado Reproductivo', Icons.pregnant_woman),
                  const SizedBox(height: 12),
                  _buildBreedingStatusSelector(),
                  const SizedBox(height: 16),
                  _buildLastHeatDateField(context),
                  const SizedBox(height: 16),
                  if (_breedingStatus == BreedingStatus.inseminated ||
                      _breedingStatus == BreedingStatus.pregnant) ...[
                    _buildInseminationDateField(context),
                    const SizedBox(height: 16),
                  ],
                  if (_breedingStatus == BreedingStatus.pregnant) ...[
                    _buildExpectedCalvingDateField(context),
                    const SizedBox(height: 16),
                  ],
                  _buildPreviousCalvingsField(),
                  const SizedBox(height: 24),
                ],

                // Sección: Notas
                _buildSectionTitle('Notas', Icons.notes),
                const SizedBox(height: 12),
                _buildNotesField(),

                const SizedBox(height: 32),

                // Botón de guardar
                SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : () => _submit(context),
                    icon: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(
                      isLoading
                          ? 'Guardando...'
                          : isEditMode
                              ? 'Actualizar Bovino'
                              : 'Crear Bovino',
                      style: const TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
        ),
      ],
    );
  }

  Widget _buildGenealogySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vincula los padres de este animal si están registrados en el inventario.',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 16),
        BovineSelectorField(
          label: 'Padre (Sire)',
          hint: 'Selecciona el padre',
          prefixIcon: Icons.male,
          selectedBovine: _selectedFather,
          availableBovines: _availableBovines,
          sexFilter: SexFilter.male,
          excludeBovineId: widget.bovine?.id,
          onSelect: (bovine) {
            setState(() {
              _selectedFather = bovine;
              _fatherId = bovine?.id;
            });
          },
        ),
        const SizedBox(height: 16),
        BovineSelectorField(
          label: 'Madre (Dam)',
          hint: 'Selecciona la madre',
          prefixIcon: Icons.female,
          selectedBovine: _selectedMother,
          availableBovines: _availableBovines,
          sexFilter: SexFilter.female,
          excludeBovineId: widget.bovine?.id,
          onSelect: (bovine) {
            setState(() {
              _selectedMother = bovine;
              _motherId = bovine?.id;
            });
          },
        ),
      ],
    );
  }

  Widget _buildIdentifierField() {
    return TextFormField(
      controller: _identifierController,
      decoration: InputDecoration(
        labelText: 'Identificador / Arete *',
        hintText: 'Ej: #001, A-123',
        prefixIcon: const Icon(Icons.tag),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'El identificador es obligatorio';
        }
        return null;
      },
      textCapitalization: TextCapitalization.characters,
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Nombre (Opcional)',
        hintText: 'Ej: Mariposa, El Toro',
        prefixIcon: const Icon(Icons.label_outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      textCapitalization: TextCapitalization.words,
    );
  }

  Widget _buildBreedField() {
    return TextFormField(
      controller: _breedController,
      decoration: InputDecoration(
        labelText: 'Raza *',
        hintText: 'Ej: Holstein, Angus, Brahman',
        prefixIcon: const Icon(Icons.pets),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'La raza es obligatoria';
        }
        return null;
      },
      textCapitalization: TextCapitalization.words,
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Género *',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildChoiceChip(
                label: 'Macho',
                icon: Icons.male,
                selected: _selectedGender == BovineGender.male,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedGender = BovineGender.male;
                      // LÓGICA: Si cambia a macho, forzar propósito a CARNE
                      if (_selectedPurpose != BovinePurpose.meat) {
                        _selectedPurpose = BovinePurpose.meat;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Propósito cambiado a "Carne" (los machos no producen leche)'),
                            duration: Duration(seconds: 2),
                            backgroundColor: Colors.blue,
                          ),
                        );
                      }
                      // LÓGICA: Limpiar datos reproductivos
                      _breedingStatus = null;
                      _lastHeatDate = null;
                      _inseminationDate = null;
                      _expectedCalvingDate = null;
                    });
                  }
                },
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildChoiceChip(
                label: 'Hembra',
                icon: Icons.female,
                selected: _selectedGender == BovineGender.female,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedGender = BovineGender.female);
                  }
                },
                color: Colors.pink,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPurposeSelector() {
    final isMale = _selectedGender == BovineGender.male;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Propósito *',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            if (isMale) ...[
              const SizedBox(width: 8),
              Tooltip(
                message: 'Los machos solo pueden ser de Carne',
                child: Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<BovinePurpose>(
          value: _selectedPurpose,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.work_outline),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          items: [
            const DropdownMenuItem(
              value: BovinePurpose.meat,
              child: Row(
                children: [
                  Icon(Icons.restaurant, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Carne'),
                ],
              ),
            ),
            if (!isMale) ...[
              const DropdownMenuItem(
                value: BovinePurpose.milk,
                child: Row(
                  children: [
                    Icon(Icons.water_drop, size: 18, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Leche'),
                  ],
                ),
              ),
              const DropdownMenuItem(
                value: BovinePurpose.dual,
                child: Row(
                  children: [
                    Icon(Icons.star, size: 18, color: Colors.purple),
                    SizedBox(width: 8),
                    Text('Doble Propósito'),
                  ],
                ),
              ),
            ],
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedPurpose = value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildStatusSelector() {
    return DropdownButtonFormField<BovineStatus>(
      value: _selectedStatus,
      decoration: InputDecoration(
        labelText: 'Estado *',
        prefixIcon: const Icon(Icons.info_outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: const [
        DropdownMenuItem(
          value: BovineStatus.active,
          child: Text('Activo'),
        ),
        DropdownMenuItem(
          value: BovineStatus.sold,
          child: Text('Vendido'),
        ),
        DropdownMenuItem(
          value: BovineStatus.dead,
          child: Text('Muerto'),
        ),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedStatus = value);
        }
      },
    );
  }

  Widget _buildBirthDateField(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final age = DateTime.now().difference(_selectedBirthDate).inDays ~/ 365;

    return InkWell(
      onTap: () => _selectBirthDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Fecha de Nacimiento *',
          prefixIcon: const Icon(Icons.cake),
          suffixIcon: const Icon(Icons.calendar_today),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              dateFormat.format(_selectedBirthDate),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              '$age ${age == 1 ? 'año' : 'años'}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightField() {
    return TextFormField(
      controller: _weightController,
      decoration: InputDecoration(
        labelText: 'Peso (kg) *',
        hintText: 'Ej: 450',
        prefixIcon: const Icon(Icons.monitor_weight),
        suffixText: 'kg',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'El peso es obligatorio';
        }
        final weight = double.tryParse(value);
        if (weight == null || weight <= 0) {
          return 'Ingrese un peso válido mayor a 0';
        }
        return null;
      },
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required IconData icon,
    required bool selected,
    required ValueChanged<bool> onSelected,
    required Color color,
  }) {
    return FilterChip(
      label: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 18,
            color: selected ? Colors.white : color,
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: selected,
      onSelected: onSelected,
      selectedColor: color,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: selected ? Colors.white : null,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  // ========== NUEVOS MÉTODOS ==========

  Widget _buildCategoryBadge() {
    // Crear una entidad temporal para calcular la categoría
    final tempEntity = BovineEntity(
      id: '',
      farmId: widget.farmId,
      identifier: _identifierController.text,
      breed: _breedController.text,
      gender: _selectedGender,
      birthDate: _selectedBirthDate,
      weight: double.tryParse(_weightController.text) ?? 0,
      purpose: _selectedPurpose,
      status: _selectedStatus,
      createdAt: DateTime.now(),
      previousCalvings: _previousCalvings,
    );

    final category = tempEntity.category;
    final ageDisplay = tempEntity.ageDisplay;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: category.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: category.color, width: 2),
      ),
      child: Row(
        children: [
          Icon(category.icon, color: category.color, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Categoría: ${category.displayName}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: category.color,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Tooltip(
                      message: 'Se calcula automáticamente según edad, género y partos',
                      child: Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Edad: $ageDisplay',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.auto_awesome,
            color: category.color.withOpacity(0.6),
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildHealthStatusSelector() {
    return DropdownButtonFormField<HealthStatus>(
      value: _healthStatus,
      decoration: InputDecoration(
        labelText: 'Estado de Salud *',
        prefixIcon: const Icon(Icons.favorite_outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: HealthStatus.values.map((status) {
        return DropdownMenuItem(
          value: status,
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: status.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(status.displayName),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _healthStatus = value);
        }
      },
    );
  }

  Widget _buildProductionStageSelector() {
    return DropdownButtonFormField<ProductionStage>(
      value: _productionStage,
      decoration: InputDecoration(
        labelText: 'Etapa de Producción *',
        prefixIcon: const Icon(Icons.timeline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: ProductionStage.values.map((stage) {
        return DropdownMenuItem(
          value: stage,
          child: Text(stage.displayName),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _productionStage = value);
        }
      },
    );
  }

  Widget _buildBreedingStatusSelector() {
    return DropdownButtonFormField<BreedingStatus?>(
      value: _breedingStatus,
      decoration: InputDecoration(
        labelText: 'Estado Reproductivo',
        prefixIcon: const Icon(Icons.pregnant_woman),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: [
        const DropdownMenuItem<BreedingStatus?>(
          value: null,
          child: Text('No especificado'),
        ),
        ...BreedingStatus.values.map((status) {
          return DropdownMenuItem(
            value: status,
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: status.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(status.displayName),
              ],
            ),
          );
        }),
      ],
      onChanged: (value) {
        setState(() => _breedingStatus = value);
      },
    );
  }

  Widget _buildLastHeatDateField(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _lastHeatDate ?? DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now(),
          locale: const Locale('es', 'ES'),
        );
        if (picked != null) {
          setState(() => _lastHeatDate = picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Última Fecha de Celo',
          prefixIcon: const Icon(Icons.calendar_today),
          suffixIcon: _lastHeatDate != null
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() => _lastHeatDate = null),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          _lastHeatDate != null
              ? DateFormat('dd/MM/yyyy').format(_lastHeatDate!)
              : 'Seleccionar fecha',
          style: TextStyle(
            color: _lastHeatDate != null ? null : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildInseminationDateField(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _inseminationDate ?? DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now(),
          locale: const Locale('es', 'ES'),
        );
        if (picked != null) {
          setState(() {
            _inseminationDate = picked;
            // Calcular fecha esperada de parto (283 días después)
            _expectedCalvingDate = picked.add(const Duration(days: 283));
          });
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Fecha de Inseminación',
          prefixIcon: const Icon(Icons.science),
          suffixIcon: _inseminationDate != null
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() {
                    _inseminationDate = null;
                    _expectedCalvingDate = null;
                  }),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          _inseminationDate != null
              ? DateFormat('dd/MM/yyyy').format(_inseminationDate!)
              : 'Seleccionar fecha',
          style: TextStyle(
            color: _inseminationDate != null ? null : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildExpectedCalvingDateField(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _expectedCalvingDate ?? DateTime.now().add(const Duration(days: 283)),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          locale: const Locale('es', 'ES'),
        );
        if (picked != null) {
          setState(() => _expectedCalvingDate = picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Fecha Esperada de Parto',
          prefixIcon: const Icon(Icons.event_available),
          helperText: 'Calculada automáticamente (283 días)',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          _expectedCalvingDate != null
              ? DateFormat('dd/MM/yyyy').format(_expectedCalvingDate!)
              : 'Seleccionar fecha',
          style: TextStyle(
            color: _expectedCalvingDate != null ? null : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildPreviousCalvingsField() {
    return TextFormField(
      initialValue: _previousCalvings.toString(),
      decoration: InputDecoration(
        labelText: 'Partos Previos',
        hintText: '0',
        prefixIcon: const Icon(Icons.child_care),
        helperText: 'Número de partos anteriores',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      onChanged: (value) {
        setState(() {
          _previousCalvings = int.tryParse(value) ?? 0;
        });
      },
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      decoration: InputDecoration(
        labelText: 'Notas Adicionales',
        hintText: 'Observaciones, comentarios, etc.',
        prefixIcon: const Icon(Icons.note),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      maxLines: 4,
      textCapitalization: TextCapitalization.sentences,
    );
  }
}

