import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';
import '../models/cattle.dart';

class CattleReproductionFormScreen extends StatefulWidget {
  final Farm farm;

  const CattleReproductionFormScreen({super.key, required this.farm});

  @override
  State<CattleReproductionFormScreen> createState() => _CattleReproductionFormScreenState();
}

class _CattleReproductionFormScreenState extends State<CattleReproductionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  Cattle? _selectedCattle;
  BreedingStatus? _breedingStatus;
  DateTime? _lastHeatDate;
  DateTime? _inseminationDate;
  DateTime? _expectedCalvingDate;
  late TextEditingController _previousCalvingsController;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _previousCalvingsController = TextEditingController();
  }

  @override
  void dispose() {
    _previousCalvingsController.dispose();
    super.dispose();
  }

  Future<void> _saveReproduction() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCattle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un animal')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final farmProvider = Provider.of<FarmProvider>(context, listen: false);
      
      final updatedCattle = _selectedCattle!.copyWith(
        breedingStatus: _breedingStatus,
        lastHeatDate: _lastHeatDate,
        inseminationDate: _inseminationDate,
        expectedCalvingDate: _expectedCalvingDate,
        previousCalvings: _previousCalvingsController.text.isEmpty 
            ? null 
            : int.tryParse(_previousCalvingsController.text),
      );

      await farmProvider.updateCattle(updatedCattle);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Estado reproductivo actualizado'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final females = widget.farm.cattle.where((c) => c.gender == CattleGender.female).toList();

    if (_selectedCattle == null && females.isNotEmpty) {
      _selectedCattle = females.first;
      _breedingStatus = females.first.breedingStatus;
      _lastHeatDate = females.first.lastHeatDate;
      _inseminationDate = females.first.inseminationDate;
      _expectedCalvingDate = females.first.expectedCalvingDate;
      _previousCalvingsController.text = females.first.previousCalvings?.toString() ?? '';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('🔴 Actualizar Estado Reproductivo'),
        centerTitle: true,
        backgroundColor: widget.farm.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: females.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.child_care, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay hembras registradas',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Selección de animal
                  DropdownButtonFormField<Cattle>(
                    value: _selectedCattle,
                    decoration: const InputDecoration(
                      labelText: 'Animal *',
                      prefixIcon: Icon(Icons.pets),
                      border: OutlineInputBorder(),
                    ),
                    items: females.map((cattle) {
                      return DropdownMenuItem<Cattle>(
                        value: cattle,
                        child: Text(cattle.name ?? cattle.identification ?? 'Sin ID'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCattle = value;
                        _breedingStatus = value?.breedingStatus;
                        _lastHeatDate = value?.lastHeatDate;
                        _inseminationDate = value?.inseminationDate;
                        _expectedCalvingDate = value?.expectedCalvingDate;
                        _previousCalvingsController.text = value?.previousCalvings?.toString() ?? '';
                      });
                    },
                    validator: (value) {
                      if (value == null) return 'Selecciona un animal';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Estado reproductivo
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Estado reproductivo'),
                          RadioListTile<BreedingStatus>(
                            title: const Text('Sin estado'),
                            value: BreedingStatus.vacia,
                            groupValue: _breedingStatus,
                            onChanged: (value) => setState(() => _breedingStatus = value),
                          ),
                          RadioListTile<BreedingStatus>(
                            title: const Text('En celo'),
                            value: BreedingStatus.vacia,
                            groupValue: _breedingStatus,
                            onChanged: (value) => setState(() => _breedingStatus = value),
                          ),
                          RadioListTile<BreedingStatus>(
                            title: const Text('Gestante'),
                            value: BreedingStatus.prenada,
                            groupValue: _breedingStatus,
                            onChanged: (value) => setState(() => _breedingStatus = value),
                          ),
                          RadioListTile<BreedingStatus>(
                            title: const Text('Parida'),
                            value: BreedingStatus.lactante,
                            groupValue: _breedingStatus,
                            onChanged: (value) => setState(() => _breedingStatus = value),
                          ),
                          RadioListTile<BreedingStatus>(
                            title: const Text('Descansando'),
                            value: BreedingStatus.seca,
                            groupValue: _breedingStatus,
                            onChanged: (value) => setState(() => _breedingStatus = value),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Fecha de último celo
                  if (_breedingStatus != null) ...[
                    const SizedBox(height: 16),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.schedule),
                        title: const Text('Último celo'),
                        subtitle: Text(
                          _lastHeatDate != null
                              ? DateFormat('dd/MM/yyyy').format(_lastHeatDate!)
                              : 'No especificada',
                        ),
                        trailing: _lastHeatDate != null
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () => setState(() => _lastHeatDate = null),
                              )
                            : null,
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _lastHeatDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() => _lastHeatDate = date);
                          }
                        },
                      ),
                    ),
                  ],

                  // Fecha de inseminación/monta
                  if (_breedingStatus == BreedingStatus.prenada) ...[
                    const SizedBox(height: 16),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.favorite),
                        title: const Text('Fecha de inseminación/monta'),
                        subtitle: Text(
                          _inseminationDate != null
                              ? DateFormat('dd/MM/yyyy').format(_inseminationDate!)
                              : 'No especificada',
                        ),
                        trailing: _inseminationDate != null
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () => setState(() => _inseminationDate = null),
                              )
                            : null,
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _inseminationDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() {
                              _inseminationDate = date;
                              // Calcular fecha estimada de parto
                              _expectedCalvingDate = date.add(const Duration(days: 283)); // TODO: Usar AppConstants.cattleGestationDays
                            });
                          }
                        },
                      ),
                    ),
                  ],

                  // Fecha estimada de parto
                  if (_breedingStatus == BreedingStatus.prenada) ...[
                    const SizedBox(height: 16),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.child_care),
                        title: const Text('Fecha estimada de parto'),
                        subtitle: Text(
                          _expectedCalvingDate != null
                              ? DateFormat('dd/MM/yyyy').format(_expectedCalvingDate!)
                              : 'No especificada',
                        ),
                        trailing: _expectedCalvingDate != null
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () => setState(() => _expectedCalvingDate = null),
                              )
                            : null,
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _expectedCalvingDate ?? DateTime.now().add(const Duration(days: 283)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2030),
                          );
                          if (date != null) {
                            setState(() => _expectedCalvingDate = date);
                          }
                        },
                      ),
                    ),
                  ],

                  // Partos anteriores
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _previousCalvingsController,
                    decoration: const InputDecoration(
                      labelText: 'Partos anteriores (opcional)',
                      hintText: 'Número de crías anteriores',
                      prefixIcon: Icon(Icons.child_care),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 24),

                  // Botón de guardar
                  ElevatedButton(
                    onPressed: _isProcessing ? null : _saveReproduction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.farm.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Guardar', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
    );
  }
}














