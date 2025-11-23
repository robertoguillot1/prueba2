import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';
import '../models/worker.dart';
import '../utils/thousands_formatter.dart';

class WorkerFormScreen extends StatefulWidget {
  final Farm farm;
  final Worker? workerToEdit;

  const WorkerFormScreen({
    super.key,
    required this.farm,
    this.workerToEdit,
  });

  @override
  State<WorkerFormScreen> createState() => _WorkerFormScreenState();
}

class _WorkerFormScreenState extends State<WorkerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _identificationController = TextEditingController();
  final _positionController = TextEditingController();
  final _salaryController = TextEditingController();
  
  DateTime _startDate = DateTime.now();
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.workerToEdit != null) {
      _initializeWithWorker();
    }
  }

  void _initializeWithWorker() {
    final worker = widget.workerToEdit!;
    _fullNameController.text = worker.fullName;
    _identificationController.text = worker.identification;
    _positionController.text = worker.position;
    // Format salary with thousands separator
    final formattedSalary = NumberFormat('#,###').format(worker.salary.toInt());
    _salaryController.text = formattedSalary;
    _startDate = worker.startDate;
    _isActive = worker.isActive;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _identificationController.dispose();
    _positionController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _saveWorker() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<FarmProvider>(context, listen: false);
      
      if (widget.workerToEdit == null) {
        // Create new worker
        final salaryValue = ThousandsFormatter.getNumericValue(_salaryController.text);
        final newWorker = Worker(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          fullName: _fullNameController.text.trim(),
          identification: _identificationController.text.trim(),
          position: _positionController.text.trim(),
          salary: double.parse(salaryValue),
          startDate: _startDate,
          isActive: _isActive,
        );
        
        await provider.addWorker(newWorker, farmId: widget.farm.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trabajador creado exitosamente')),
        );
      } else {
        // Update existing worker
        final salaryValue = ThousandsFormatter.getNumericValue(_salaryController.text);
        final updatedWorker = widget.workerToEdit!.copyWith(
          fullName: _fullNameController.text.trim(),
          identification: _identificationController.text.trim(),
          position: _positionController.text.trim(),
          salary: double.parse(salaryValue),
          startDate: _startDate,
          isActive: _isActive,
        );
        
        await provider.updateWorker(updatedWorker, farmId: widget.farm.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trabajador actualizado exitosamente')),
        );
      }
      
      Navigator.pop(context);
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
        title: Text(widget.workerToEdit == null ? 'Nuevo Trabajador' : 'Editar Trabajador'),
        centerTitle: true,
        backgroundColor: widget.farm.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Full name
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre Completo',
                  hintText: 'Ingresa el nombre completo',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresa el nombre completo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Identification
              TextFormField(
                controller: _identificationController,
                decoration: const InputDecoration(
                  labelText: 'Cédula o Identificación (Opcional)',
                  hintText: 'Número de identificación',
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Position
              TextFormField(
                controller: _positionController,
                decoration: const InputDecoration(
                  labelText: 'Cargo o Función',
                  hintText: 'Ej: Jornalero, Capataz, etc.',
                  prefixIcon: Icon(Icons.work),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresa el cargo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Salary
              TextFormField(
                controller: _salaryController,
                decoration: const InputDecoration(
                  labelText: 'Salario Quincenal',
                  hintText: 'Ingresa el salario',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  ThousandsFormatter(),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el salario';
                  }
                  final numericValue = ThousandsFormatter.getNumericValue(value);
                  final salary = double.tryParse(numericValue);
                  if (salary == null || salary <= 0) {
                    return 'Por favor ingresa un salario válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Start date
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha de Ingreso',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    DateFormat('dd/MM/yyyy').format(_startDate),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Active status
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.toggle_on,
                        color: _isActive ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Estado del Trabajador',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _isActive ? 'Activo' : 'Inactivo',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: _isActive ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isActive,
                        onChanged: (value) {
                          setState(() {
                            _isActive = value;
                          });
                        },
                        activeColor: Colors.green,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveWorker,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.farm.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          widget.workerToEdit == null ? 'Crear Trabajador' : 'Actualizar Trabajador',
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
