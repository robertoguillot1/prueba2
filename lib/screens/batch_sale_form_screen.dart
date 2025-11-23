import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';
import '../models/broiler_batch.dart';
import '../models/batch_sale.dart';
import '../utils/thousands_formatter.dart';

class BatchSaleFormScreen extends StatefulWidget {
  final Farm farm;
  final BroilerBatch batch;
  final BatchSale? saleToEdit;

  const BatchSaleFormScreen({
    super.key,
    required this.farm,
    required this.batch,
    this.saleToEdit,
  });

  @override
  State<BatchSaleFormScreen> createState() => _BatchSaleFormScreenState();
}

class _BatchSaleFormScreenState extends State<BatchSaleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pesoTotalController = TextEditingController();
  final _precioPorKiloController = TextEditingController();
  final _cantidadPollosController = TextEditingController();
  final _observacionesController = TextEditingController();

  DateTime _fechaVenta = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.saleToEdit != null) {
      final sale = widget.saleToEdit!;
      _pesoTotalController.text = sale.pesoTotalVendido.toStringAsFixed(2);
      _precioPorKiloController.text = NumberFormat('#,###').format(sale.precioPorKilo.toInt());
      _cantidadPollosController.text = sale.cantidadPollosVendidos.toString();
      _observacionesController.text = sale.observaciones ?? '';
      _fechaVenta = sale.fechaVenta;
    } else {
      // Pre-llenar cantidad de pollos con la cantidad actual del lote
      _cantidadPollosController.text = widget.batch.cantidadActual.toString();
    }
  }

  @override
  void dispose() {
    _pesoTotalController.dispose();
    _precioPorKiloController.dispose();
    _cantidadPollosController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaVenta,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _fechaVenta = picked;
      });
    }
  }

  Future<void> _saveSale() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final farmProvider = Provider.of<FarmProvider>(context, listen: false);
      final saleId = widget.saleToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString();

      final sale = BatchSale(
        id: saleId,
        batchId: widget.batch.id,
        farmId: widget.farm.id,
        pesoTotalVendido: double.parse(_pesoTotalController.text),
        precioPorKilo: double.parse(ThousandsFormatter.getNumericValue(_precioPorKiloController.text)),
        cantidadPollosVendidos: int.parse(_cantidadPollosController.text.replaceAll(',', '')),
        fechaVenta: _fechaVenta,
        observaciones: _observacionesController.text.trim().isEmpty
            ? null
            : _observacionesController.text.trim(),
        createdAt: widget.saleToEdit?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.saleToEdit != null) {
        await farmProvider.updateBatchSale(sale, farmId: widget.farm.id);
      } else {
        await farmProvider.addBatchSale(sale, farmId: widget.farm.id);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.saleToEdit != null
                ? 'Venta actualizada'
                : 'Lote cerrado y vendido exitosamente'),
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

  double get _totalVenta {
    final peso = double.tryParse(_pesoTotalController.text);
    final precio = double.tryParse(ThousandsFormatter.getNumericValue(_precioPorKiloController.text));
    if (peso != null && precio != null && peso > 0 && precio > 0) {
      return peso * precio;
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.saleToEdit != null ? 'Editar Venta' : 'Cerrar/Vender Lote'),
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
                    labelText: 'Fecha de Venta',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('dd/MM/yyyy').format(_fechaVenta)),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pesoTotalController,
                decoration: const InputDecoration(
                  labelText: 'Peso Total Vendido (kg)',
                  hintText: '0.00',
                  prefixIcon: Icon(Icons.monitor_weight),
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setState(() {}),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el peso total';
                  }
                  final num = double.tryParse(value);
                  if (num == null || num <= 0) {
                    return 'Por favor ingresa un peso válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _precioPorKiloController,
                decoration: const InputDecoration(
                  labelText: 'Precio por Kilo',
                  hintText: '0',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [ThousandsFormatter()],
                onChanged: (_) => setState(() {}),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el precio por kilo';
                  }
                  final num = double.tryParse(ThousandsFormatter.getNumericValue(value));
                  if (num == null || num <= 0) {
                    return 'Por favor ingresa un precio válido';
                  }
                  return null;
                },
              ),
              if (_pesoTotalController.text.isNotEmpty && _precioPorKiloController.text.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calculate, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        'Total Venta: ${NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(_totalVenta)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _cantidadPollosController,
                decoration: const InputDecoration(
                  labelText: 'Cantidad de Pollos Vendidos',
                  hintText: 'Número de pollos',
                  prefixIcon: Icon(Icons.pets),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [ThousandsFormatter()],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la cantidad de pollos';
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
                controller: _observacionesController,
                decoration: const InputDecoration(
                  labelText: 'Observaciones - Opcional',
                  hintText: 'Notas adicionales sobre la venta',
                  prefixIcon: Icon(Icons.note),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveSale,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.farm.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(widget.saleToEdit != null ? 'Actualizar Venta' : 'Cerrar y Vender Lote'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

