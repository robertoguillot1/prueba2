import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';
import '../models/broiler_batch.dart';
import '../utils/thousands_formatter.dart';

class BroilerBatchFormScreen extends StatefulWidget {
  final Farm farm;
  final BroilerBatch? batchToEdit;

  const BroilerBatchFormScreen({
    super.key,
    required this.farm,
    this.batchToEdit,
  });

  @override
  State<BroilerBatchFormScreen> createState() => _BroilerBatchFormScreenState();
}

class _BroilerBatchFormScreenState extends State<BroilerBatchFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreLoteController = TextEditingController();
  final _cantidadInicialController = TextEditingController();
  final _cantidadActualController = TextEditingController();
  final _edadInicialController = TextEditingController();
  final _pesoPromedioController = TextEditingController();
  final _metaPesoController = TextEditingController();
  final _metaSacrificioController = TextEditingController();
  final _stockAlimentoController = TextEditingController();
  final _costoCompraLoteController = TextEditingController();

  DateTime _fechaIngreso = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.batchToEdit != null) {
      final batch = widget.batchToEdit!;
      _nombreLoteController.text = batch.nombreLote;
      _cantidadInicialController.text = batch.cantidadInicial.toString();
      _cantidadActualController.text = batch.cantidadActual.toString();
      _edadInicialController.text = batch.edadInicialDias.toString();
      _pesoPromedioController.text = batch.pesoPromedioActual.toStringAsFixed(0); // En gramos
      _metaPesoController.text = batch.metaPesoGramos.toStringAsFixed(0); // En gramos
      _metaSacrificioController.text = batch.metaSacrificioDias.toString();
      _stockAlimentoController.text = batch.stockAlimentoKg.toStringAsFixed(2);
      _costoCompraLoteController.text = NumberFormat('#,###').format(batch.costoCompraLote.toInt());
      _fechaIngreso = batch.fechaIngreso;
    } else {
      _metaSacrificioController.text = '45'; // Valor por defecto
      _edadInicialController.text = '1'; // Valor por defecto
      _metaPesoController.text = '3000'; // 3 kg = 3000 gramos por defecto
    }
  }

  @override
  void dispose() {
    _nombreLoteController.dispose();
    _cantidadInicialController.dispose();
    _cantidadActualController.dispose();
    _edadInicialController.dispose();
    _pesoPromedioController.dispose();
    _metaPesoController.dispose();
    _metaSacrificioController.dispose();
    _stockAlimentoController.dispose();
    _costoCompraLoteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaIngreso,
      firstDate: DateTime(2020),
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

      // Al crear un nuevo lote, cantidad actual = cantidad inicial
      // Al editar, usar el valor del campo
      final cantidadInicial = int.parse(_cantidadInicialController.text.replaceAll(',', ''));
      final cantidadActual = widget.batchToEdit != null
          ? int.parse(_cantidadActualController.text.replaceAll(',', ''))
          : cantidadInicial; // Al crear, es igual a la inicial

      final batch = BroilerBatch(
        id: batchId,
        farmId: widget.farm.id,
        nombreLote: _nombreLoteController.text.trim(),
        fechaIngreso: _fechaIngreso,
        cantidadInicial: cantidadInicial,
        cantidadActual: cantidadActual,
        edadInicialDias: int.parse(_edadInicialController.text),
        pesoPromedioActual: double.parse(_pesoPromedioController.text.replaceAll(',', '')),
        metaPesoGramos: _metaPesoController.text.isNotEmpty
            ? double.parse(_metaPesoController.text.replaceAll(',', ''))
            : 3000.0, // Por defecto 3kg = 3000g
        metaSacrificioDias: int.parse(_metaSacrificioController.text),
        stockAlimentoKg: widget.batchToEdit != null
            ? double.parse(_stockAlimentoController.text)
            : 0.0, // Al crear, stock inicial es 0
        costoCompraLote: _costoCompraLoteController.text.isNotEmpty
            ? double.parse(ThousandsFormatter.getNumericValue(_costoCompraLoteController.text))
            : 0.0,
        ultimaActualizacionStock: widget.batchToEdit?.ultimaActualizacionStock ?? DateTime.now(),
        createdAt: widget.batchToEdit?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.batchToEdit != null) {
        await farmProvider.updateBroilerBatch(batch, farmId: widget.farm.id);
      } else {
        await farmProvider.addBroilerBatch(batch, farmId: widget.farm.id);
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
        title: Text(widget.batchToEdit != null ? 'Editar Lote' : 'Nuevo Lote de Engorde'),
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
                  hintText: 'Ej: Lote 001 - Enero 2024',
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
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha de Ingreso',
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
                controller: _cantidadInicialController,
                decoration: const InputDecoration(
                  labelText: 'Cantidad Inicial',
                  hintText: 'Número de pollos al ingresar',
                  prefixIcon: Icon(Icons.numbers),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [ThousandsFormatter()],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la cantidad inicial';
                  }
                  final num = int.tryParse(ThousandsFormatter.getNumericValue(value));
                  if (num == null || num <= 0) {
                    return 'Por favor ingresa un número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Solo mostrar cantidad actual si se está editando
              if (widget.batchToEdit != null) ...[
                TextFormField(
                  controller: _cantidadActualController,
                  decoration: const InputDecoration(
                    labelText: 'Cantidad Actual',
                    hintText: 'Pollos vivos actualmente',
                    prefixIcon: Icon(Icons.pets),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [ThousandsFormatter()],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa la cantidad actual';
                    }
                    final num = int.tryParse(ThousandsFormatter.getNumericValue(value));
                    if (num == null || num <= 0) {
                      return 'Por favor ingresa un número válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _edadInicialController,
                decoration: const InputDecoration(
                  labelText: 'Edad Inicial (días)',
                  hintText: 'Edad que tenían al llegar',
                  prefixIcon: Icon(Icons.calendar_view_day),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la edad inicial';
                  }
                  final num = int.tryParse(value);
                  if (num == null || num < 0) {
                    return 'Por favor ingresa un número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pesoPromedioController,
                decoration: const InputDecoration(
                  labelText: 'Peso Promedio Actual (gramos)',
                  hintText: 'Ej: 50, 100, 200',
                  prefixIcon: Icon(Icons.monitor_weight),
                  border: OutlineInputBorder(),
                  helperText: 'Ingresa el peso en gramos (ej: 50g, 100g)',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [ThousandsFormatter()],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el peso promedio';
                  }
                  final num = double.tryParse(ThousandsFormatter.getNumericValue(value));
                  if (num == null || num <= 0) {
                    return 'Por favor ingresa un peso válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _metaPesoController,
                decoration: const InputDecoration(
                  labelText: 'Meta de Peso (gramos)',
                  hintText: 'Ej: 3000 (3 kg)',
                  prefixIcon: Icon(Icons.track_changes),
                  border: OutlineInputBorder(),
                  helperText: 'Peso objetivo al momento del sacrificio. Por defecto: 3000g (3kg)',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [ThousandsFormatter()],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la meta de peso';
                  }
                  final num = double.tryParse(ThousandsFormatter.getNumericValue(value));
                  if (num == null || num <= 0) {
                    return 'Por favor ingresa un peso válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _metaSacrificioController,
                decoration: const InputDecoration(
                  labelText: 'Meta de Sacrificio (días)',
                  hintText: 'Generalmente 45 días',
                  prefixIcon: Icon(Icons.flag),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la meta de sacrificio';
                  }
                  final num = int.tryParse(value);
                  if (num == null || num <= 0) {
                    return 'Por favor ingresa un número válido';
                  }
                  return null;
                },
              ),
              // Solo mostrar stock de alimento al editar
              if (widget.batchToEdit != null) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _stockAlimentoController,
                  decoration: const InputDecoration(
                    labelText: 'Stock de Alimento (kg)',
                    hintText: '0.00',
                    prefixIcon: Icon(Icons.inventory),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa el stock de alimento';
                    }
                    final num = double.tryParse(value);
                    if (num == null || num < 0) {
                      return 'Por favor ingresa un valor válido';
                    }
                    return null;
                  },
                ),
              ],
              // Información sobre consumo automático
              const SizedBox(height: 16),
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'El consumo de alimento se calcula automáticamente según la edad del lote usando una tabla de referencia estándar.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _costoCompraLoteController,
                decoration: const InputDecoration(
                  labelText: 'Costo de Compra del Lote',
                  hintText: 'Costo de los pollitos al inicio',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [ThousandsFormatter()],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el costo de compra';
                  }
                  final num = double.tryParse(ThousandsFormatter.getNumericValue(value));
                  if (num == null || num < 0) {
                    return 'Por favor ingresa un valor válido';
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

