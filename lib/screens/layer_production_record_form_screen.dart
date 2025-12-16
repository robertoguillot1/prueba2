import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';
import '../models/layer_batch.dart';
import '../models/layer_production_record.dart';
import '../utils/thousands_formatter.dart';

class LayerProductionRecordFormScreen extends StatefulWidget {
  final Farm farm;
  final LayerBatch batch;
  final LayerProductionRecord? recordToEdit;

  const LayerProductionRecordFormScreen({
    super.key,
    required this.farm,
    required this.batch,
    this.recordToEdit,
  });

  @override
  State<LayerProductionRecordFormScreen> createState() => _LayerProductionRecordFormScreenState();
}

class _LayerProductionRecordFormScreenState extends State<LayerProductionRecordFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cantidadHuevosController = TextEditingController();
  final _cantidadHuevosRotosController = TextEditingController();
  final _alimentoConsumidoController = TextEditingController();
  final _precioPorCartonController = TextEditingController();
  final _observacionesController = TextEditingController();

  DateTime _fecha = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.recordToEdit != null) {
      final record = widget.recordToEdit!;
      _cantidadHuevosController.text = record.cantidadHuevos.toString();
      _cantidadHuevosRotosController.text = record.cantidadHuevosRotos.toString();
      _alimentoConsumidoController.text = record.alimentoConsumidoKg.toStringAsFixed(2);
      if (record.precioPorCarton != null) {
        _precioPorCartonController.text = record.precioPorCarton!.toStringAsFixed(0);
      }
      _observacionesController.text = record.observaciones ?? '';
      _fecha = record.fecha;
    } else {
      // Usar precio del lote si está configurado
      if (widget.batch.precioPorCarton != null) {
        _precioPorCartonController.text = widget.batch.precioPorCarton!.toStringAsFixed(0);
      }
    }
  }

  @override
  void dispose() {
    _cantidadHuevosController.dispose();
    _cantidadHuevosRotosController.dispose();
    _alimentoConsumidoController.dispose();
    _precioPorCartonController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _fecha = picked;
      });
    }
  }

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final farmProvider = Provider.of<FarmProvider>(context, listen: false);
      final recordId = widget.recordToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString();

      final record = LayerProductionRecord(
        id: recordId,
        layerBatchId: widget.batch.id,
        farmId: widget.farm.id,
        fecha: _fecha,
        cantidadHuevos: int.parse(_cantidadHuevosController.text.replaceAll(',', '')),
        cantidadHuevosRotos: int.parse(_cantidadHuevosRotosController.text.replaceAll(',', '')),
        alimentoConsumidoKg: double.parse(_alimentoConsumidoController.text),
        precioPorCarton: _precioPorCartonController.text.isNotEmpty
            ? double.tryParse(_precioPorCartonController.text.replaceAll(',', ''))
            : null,
        observaciones: _observacionesController.text.trim().isEmpty
            ? null
            : _observacionesController.text.trim(),
      );

      if (widget.recordToEdit != null) {
        await farmProvider.updateLayerProductionRecord(record, farmId: widget.farm.id);
      } else {
        await farmProvider.addLayerProductionRecord(record, farmId: widget.farm.id);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.recordToEdit != null
                ? 'Registro actualizado'
                : 'Producción registrada exitosamente'),
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
    final cartones = _cantidadHuevosController.text.isNotEmpty
        ? (int.tryParse(_cantidadHuevosController.text.replaceAll(',', '')) ?? 0) ~/ 30
        : 0;
    final huevosSueltos = _cantidadHuevosController.text.isNotEmpty
        ? (int.tryParse(_cantidadHuevosController.text.replaceAll(',', '')) ?? 0) % 30
        : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recordToEdit != null ? 'Editar Registro' : 'Registrar Producción'),
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
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('dd/MM/yyyy').format(_fecha)),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cantidadHuevosController,
                decoration: const InputDecoration(
                  labelText: 'Cantidad de Huevos',
                  hintText: 'Total de huevos recogidos',
                  prefixIcon: Icon(Icons.egg),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [ThousandsFormatter()],
                onChanged: (_) => setState(() {}),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la cantidad de huevos';
                  }
                  final num = int.tryParse(ThousandsFormatter.getNumericValue(value));
                  if (num == null || num < 0) {
                    return 'Por favor ingresa un número válido';
                  }
                  return null;
                },
              ),
              if (_cantidadHuevosController.text.isNotEmpty && int.tryParse(_cantidadHuevosController.text.replaceAll(',', '')) != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.farm.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Equivale a: $cartones cartones y $huevosSueltos huevos sueltos',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: widget.farm.primaryColor,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _cantidadHuevosRotosController,
                decoration: const InputDecoration(
                  labelText: 'Cantidad de Huevos Rotos',
                  hintText: '0',
                  prefixIcon: Icon(Icons.broken_image),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [ThousandsFormatter()],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la cantidad (puede ser 0)';
                  }
                  final num = int.tryParse(ThousandsFormatter.getNumericValue(value));
                  if (num == null || num < 0) {
                    return 'Por favor ingresa un número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _alimentoConsumidoController,
                decoration: const InputDecoration(
                  labelText: 'Alimento Consumido (kg)',
                  hintText: '0.00',
                  prefixIcon: Icon(Icons.restaurant),
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el alimento consumido';
                  }
                  final num = double.tryParse(value);
                  if (num == null || num < 0) {
                    return 'Por favor ingresa un valor válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _precioPorCartonController,
                decoration: const InputDecoration(
                  labelText: 'Precio por Cartón - Opcional',
                  hintText: 'Precio de venta del día',
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
              if (_precioPorCartonController.text.isNotEmpty &&
                  _cantidadHuevosController.text.isNotEmpty) ...[
                const SizedBox(height: 8),
                Builder(
                  builder: (context) {
                    final precio = double.tryParse(_precioPorCartonController.text.replaceAll(',', ''));
                    final huevos = int.tryParse(_cantidadHuevosController.text.replaceAll(',', ''));
                    if (precio != null && huevos != null) {
                      final ganancia = (huevos ~/ 30) * precio;
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Ganancia estimada: ${NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(ganancia)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _observacionesController,
                decoration: const InputDecoration(
                  labelText: 'Observaciones - Opcional',
                  hintText: 'Notas adicionales',
                  prefixIcon: Icon(Icons.note),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveRecord,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.farm.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(widget.recordToEdit != null ? 'Actualizar Registro' : 'Registrar Producción'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

