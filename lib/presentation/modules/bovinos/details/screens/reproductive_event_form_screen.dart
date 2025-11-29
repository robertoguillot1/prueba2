import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/di/dependency_injection.dart' as di;
import '../../../../../features/cattle/domain/entities/bovine_entity.dart';
import '../../../../../features/cattle/domain/entities/reproductive_event_entity.dart';
import '../cubits/reproductive_event_form_cubit.dart';

/// Pantalla de formulario para eventos reproductivos (Clean Architecture)
class ReproductiveEventFormScreen extends StatelessWidget {
  final BovineEntity bovine;
  final String farmId;
  final ReproductiveEventType? preselectedType;

  const ReproductiveEventFormScreen({
    super.key,
    required this.bovine,
    required this.farmId,
    this.preselectedType,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.DependencyInjection.createReproductiveEventFormCubit(),
      child: _ReproductiveEventFormContent(
        bovine: bovine,
        farmId: farmId,
        preselectedType: preselectedType,
      ),
    );
  }
}

class _ReproductiveEventFormContent extends StatefulWidget {
  final BovineEntity bovine;
  final String farmId;
  final ReproductiveEventType? preselectedType;

  const _ReproductiveEventFormContent({
    required this.bovine,
    required this.farmId,
    this.preselectedType,
  });

  @override
  State<_ReproductiveEventFormContent> createState() =>
      _ReproductiveEventFormContentState();
}

class _ReproductiveEventFormContentState
    extends State<_ReproductiveEventFormContent> {
  final _formKey = GlobalKey<FormState>();
  late ReproductiveEventType _selectedType;
  DateTime _selectedDate = DateTime.now();
  final _notesController = TextEditingController();

  // Campos específicos por tipo
  final _strawCodeController = TextEditingController(); // Código de pajilla
  String? _palpationResult; // Resultado de palpación
  bool _calfBorn = true; // Si nació la cría
  final _calfWeightController = TextEditingController(); // Peso de la cría

  @override
  void initState() {
    super.initState();
    _selectedType = widget.preselectedType ?? ReproductiveEventType.heat;
  }

  @override
  void dispose() {
    _notesController.dispose();
    _strawCodeController.dispose();
    _calfWeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReproductiveEventFormCubit,
        ReproductiveEventFormState>(
      listener: (context, state) {
        if (state is ReproductiveEventFormSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          
          // Si fue un parto, ofrecer registrar la cría
          if (_selectedType == ReproductiveEventType.calving) {
            _showRegisterOffspringDialog(context);
          } else {
            Navigator.pop(context, true); // Retorna true para indicar éxito
          }
        } else if (state is ReproductiveEventFormError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Registrar Evento'),
          actions: [
            BlocBuilder<ReproductiveEventFormCubit,
                ReproductiveEventFormState>(
              builder: (context, state) {
                if (state is ReproductiveEventFormLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  );
                }
                return IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: _handleSave,
                  tooltip: 'Guardar',
                );
              },
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Información del bovino
              _buildAnimalInfoCard(),
              const SizedBox(height: 24),

              // Tipo de evento
              _buildEventTypeSelector(),
              const SizedBox(height: 16),

              // Fecha
              _buildDatePicker(),
              const SizedBox(height: 16),

              // Campos específicos según tipo
              _buildTypeSpecificFields(),

              // Notas
              _buildNotesField(),
              const SizedBox(height: 32),

              // Botón de guardar
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// Tarjeta de información del animal
  Widget _buildAnimalInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _getGenderColor(widget.bovine.gender).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getGenderIcon(widget.bovine.gender),
                color: _getGenderColor(widget.bovine.gender),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.bovine.identifier,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (widget.bovine.name != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.bovine.name!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    '${widget.bovine.breed} • ${widget.bovine.ageDisplay}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Selector de tipo de evento
  Widget _buildEventTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de Evento',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ReproductiveEventType.values.map((tipo) {
            final isSelected = _selectedType == tipo;
            return ChoiceChip(
              label: Text(tipo.displayName),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedType = tipo;
                  });
                }
              },
              avatar: isSelected
                  ? null
                  : Icon(
                      _getIconForEventType(tipo),
                      size: 18,
                    ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Selector de fecha
  Widget _buildDatePicker() {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.calendar_today,
          color: Theme.of(context).primaryColor,
        ),
      ),
      title: const Text('Fecha del Evento'),
      subtitle: Text(dateFormat.format(_selectedDate)),
      trailing: const Icon(Icons.chevron_right),
      onTap: _selectDate,
    );
  }

  /// Campos específicos según el tipo de evento
  Widget _buildTypeSpecificFields() {
    switch (_selectedType) {
      case ReproductiveEventType.insemination:
        return _buildInseminationFields();
      case ReproductiveEventType.palpation:
        return _buildPalpationFields();
      case ReproductiveEventType.calving:
        return _buildBirthFields();
      default:
        return const SizedBox.shrink();
    }
  }

  /// Campos para Monta/Inseminación
  Widget _buildInseminationFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32),
        Text(
          'Detalles de Inseminación',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _strawCodeController,
          decoration: const InputDecoration(
            labelText: 'Código de Pajilla',
            hintText: 'Ej: PAJ-2024-001',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.qr_code),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  /// Campos para Palpación
  Widget _buildPalpationFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32),
        Text(
          'Resultado de Palpación',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(
              value: 'Positiva',
              label: Text('Positiva'),
              icon: Icon(Icons.check_circle, color: Colors.green),
            ),
            ButtonSegment(
              value: 'Negativa',
              label: Text('Negativa'),
              icon: Icon(Icons.cancel, color: Colors.red),
            ),
          ],
          selected: _palpationResult != null ? {_palpationResult!} : {},
          onSelectionChanged: (Set<String> selected) {
            setState(() {
              _palpationResult = selected.first;
            });
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  /// Campos para Parto
  Widget _buildBirthFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32),
        Text(
          'Detalles del Parto',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('¿Nació la cría?'),
          value: _calfBorn,
          onChanged: (value) {
            setState(() {
              _calfBorn = value;
            });
          },
        ),
        if (_calfBorn) ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: _calfWeightController,
            decoration: const InputDecoration(
              labelText: 'Peso de la Cría (kg)',
              hintText: 'Ej: 35',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.monitor_weight),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  /// Campo de notas
  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32),
        Text(
          'Notas Adicionales',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _notesController,
          decoration: const InputDecoration(
            labelText: 'Observaciones',
            hintText: 'Agrega cualquier información relevante...',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          maxLines: 4,
        ),
      ],
    );
  }

  /// Botón de guardar
  Widget _buildSaveButton() {
    return BlocBuilder<ReproductiveEventFormCubit,
        ReproductiveEventFormState>(
      builder: (context, state) {
        final isLoading = state is ReproductiveEventFormLoading;

        return ElevatedButton.icon(
          onPressed: isLoading ? null : _handleSave,
          icon: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save),
          label: Text(isLoading ? 'Guardando...' : 'Guardar Evento'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(16),
          ),
        );
      },
    );
  }

  /// Seleccionar fecha
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// Construir detalles según el tipo
  Map<String, dynamic> _buildDetails() {
    final details = <String, dynamic>{};

    switch (_selectedType) {
      case ReproductiveEventType.insemination:
        if (_strawCodeController.text.isNotEmpty) {
          details['semenCode'] = _strawCodeController.text.trim();
        }
        break;

      case ReproductiveEventType.palpation:
        if (_palpationResult != null) {
          details['palpationResult'] = _palpationResult;
        }
        break;

      case ReproductiveEventType.calving:
        details['calfBorn'] = _calfBorn;
        if (_calfBorn && _calfWeightController.text.isNotEmpty) {
          final weight = double.tryParse(_calfWeightController.text);
          if (weight != null) {
            details['calfWeight'] = weight;
          }
        }
        break;

      default:
        break;
    }

    return details;
  }

  /// Validar y guardar
  void _handleSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validaciones específicas
    if (_selectedType == ReproductiveEventType.palpation &&
        _palpationResult == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona el resultado de la palpación'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final details = _buildDetails();

    context.read<ReproductiveEventFormCubit>().saveEvent(
          farmId: widget.farmId,
          bovineId: widget.bovine.id,
          type: _selectedType,
          eventDate: _selectedDate,
          details: details,
          notes: _notesController.text,
        );
  }

  // Helper methods
  IconData _getGenderIcon(BovineGender gender) {
    return gender == BovineGender.male ? Icons.male : Icons.female;
  }

  Color _getGenderColor(BovineGender gender) {
    return gender == BovineGender.male ? Colors.blue : Colors.pink;
  }

  IconData _getIconForEventType(ReproductiveEventType tipo) {
    switch (tipo) {
      case ReproductiveEventType.heat:
        return Icons.favorite;
      case ReproductiveEventType.insemination:
        return Icons.pets;
      case ReproductiveEventType.palpation:
        return Icons.medical_services;
      case ReproductiveEventType.calving:
        return Icons.child_care;
      case ReproductiveEventType.abortion:
        return Icons.cancel;
      case ReproductiveEventType.drying:
        return Icons.water_drop;
    }
  }

  /// Muestra diálogo para registrar la cría nacida
  Future<void> _showRegisterOffspringDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.child_care, color: Colors.green),
            SizedBox(width: 12),
            Text('Registro de Cría'),
          ],
        ),
        content: const Text(
          '¿Desea registrar la cría nacida ahora mismo?\n\n'
          'Se prellenará automáticamente la fecha de nacimiento y la madre.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Después'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(dialogContext, true),
            icon: const Icon(Icons.add),
            label: const Text('Registrar Ahora'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );

    if (!context.mounted) return;

    if (result == true) {
      // Usuario aceptó registrar la cría
      // Navegar al formulario de bovino con datos prellenados
      final registered = await Navigator.pushNamed(
        context,
        '/bovinos/form',
        arguments: {
          'farmId': widget.bovine.farmId,
          'initialMotherId': widget.bovine.id,
          'initialBirthDate': _selectedDate,
        },
      );

      if (!context.mounted) return;

      // Volver a la pantalla anterior después de registrar (o cancelar)
      Navigator.pop(context, registered ?? true);
    } else {
      // Usuario eligió "Después"
      Navigator.pop(context, true);
    }
  }
}

