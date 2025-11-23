import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';

class FarmFormScreen extends StatefulWidget {
  final Farm? farmToEdit;

  const FarmFormScreen({super.key, this.farmToEdit});

  @override
  State<FarmFormScreen> createState() => _FarmFormScreenState();
}

class _FarmFormScreenState extends State<FarmFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  Color _selectedColor = Colors.green;
  bool _isLoading = false;

  final List<Color> _availableColors = [
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.brown,
    Colors.cyan,
    Colors.amber,
    Colors.deepOrange,
    Colors.lightBlue,
    Colors.lightGreen,
    Colors.deepPurple,
    Colors.red,
    Colors.grey,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.farmToEdit != null) {
      _initializeWithFarm();
    }
  }

  void _initializeWithFarm() {
    final farm = widget.farmToEdit!;
    _nameController.text = farm.name;
    _locationController.text = farm.location ?? '';
    _descriptionController.text = farm.description ?? '';
    _selectedColor = farm.primaryColor;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveFarm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<FarmProvider>(context, listen: false);
      
      if (widget.farmToEdit == null) {
        // Create new farm
        final newFarm = Farm(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text.trim(),
          location: _locationController.text.trim().isEmpty 
              ? null 
              : _locationController.text.trim(),
          description: _descriptionController.text.trim().isEmpty 
              ? null 
              : _descriptionController.text.trim(),
          createdAt: DateTime.now(),
          primaryColor: _selectedColor,
        );
        
        await provider.addFarm(newFarm);
        
        // Esperar un momento para que los listeners de Firestore se actualicen
        await Future.delayed(const Duration(milliseconds: 200));
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Finca creada exitosamente')),
          );
          
          // Esperar un poco más antes de cerrar
          await Future.delayed(const Duration(milliseconds: 300));
          
          if (mounted) {
            Navigator.pop(context, true);
          }
        }
      } else {
        // Update existing farm
        final updatedFarm = widget.farmToEdit!.copyWith(
          name: _nameController.text.trim(),
          location: _locationController.text.trim().isEmpty 
              ? null 
              : _locationController.text.trim(),
          description: _descriptionController.text.trim().isEmpty 
              ? null 
              : _descriptionController.text.trim(),
          primaryColor: _selectedColor,
        );
        
        await provider.updateFarm(updatedFarm);
        
        // Esperar un momento para que los listeners de Firestore se actualicen
        await Future.delayed(const Duration(milliseconds: 200));
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Finca actualizada exitosamente')),
          );
          
          // Esperar un poco más antes de cerrar
          await Future.delayed(const Duration(milliseconds: 300));
          
          if (mounted) {
            Navigator.pop(context, true);
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.farmToEdit == null ? 'Nueva Finca' : 'Editar Finca'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Farm name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la Finca',
                  hintText: 'Ingresa el nombre de la finca',
                  prefixIcon: Icon(Icons.agriculture),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresa el nombre de la finca';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Location
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Ubicación (Opcional)',
                  hintText: 'Ciudad, departamento, etc.',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción (Opcional)',
                  hintText: 'Describe las características de la finca',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Color selection
              Text(
                'Color Principal',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableColors.map((color) {
                  final isSelected = _selectedColor == color;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.black, width: 3)
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
                }).toList(),
              ),
              const SizedBox(height: 32),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveFarm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedColor,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          widget.farmToEdit == null ? 'Crear Finca' : 'Actualizar Finca',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}