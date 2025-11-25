import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';
import '../models/cattle.dart';
import '../widgets/cattle_selector_modal.dart';

class CattleFormScreen extends StatefulWidget {
  final Farm farm;
  final Cattle? cattleToEdit;

  const CattleFormScreen({
    super.key,
    required this.farm,
    this.cattleToEdit,
  });

  @override
  State<CattleFormScreen> createState() => _CattleFormScreenState();
}

class _CattleFormScreenState extends State<CattleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _identificationController;
  late TextEditingController _nameController;
  late CattleCategory _category;
  late CattleGender _gender;
  DateTime? _birthDate;
  late TextEditingController _weightController;
  late ProductionStage _productionStage;
  late HealthStatus _healthStatus;
  BreedingStatus? _breedingStatus;
  DateTime? _lastHeatDate;
  DateTime? _inseminationDate;
  DateTime? _expectedCalvingDate;
  late TextEditingController _previousCalvingsController;
  late TextEditingController _notesController;
  late TextEditingController _razaController;
  Cattle? _selectedPadre;
  Cattle? _selectedMadre;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _identificationController = TextEditingController(
      text: widget.cattleToEdit?.identification ?? '',
    );
    _nameController = TextEditingController(
      text: widget.cattleToEdit?.name ?? '',
    );
    _category = widget.cattleToEdit?.category ?? CattleCategory.vaca;
    _gender = widget.cattleToEdit?.gender ?? CattleGender.female;
    _birthDate = widget.cattleToEdit?.birthDate;
    _weightController = TextEditingController(
      text: widget.cattleToEdit?.currentWeight.toString() ?? '',
    );
    _productionStage = widget.cattleToEdit?.productionStage ?? ProductionStage.levante;
    _healthStatus = widget.cattleToEdit?.healthStatus ?? HealthStatus.sano;
    _breedingStatus = widget.cattleToEdit?.breedingStatus;
    _lastHeatDate = widget.cattleToEdit?.lastHeatDate;
    _inseminationDate = widget.cattleToEdit?.inseminationDate;
    _expectedCalvingDate = widget.cattleToEdit?.expectedCalvingDate;
    _previousCalvingsController = TextEditingController(
      text: widget.cattleToEdit?.previousCalvings?.toString() ?? '',
    );
    _notesController = TextEditingController(
      text: widget.cattleToEdit?.notes ?? '',
    );
    _razaController = TextEditingController(
      text: widget.cattleToEdit?.raza ?? '',
    );
    
    // Inicializar padres si existen
    if (widget.cattleToEdit != null) {
      final farmProvider = Provider.of<FarmProvider>(context, listen: false);
      final updatedFarm = farmProvider.farms.firstWhere(
        (f) => f.id == widget.farm.id,
        orElse: () => widget.farm,
      );
      
      if (widget.cattleToEdit!.idPadre != null) {
        try {
          _selectedPadre = updatedFarm.cattle.firstWhere(
            (c) => c.id == widget.cattleToEdit!.idPadre,
          );
        } catch (e) {
          _selectedPadre = null;
        }
      }
      
      if (widget.cattleToEdit!.idMadre != null) {
        try {
          _selectedMadre = updatedFarm.cattle.firstWhere(
            (c) => c.id == widget.cattleToEdit!.idMadre,
          );
        } catch (e) {
          _selectedMadre = null;
        }
      }
    }
  }

  @override
  void dispose() {
    _identificationController.dispose();
    _nameController.dispose();
    _weightController.dispose();
    _previousCalvingsController.dispose();
    _notesController.dispose();
    _razaController.dispose();
    super.dispose();
  }

  Future<void> _saveCattle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    try {
      final farmProvider = Provider.of<FarmProvider>(context, listen: false);
      final cattleId = widget.cattleToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
      
      final cattle = Cattle(
        id: cattleId,
        farmId: widget.farm.id,
        identification: _identificationController.text.isEmpty ? null : _identificationController.text,
        name: _nameController.text.isEmpty ? null : _nameController.text,
        category: _category,
        gender: _gender,
        currentWeight: double.parse(_weightController.text),
        birthDate: _birthDate ?? DateTime.now(),
        productionStage: _productionStage,
        healthStatus: _healthStatus,
        breedingStatus: _breedingStatus,
        lastHeatDate: _lastHeatDate,
        inseminationDate: _inseminationDate,
        expectedCalvingDate: _expectedCalvingDate,
        previousCalvings: _previousCalvingsController.text.isEmpty ? null : int.tryParse(_previousCalvingsController.text),
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        idPadre: _selectedPadre?.id,
        nombrePadre: _selectedPadre?.name ?? _selectedPadre?.identification,
        idMadre: _selectedMadre?.id,
        nombreMadre: _selectedMadre?.name ?? _selectedMadre?.identification,
        raza: _razaController.text.isEmpty ? null : _razaController.text,
      );

      if (widget.cattleToEdit == null) {
        await farmProvider.addCattle(cattle, farmId: widget.farm.id);
      } else {
        await farmProvider.updateCattle(cattle, farmId: widget.farm.id);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.cattleToEdit == null
                ? 'Animal agregado exitosamente'
                : 'Animal actualizado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e, stackTrace) {
      if (mounted) {
        // Mostrar error más descriptivo
        final errorMessage = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage.isNotEmpty ? errorMessage : 'Error al guardar el animal'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
        // Log del error
        print('Error al guardar animal: $e');
        print('StackTrace: $stackTrace');
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _deleteCattle() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Está seguro de eliminar este animal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && widget.cattleToEdit != null) {
      final farmProvider = Provider.of<FarmProvider>(context, listen: false);
      await farmProvider.deleteCattle(widget.cattleToEdit!.id, farmId: widget.farm.id);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Animal eliminado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cattleToEdit == null ? 'Agregar Animal' : 'Editar Animal'),
        centerTitle: true,
        backgroundColor: widget.farm.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (widget.cattleToEdit != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteCattle,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Identificación DNI
            TextFormField(
              controller: _identificationController,
              decoration: const InputDecoration(
                labelText: 'DNI o ID (opcional)',
                hintText: 'Identificación única del animal',
                prefixIcon: Icon(Icons.credit_card),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Nombre
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre o Alias (opcional)',
                hintText: 'Nombre del animal',
                prefixIcon: Icon(Icons.label),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Categoría
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Categoría'),
                    Wrap(
                      children: [
                        RadioListTile<CattleCategory>(
                          title: const Text('Toro'),
                          value: CattleCategory.toro,
                          groupValue: _category,
                          onChanged: (value) => setState(() => _category = value!),
                        ),
                        RadioListTile<CattleCategory>(
                          title: const Text('Vaca'),
                          value: CattleCategory.vaca,
                          groupValue: _category,
                          onChanged: (value) => setState(() => _category = value!),
                        ),
                        RadioListTile<CattleCategory>(
                          title: const Text('Ternero'),
                          value: CattleCategory.ternero,
                          groupValue: _category,
                          onChanged: (value) => setState(() => _category = value!),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Género
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Género'),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<CattleGender>(
                            title: const Text('Macho'),
                            value: CattleGender.male,
                            groupValue: _gender,
                            onChanged: (value) => setState(() => _gender = value!),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<CattleGender>(
                            title: const Text('Hembra'),
                            value: CattleGender.female,
                            groupValue: _gender,
                            onChanged: (value) => setState(() => _gender = value!),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Fecha de nacimiento
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Fecha de nacimiento'),
                subtitle: Text(
                  _birthDate != null
                      ? DateFormat('dd/MM/yyyy').format(_birthDate!)
                      : 'No especificada',
                ),
                trailing: _birthDate != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _birthDate = null),
                      )
                    : null,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _birthDate ?? DateTime.now(),
                    firstDate: DateTime(2010),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => _birthDate = date);
                  }
                },
              ),
            ),
            const SizedBox(height: 16),

            // Peso actual
            TextFormField(
              controller: _weightController,
              decoration: const InputDecoration(
                labelText: 'Peso actual (kg)',
                hintText: 'Ingrese el peso',
                prefixIcon: Icon(Icons.monitor_weight),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El peso es requerido';
                }
                final weight = double.tryParse(value);
                if (weight == null || weight <= 0) {
                  return 'Ingrese un peso válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Etapa de producción
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Etapa de producción'),
                    RadioListTile<ProductionStage>(
                      title: const Text('Levante'),
                      value: ProductionStage.levante,
                      groupValue: _productionStage,
                      onChanged: (value) => setState(() => _productionStage = value!),
                    ),
                    RadioListTile<ProductionStage>(
                      title: const Text('Desarrollo'),
                      value: ProductionStage.desarrollo,
                      groupValue: _productionStage,
                      onChanged: (value) => setState(() => _productionStage = value!),
                    ),
                    if (_gender == CattleGender.female)
                      RadioListTile<ProductionStage>(
                        title: const Text('Reproductiva'),
                        value: ProductionStage.produccion,
                        groupValue: _productionStage,
                        onChanged: (value) => setState(() => _productionStage = value!),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Estado de salud
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Estado de salud'),
                    RadioListTile<HealthStatus>(
                      title: const Text('Sano'),
                      value: HealthStatus.sano,
                      groupValue: _healthStatus,
                      onChanged: (value) => setState(() => _healthStatus = value!),
                    ),
                    RadioListTile<HealthStatus>(
                      title: const Text('En tratamiento'),
                      value: HealthStatus.tratamiento,
                      groupValue: _healthStatus,
                      onChanged: (value) => setState(() => _healthStatus = value!),
                    ),
                    RadioListTile<HealthStatus>(
                      title: const Text('Enfermo'),
                      value: HealthStatus.enfermo,
                      groupValue: _healthStatus,
                      onChanged: (value) => setState(() => _healthStatus = value!),
                    ),
                  ],
                ),
              ),
            ),

            // Control reproductivo (solo hembras)
            if (_gender == CattleGender.female) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Estado reproductivo (solo hembras)'),
                      RadioListTile<BreedingStatus>(
                        title: const Text('Sin estado'),
                        value: BreedingStatus.vacia,
                        groupValue: _breedingStatus,
                        onChanged: (value) => setState(() => _breedingStatus = value),
                      ),
                      RadioListTile<BreedingStatus>(
                        title: const Text('En celo'),
                        value: BreedingStatus.enCelo,
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
                    ],
                  ),
                ),
              ),
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
            ],

            // Raza
            const SizedBox(height: 16),
            TextFormField(
              controller: _razaController,
              decoration: const InputDecoration(
                labelText: 'Raza (opcional)',
                hintText: 'Ej: Holstein, Angus, Brahman, etc.',
                prefixIcon: Icon(Icons.pets),
                border: OutlineInputBorder(),
              ),
            ),

            // Genealogía (Padres)
            const SizedBox(height: 24),
            Card(
              color: Colors.blue.shade50,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.account_tree, color: Colors.blue.shade700, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'Genealogía (Padres)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Vincula los padres de este animal si están registrados en el inventario.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Selector de Padre (Sire)
                    _buildParentSelector(
                      context,
                      label: 'Padre (Sire)',
                      icon: Icons.male,
                      selectedCattle: _selectedPadre,
                      requiredGender: CattleGender.male,
                      onSelect: (cattle) {
                        setState(() {
                          _selectedPadre = cattle;
                          // Actualizar nombrePadre si se selecciona
                          if (cattle != null) {
                            // El nombre se guardará automáticamente desde el objeto
                          }
                        });
                      },
                      onClear: () {
                        setState(() {
                          _selectedPadre = null;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    // Selector de Madre (Dam)
                    _buildParentSelector(
                      context,
                      label: 'Madre (Dam)',
                      icon: Icons.female,
                      selectedCattle: _selectedMadre,
                      requiredGender: CattleGender.female,
                      onSelect: (cattle) {
                        setState(() {
                          _selectedMadre = cattle;
                        });
                      },
                      onClear: () {
                        setState(() {
                          _selectedMadre = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Notas
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notas (opcional)',
                hintText: 'Información adicional',
                prefixIcon: Icon(Icons.note),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Botón de guardar
            ElevatedButton(
              onPressed: _isProcessing ? null : _saveCattle,
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

  Widget _buildParentSelector(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Cattle? selectedCattle,
    required CattleGender requiredGender,
    required Function(Cattle?) onSelect,
    required VoidCallback onClear,
  }) {
    return Consumer<FarmProvider>(
      builder: (context, farmProvider, _) {
        final updatedFarm = farmProvider.farms.firstWhere(
          (f) => f.id == widget.farm.id,
          orElse: () => widget.farm,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (context) => CattleSelectorModal(
                          farm: updatedFarm,
                          availableCattle: updatedFarm.cattle,
                          title: 'Seleccionar $label',
                          selectedCattleId: selectedCattle?.id,
                          requiredGender: requiredGender,
                          excludeCattle: widget.cattleToEdit,
                          onSelect: onSelect,
                        ),
                      );
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: selectedCattle == null ? 'Sin seleccionar' : label,
                        hintText: 'Toca para seleccionar',
                        prefixIcon: Icon(icon, color: widget.farm.primaryColor),
                        suffixIcon: selectedCattle != null
                            ? Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 20,
                              )
                            : const Icon(Icons.arrow_drop_down),
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: selectedCattle != null
                            ? Colors.green.shade50
                            : Colors.white,
                      ),
                      child: selectedCattle != null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  selectedCattle.name ?? selectedCattle.identification ?? 'Sin ID',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                if (selectedCattle.identification != null)
                                  Text(
                                    'Chapeta: ${selectedCattle.identification}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                if (selectedCattle.raza != null && selectedCattle.raza!.isNotEmpty)
                                  Text(
                                    'Raza: ${selectedCattle.raza}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                              ],
                            )
                          : Text(
                              'Toca para seleccionar',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                    ),
                  ),
                ),
                if (selectedCattle != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.clear, color: Colors.red),
                    tooltip: 'Borrar selección',
                    onPressed: onClear,
                  ),
                ],
              ],
            ),
          ],
        );
      },
    );
  }
}


