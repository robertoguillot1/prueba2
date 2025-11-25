import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/farm/farm.dart';
import '../cubits/farm_form_cubit.dart';
import '../cubits/farm_form_state.dart';

/// Pantalla para crear o editar una finca
class FarmFormScreen extends StatefulWidget {
  final Farm? farm; // Si es null, es creación; si tiene valor, es edición

  const FarmFormScreen({super.key, this.farm});

  @override
  State<FarmFormScreen> createState() => _FarmFormScreenState();
}

class _FarmFormScreenState extends State<FarmFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  int _selectedColor = 0xFF4CAF50; // Verde por defecto

  @override
  void initState() {
    super.initState();
    if (widget.farm != null) {
      _nameController.text = widget.farm!.name;
      _locationController.text = widget.farm!.location ?? '';
      _descriptionController.text = widget.farm!.description ?? '';
      _selectedColor = widget.farm!.primaryColor;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showColorPicker() {
    final colors = [
      0xFF4CAF50, // Verde
      0xFF2196F3, // Azul
      0xFF9C27B0, // Morado
      0xFFF44336, // Rojo
      0xFFFF9800, // Naranja
      0xFF00BCD4, // Cyan
      0xFF795548, // Marrón
      0xFF607D8B, // Azul Gris
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar Color'),
        content: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: colors.map((colorValue) {
            final isSelected = _selectedColor == colorValue;
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedColor = colorValue;
                });
                Navigator.pop(context);
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Color(colorValue),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white)
                    : null,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<FarmFormCubit>();

    if (widget.farm == null) {
      // Crear nueva finca
      cubit.createFarm(
        name: _nameController.text.trim(),
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        primaryColor: _selectedColor,
      );
    } else {
      // Actualizar finca existente
      cubit.updateFarm(
        farm: widget.farm!,
        name: _nameController.text.trim(),
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        primaryColor: _selectedColor,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.farm == null ? 'Nueva Finca' : 'Editar Finca'),
      ),
      body: BlocListener<FarmFormCubit, FarmFormState>(
        listener: (context, state) {
          if (state is FarmFormSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  widget.farm == null
                      ? 'Finca creada exitosamente'
                      : 'Finca actualizada exitosamente',
                ),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          } else if (state is FarmFormError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Campo de nombre
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la Finca *',
                    hintText: 'Ej: Finca San José',
                    prefixIcon: Icon(Icons.agriculture),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El nombre es obligatorio';
                    }
                    if (value.length < 2) {
                      return 'El nombre debe tener al menos 2 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo de ubicación
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Ubicación',
                    hintText: 'Ej: San José, Costa Rica',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Campo de descripción
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    hintText: 'Descripción opcional de la finca',
                    prefixIcon: Icon(Icons.description),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),

                // Selector de color
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Color Principal',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: _showColorPicker,
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Color(_selectedColor),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '#${_selectedColor.toRadixString(16).toUpperCase()}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Botón de guardar
                BlocBuilder<FarmFormCubit, FarmFormState>(
                  builder: (context, state) {
                    final isLoading = state is FarmFormLoading;
                    return ElevatedButton(
                      onPressed: isLoading ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              widget.farm == null ? 'Crear Finca' : 'Guardar Cambios',
                              style: const TextStyle(fontSize: 16),
                            ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

