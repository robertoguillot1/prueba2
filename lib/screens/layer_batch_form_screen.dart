import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';
import '../models/layer_batch.dart';
import '../utils/thousands_formatter.dart';

class LayerBatchFormScreen extends StatefulWidget {
  final Farm farm;
  final LayerBatch? batchToEdit;

  const LayerBatchFormScreen({
    super.key,
    required this.farm,
    this.batchToEdit,
  });

  @override
  State<LayerBatchFormScreen> createState() => _LayerBatchFormScreenState();
}

class _LayerBatchFormScreenState extends State<LayerBatchFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreLoteController = TextEditingController();
  final _cantidadGallinasController = TextEditingController();
  final _precioPorCartonController = TextEditingController();

  DateTime _fechaNacimiento = DateTime.now();
  DateTime _fechaIngreso = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.batchToEdit != null) {
      final batch = widget.batchToEdit!;
      _nombreLoteController.text = batch.nombreLote;
      _cantidadGallinasController.text = batch.cantidadGallinas.toString();
      if (batch.precioPorCarton != null) {
        _precioPorCartonController.text = batch.precioPorCarton!.toStringAsFixed(0);
      }
      _fechaNacimiento = batch.fechaNacimiento;
      _fechaIngreso = batch.fechaIngreso;
    }
  }

  @override
  void dispose() {
    _nombreLoteController.dispose();
    _cantidadGallinasController.dispose();
    _precioPorCartonController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _fechaNacimiento = picked;
      });
    }
  }

  Future<void> _selectIngressDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaIngreso,
      firstDate: _fechaNacimiento,
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _fechaIngreso = picked;
      });
    }
  }

  Future<void> _saveBatch() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final farmProvider = Provider.of<FarmProvider>(context, listen: false);
      final batchId = widget.batchToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString();

      final batch = LayerBatch(
        id: batchId,
        farmId: widget.farm.id,
        nombreLote: _nombreLoteController.text.trim(),
        fechaIngreso: _fechaIngreso,
        fechaNacimiento: _fechaNacimiento,
        cantidadGallinas: int.parse(_cantidadGallinasController.text.replaceAll(',', '')),
        precioPorCarton: _precioPorCartonController.text.isNotEmpty
            ? double.tryParse(_precioPorCartonController.text.replaceAll(',', ''))
            : null,
        createdAt: widget.batchToEdit?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.batchToEdit != null) {
        await farmProvider.updateLayerBatch(batch, farmId: widget.farm.id);
      } else {
        await farmProvider.addLayerBatch(batch, farmId: widget.farm.id);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.batchToEdit != null
                ? 'Lote actualizado'
                : 'Lote creado exitosamente'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.batchToEdit != null ? 'Editar Lote' : 'Nuevo Lote de Ponedoras'),
        backgroundColor: widget.farm.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nombreLoteController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Lote',
                  hintText: 'Ej: Lote Ponedoras 001',
                  prefixIcon: Icon(Icons.label),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresa el nombre del lote';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectBirthDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha de Nacimiento',
                    prefixIcon: Icon(Icons.cake),
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('dd/MM/yyyy').format(_fechaNacimiento)),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectIngressDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha de Ingreso al Lote',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('dd/MM/yyyy').format(_fechaIngreso)),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cantidadGallinasController,
                decoration: const InputDecoration(
                  labelText: 'Cantidad de Gallinas',
                  hintText: 'Número de gallinas en el lote',
                  prefixIcon: Icon(Icons.pets),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [ThousandsFormatter()],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la cantidad de gallinas';
                  }
                  final num = int.tryParse(ThousandsFormatter.getNumericValue(value));
                  if (num == null || num <= 0) {
                    return 'Por favor ingresa un número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _precioPorCartonController,
                decoration: const InputDecoration(
                  labelText: 'Precio por Cartón - Opcional',
                  hintText: 'Precio de venta por cartón (30 huevos)',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [ThousandsFormatter()],
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final num = double.tryParse(ThousandsFormatter.getNumericValue(value));
                    if (num == null || num <= 0) {
                      return 'Por favor ingresa un precio válido';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveBatch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.farm.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(widget.batchToEdit != null ? 'Actualizar Lote' : 'Crear Lote'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

