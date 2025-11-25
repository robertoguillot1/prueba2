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
  final _laborDescriptionController = TextEditingController();
  
  DateTime _startDate = DateTime.now();
  bool _isActive = true;
  bool _isLoading = false;
  WorkerType _workerType = WorkerType.fijo;

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
    _workerType = worker.workerType;
    _laborDescriptionController.text = worker.laborDescription ?? '';
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _identificationController.dispose();
    _positionController.dispose();
    _salaryController.dispose();
    _laborDescriptionController.dispose();
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
        final salary = double.tryParse(salaryValue);
        if (salary == null || salary <= 0) {
          throw Exception('Salario inválido');
        }
        final newWorker = Worker(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          fullName: _fullNameController.text.trim(),
          identification: _identificationController.text.trim(),
          position: _positionController.text.trim(),
          salary: salary,
          startDate: _startDate,
          isActive: _isActive,
          workerType: _workerType,
          laborDescription: _workerType == WorkerType.porLabor 
              ? (_laborDescriptionController.text.trim().isEmpty 
                  ? null 
                  : _laborDescriptionController.text.trim())
              : null,
        );
        
        await provider.addWorker(newWorker, farmId: widget.farm.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trabajador creado exitosamente')),
        );
      } else {
        // Update existing worker
        final salaryValue = ThousandsFormatter.getNumericValue(_salaryController.text);
        final salary = double.tryParse(salaryValue);
        if (salary == null || salary <= 0) {
          throw Exception('Salario inválido');
        }
        final updatedWorker = widget.workerToEdit!.copyWith(
          fullName: _fullNameController.text.trim(),
          identification: _identificationController.text.trim(),
          position: _positionController.text.trim(),
          salary: salary,
          startDate: _startDate,
          isActive: _isActive,
          workerType: _workerType,
          laborDescription: _workerType == WorkerType.porLabor 
              ? (_laborDescriptionController.text.trim().isEmpty 
                  ? null 
                  : _laborDescriptionController.text.trim())
              : null,
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

              // Worker Type
              Text(
                'Tipo de Trabajador',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _workerType = WorkerType.fijo;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _workerType == WorkerType.fijo
                              ? widget.farm.primaryColor
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _workerType == WorkerType.fijo
                                ? widget.farm.primaryColor
                                : Colors.grey[300]!,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.work,
                              color: _workerType == WorkerType.fijo
                                  ? Colors.white
                                  : Colors.grey[600],
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Indefinido/Fijo',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _workerType == WorkerType.fijo
                                    ? Colors.white
                                    : Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Contrato fijo',
                              style: TextStyle(
                                fontSize: 12,
                                color: _workerType == WorkerType.fijo
                                    ? Colors.white70
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _workerType = WorkerType.porLabor;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _workerType == WorkerType.porLabor
                              ? widget.farm.primaryColor
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _workerType == WorkerType.porLabor
                                ? widget.farm.primaryColor
                                : Colors.grey[300]!,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.assignment,
                              color: _workerType == WorkerType.porLabor
                                  ? Colors.white
                                  : Colors.grey[600],
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Prestación de Servicios',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _workerType == WorkerType.porLabor
                                    ? Colors.white
                                    : Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Por contrato',
                              style: TextStyle(
                                fontSize: 12,
                                color: _workerType == WorkerType.porLabor
                                    ? Colors.white70
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Salary
              TextFormField(
                controller: _salaryController,
                decoration: InputDecoration(
                  labelText: _workerType == WorkerType.porLabor
                      ? 'Valor Total Acordado'
                      : 'Salario Quincenal',
                  hintText: _workerType == WorkerType.porLabor
                      ? 'Ingresa el valor total del trabajo acordado'
                      : 'Ingresa el salario',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: const OutlineInputBorder(),
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

              // Labor Description (only for porLabor)
              if (_workerType == WorkerType.porLabor) ...[
                TextFormField(
                  controller: _laborDescriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción de la Labor/Obra',
                    hintText: 'Ej: Construcción de corral, Siembra de pasto, etc.',
                    prefixIcon: Icon(Icons.description),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (_workerType == WorkerType.porLabor) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor ingresa la descripción de la labor';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

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
                        _isActive ? Icons.toggle_on : Icons.toggle_off,
                        color: _isActive ? Colors.green : Colors.grey,
                        size: 28,
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
