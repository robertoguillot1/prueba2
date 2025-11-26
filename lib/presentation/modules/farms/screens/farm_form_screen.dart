import 'dart:math';
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

  @override
  void initState() {
    super.initState();
    if (widget.farm != null) {
      _nameController.text = widget.farm!.name;
      _locationController.text = widget.farm!.location ?? '';
      _descriptionController.text = widget.farm!.description ?? '';
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
      // Crear nueva finca - Generar color aleatorio
      final random = Random();
      final randomColor = Colors.primaries[random.nextInt(Colors.primaries.length)].value;
      
      cubit.createFarm(
        name: _nameController.text.trim(),
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        primaryColor: randomColor,
      );
    } else {
      // Actualizar finca existente - Mantener color original
      cubit.updateFarm(
        farm: widget.farm!,
        name: _nameController.text.trim(),
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        primaryColor: widget.farm!.primaryColor, // Mantener color original
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
          print('🟣 [FarmFormScreen] BlocListener - Estado recibido: ${state.runtimeType}');
          
          if (state is FarmFormSuccess) {
            print('✅ [FarmFormScreen] FarmFormSuccess detectado - Cerrando INMEDIATAMENTE');
            
            // CRÍTICO: Cerrar la pantalla PRIMERO (sin delay)
            // El `true` indica que se creó/actualizó exitosamente
            Navigator.of(context).pop(true);
            print('✅ [FarmFormScreen] Navigator.pop(true) ejecutado');
            
            // Mostrar SnackBar en la pantalla anterior (usando Future.microtask)
            Future.microtask(() {
              // Verificar que el contexto todavía esté montado
              if (!context.mounted) return;
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.farm == null
                              ? '¡Finca creada exitosamente!'
                              : '¡Finca actualizada exitosamente!',
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
              print('✅ [FarmFormScreen] SnackBar mostrado en pantalla anterior');
            });
          } else if (state is FarmFormError) {
            print('❌ [FarmFormScreen] FarmFormError detectado: ${state.message}');
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
                          const SizedBox(height: 16),

                          // Información sobre el color
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: primaryColor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.palette,
                                  size: 20,
                                  color: primaryColor,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    widget.farm == null
                                        ? 'Se asignará un color automáticamente'
                                        : 'El color de la finca se mantendrá',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.grey.shade700,
                                      fontStyle: FontStyle.italic,
                                    ),
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

