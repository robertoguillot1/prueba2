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

  // Lista de colores disponibles
  final List<int> _availableColors = [
    0xFF4CAF50, // Verde
    0xFF2196F3, // Azul
    0xFF9C27B0, // Morado
    0xFFF44336, // Rojo
    0xFFFF9800, // Naranja
    0xFF00BCD4, // Cyan
    0xFF795548, // Marrón
    0xFF607D8B, // Azul Gris
    0xFFE91E63, // Rosa
    0xFF3F51B5, // Índigo
    0xFF009688, // Teal
    0xFFFFC107, // Ámbar
    0xFFFF5722, // Naranja Oscuro
    0xFF03A9F4, // Azul Claro
    0xFF8BC34A, // Verde Claro
    0xFF673AB7, // Morado Oscuro
    0xFF9E9E9E, // Gris
    0xFF795548, // Marrón
  ];

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.farm == null ? 'Nueva Finca' : 'Editar Finca'),
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocListener<FarmFormCubit, FarmFormState>(
        listener: (context, state) {
          if (state is FarmFormSuccess) {
            // Mostrar mensaje de éxito
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.farm == null
                            ? 'Finca creada exitosamente'
                            : 'Finca actualizada exitosamente',
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
            // Cerrar la pantalla después de mostrar el mensaje
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) {
                Navigator.pop(context, true);
              }
            });
          } else if (state is FarmFormError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(child: Text(state.message)),
                  ],
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [
                      Colors.grey.shade900,
                      Colors.grey.shade800,
                    ]
                  : [
                      primaryColor.withOpacity(0.05),
                      Colors.white,
                    ],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header con icono
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: primaryColor.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.agriculture,
                      size: 48,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Card con formulario
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Campo de nombre
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Nombre de la Finca *',
                              hintText: 'Ej: Finca San José',
                              prefixIcon: Icon(Icons.agriculture, color: primaryColor),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade50,
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
                          const SizedBox(height: 20),

                          // Campo de ubicación
                          TextFormField(
                            controller: _locationController,
                            decoration: InputDecoration(
                              labelText: 'Ubicación',
                              hintText: 'Ej: San José, Costa Rica',
                              prefixIcon: Icon(Icons.location_on, color: primaryColor),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade50,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Campo de descripción
                          TextFormField(
                            controller: _descriptionController,
                            decoration: InputDecoration(
                              labelText: 'Descripción',
                              hintText: 'Descripción opcional de la finca',
                              prefixIcon: Icon(Icons.description, color: primaryColor),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade50,
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 32),

                          // Selector de color - Grid de círculos
                          Text(
                            'Color Principal',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 6,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1,
                            ),
                            itemCount: _availableColors.length,
                            itemBuilder: (context, index) {
                              final colorValue = _availableColors[index];
                              final isSelected = _selectedColor == colorValue;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedColor = colorValue;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Color(colorValue),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.black
                                          : Colors.grey.shade400,
                                      width: isSelected ? 3 : 1.5,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: Color(colorValue).withOpacity(0.5),
                                              blurRadius: 8,
                                              spreadRadius: 2,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 20,
                                        )
                                      : null,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 32),

                          // Vista previa del color seleccionado
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Color(_selectedColor).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Color(_selectedColor).withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Color(_selectedColor),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Color seleccionado',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '#${_selectedColor.toRadixString(16).toUpperCase()}',
                                        style: theme.textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Color(_selectedColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botón de guardar
                  BlocBuilder<FarmFormCubit, FarmFormState>(
                    builder: (context, state) {
                      final isLoading = state is FarmFormLoading;
                      return SizedBox(
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: isLoading ? null : _handleSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Icon(
                                  widget.farm == null ? Icons.add_circle : Icons.save,
                                  size: 24,
                                ),
                          label: Text(
                            isLoading
                                ? 'Guardando...'
                                : (widget.farm == null ? 'Crear Finca' : 'Guardar Cambios'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

