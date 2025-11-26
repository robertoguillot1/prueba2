import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../features/cattle/domain/entities/bovine_entity.dart';
import '../../../../core/di/dependency_injection.dart' as di;
import '../cubits/form/bovino_form_cubit.dart';
import '../cubits/form/bovino_form_state.dart';

/// Pantalla de formulario para crear o editar un Bovino
class BovinoFormScreen extends StatelessWidget {
  final BovineEntity? bovine; // null = crear, no null = editar
  final String farmId;

  const BovinoFormScreen({
    super.key,
    this.bovine,
    required this.farmId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<BovinoFormCubit>()
        ..initialize(bovine),
      child: _BovinoFormContent(
        bovine: bovine,
        farmId: farmId,
      ),
    );
  }
}

class _BovinoFormContent extends StatefulWidget {
  final BovineEntity? bovine;
  final String farmId;

  const _BovinoFormContent({
    this.bovine,
    required this.farmId,
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

  BovineGender _selectedGender = BovineGender.female;
  BovinePurpose _selectedPurpose = BovinePurpose.meat;
  BovineStatus _selectedStatus = BovineStatus.active;
  DateTime _selectedBirthDate = DateTime.now().subtract(const Duration(days: 365));

  bool get isEditMode => widget.bovine != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      _loadBovineData();
    }
  }

  void _loadBovineData() {
    final bovine = widget.bovine!;
    _identifierController.text = bovine.identifier;
    _nameController.text = bovine.name ?? '';
    _breedController.text = bovine.breed;
    _weightController.text = bovine.weight.toString();
    _selectedGender = bovine.gender;
    _selectedPurpose = bovine.purpose;
    _selectedStatus = bovine.status;
    _selectedBirthDate = bovine.birthDate;
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _nameController.dispose();
    _breedController.dispose();
    _weightController.dispose();
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

                // Sección: Características
                _buildSectionTitle('Características', Icons.pets),
                const SizedBox(height: 12),
                _buildGenderSelector(),
                const SizedBox(height: 16),
                _buildPurposeSelector(),
                const SizedBox(height: 16),
                _buildStatusSelector(),

                const SizedBox(height: 24),

                // Sección: Datos Físicos
                _buildSectionTitle('Datos Físicos', Icons.monitor_weight),
                const SizedBox(height: 12),
                _buildBirthDateField(context),
                const SizedBox(height: 16),
                _buildWeightField(),

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
                    setState(() => _selectedGender = BovineGender.male);
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
    return DropdownButtonFormField<BovinePurpose>(
      value: _selectedPurpose,
      decoration: InputDecoration(
        labelText: 'Propósito *',
        prefixIcon: const Icon(Icons.work_outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: const [
        DropdownMenuItem(
          value: BovinePurpose.meat,
          child: Text('Carne'),
        ),
        DropdownMenuItem(
          value: BovinePurpose.milk,
          child: Text('Leche'),
        ),
        DropdownMenuItem(
          value: BovinePurpose.dual,
          child: Text('Doble Propósito'),
        ),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedPurpose = value);
        }
      },
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
}

