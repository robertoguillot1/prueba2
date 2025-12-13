import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/di/dependency_injection.dart' as di;
import '../../../../../features/cattle/domain/entities/bovine_entity.dart';
import '../cubits/production_form_cubit.dart';

/// Formulario para registrar peso del bovino
class WeightRecordFormScreen extends StatelessWidget {
  final BovineEntity bovine;
  final String farmId;

  const WeightRecordFormScreen({
    super.key,
    required this.bovine,
    required this.farmId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.DependencyInjection.createProductionFormCubit(),
      child: _WeightRecordFormContent(
        bovine: bovine,
        farmId: farmId,
      ),
    );
  }
}

class _WeightRecordFormContent extends StatefulWidget {
  final BovineEntity bovine;
  final String farmId;

  const _WeightRecordFormContent({
    required this.bovine,
    required this.farmId,
  });

  @override
  State<_WeightRecordFormContent> createState() =>
      _WeightRecordFormContentState();
}

class _WeightRecordFormContentState extends State<_WeightRecordFormContent> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductionFormCubit, ProductionFormState>(
      listener: (context, state) {
        if (state is ProductionFormSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Retorna true para indicar éxito
        } else if (state is ProductionFormError) {
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
          title: const Text('Registrar Peso'),
          actions: [
            BlocBuilder<ProductionFormCubit, ProductionFormState>(
              builder: (context, state) {
                if (state is ProductionFormLoading) {
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

              // Peso actual del bovino (referencia)
              _buildCurrentWeightCard(),
              const SizedBox(height: 24),

              // Fecha
              _buildDatePicker(),
              const SizedBox(height: 16),

              // Peso
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: 'Peso',
                  hintText: 'Ej: 450.5',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.monitor_weight),
                  suffixText: 'kg',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el peso';
                  }
                  final weight = double.tryParse(value);
                  if (weight == null) {
                    return 'Ingrese un número válido';
                  }
                  if (weight <= 0) {
                    return 'El peso debe ser mayor a 0';
                  }
                  if (weight > 2000) {
                    return 'Peso muy alto, verifique';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Notas
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notas (Opcional)',
                  hintText: 'Condición corporal, observaciones...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),
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
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.monitor_weight,
                color: Colors.green,
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
                    '${widget.bovine.breed} • ${widget.bovine.age} años',
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

  /// Tarjeta con el peso actual registrado
  Widget _buildCurrentWeightCard() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Peso Registrado Actual',
                    style: TextStyle(
                      color: Colors.blue.shade900,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.bovine.weight.toStringAsFixed(1)} kg',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
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

  /// Selector de fecha
  Widget _buildDatePicker() {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      child: ListTile(
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
        title: const Text('Fecha del Pesaje'),
        subtitle: Text(dateFormat.format(_selectedDate)),
        trailing: const Icon(Icons.chevron_right),
        onTap: _selectDate,
      ),
    );
  }

  /// Botón de guardar
  Widget _buildSaveButton() {
    return BlocBuilder<ProductionFormCubit, ProductionFormState>(
      builder: (context, state) {
        final isLoading = state is ProductionFormLoading;

        return ElevatedButton.icon(
          onPressed: isLoading ? null : _handleSave,
          icon: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save),
          label: Text(isLoading ? 'Guardando...' : 'Guardar Peso'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(16),
            backgroundColor: Colors.green,
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

  /// Validar y guardar
  void _handleSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final weight = double.parse(_weightController.text);

    context.read<ProductionFormCubit>().saveWeight(
          farmId: widget.farmId,
          bovineId: widget.bovine.id,
          date: _selectedDate,
          weight: weight,
          notes: _notesController.text,
        );
  }
}







