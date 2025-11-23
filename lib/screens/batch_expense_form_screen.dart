import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';
import '../models/broiler_batch.dart';
import '../models/batch_expense.dart';
import '../utils/thousands_formatter.dart';

class BatchExpenseFormScreen extends StatefulWidget {
  final Farm farm;
  final BroilerBatch batch;
  final BatchExpense? expenseToEdit;

  const BatchExpenseFormScreen({
    super.key,
    required this.farm,
    required this.batch,
    this.expenseToEdit,
  });

  @override
  State<BatchExpenseFormScreen> createState() => _BatchExpenseFormScreenState();
}

class _BatchExpenseFormScreenState extends State<BatchExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _conceptoController = TextEditingController();
  final _montoController = TextEditingController();
  final _cantidadController = TextEditingController();
  final _stockAgregadoController = TextEditingController();

  BatchExpenseType _tipo = BatchExpenseType.alimento;
  DateTime _fecha = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.expenseToEdit != null) {
      final expense = widget.expenseToEdit!;
      _conceptoController.text = expense.concepto;
      _montoController.text = NumberFormat('#,###').format(expense.monto.toInt());
      if (expense.cantidad != null) {
        _cantidadController.text = expense.cantidad!.toStringAsFixed(2);
      }
      if (expense.stockAgregadoKg != null) {
        _stockAgregadoController.text = expense.stockAgregadoKg!.toStringAsFixed(2);
      }
      _tipo = expense.tipo;
      _fecha = expense.fecha;
    }
  }

  @override
  void dispose() {
    _conceptoController.dispose();
    _montoController.dispose();
    _cantidadController.dispose();
    _stockAgregadoController.dispose();
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

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final farmProvider = Provider.of<FarmProvider>(context, listen: false);
      final expenseId = widget.expenseToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString();

      final expense = BatchExpense(
        id: expenseId,
        batchId: widget.batch.id,
        farmId: widget.farm.id,
        tipo: _tipo,
        fecha: _fecha,
        concepto: _conceptoController.text.trim(),
        monto: double.parse(ThousandsFormatter.getNumericValue(_montoController.text)),
        cantidad: _cantidadController.text.isNotEmpty
            ? double.tryParse(_cantidadController.text)
            : null,
        stockAgregadoKg: _stockAgregadoController.text.isNotEmpty && _tipo == BatchExpenseType.alimento
            ? double.tryParse(_stockAgregadoController.text)
            : null,
        createdAt: widget.expenseToEdit?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Si es alimento y se agregó stock, actualizar el stock del lote
      if (_tipo == BatchExpenseType.alimento && expense.stockAgregadoKg != null) {
        // Primero actualizar el stock considerando el consumo desde la última actualización
        final batchActualizado = farmProvider.getBroilerBatchById(widget.batch.id, farmId: widget.farm.id) ?? widget.batch;
        final stockActualizado = batchActualizado.stockAlimentoActualKg;
        
        final updatedBatch = batchActualizado.copyWith(
          stockAlimentoKg: stockActualizado + expense.stockAgregadoKg!,
          ultimaActualizacionStock: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await farmProvider.updateBroilerBatch(updatedBatch, farmId: widget.farm.id);
      }

      if (widget.expenseToEdit != null) {
        await farmProvider.updateBatchExpense(expense, farmId: widget.farm.id);
      } else {
        await farmProvider.addBatchExpense(expense, farmId: widget.farm.id);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.expenseToEdit != null
                ? 'Gasto actualizado'
                : 'Gasto registrado exitosamente'),
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
        title: Text(widget.expenseToEdit != null ? 'Editar Gasto' : 'Registrar Gasto'),
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
              // Tipo de gasto - Botones rápidos
              Text(
                'Categoría',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: BatchExpenseType.values.map((type) {
                  final isSelected = _tipo == type;
                  return InkWell(
                    onTap: () => setState(() => _tipo = type),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? type.color : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? type.color : Colors.grey[300]!,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            type.icon,
                            color: isSelected ? Colors.white : type.color,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            type.displayName,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey[800],
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
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
                controller: _montoController,
                decoration: const InputDecoration(
                  labelText: 'Monto',
                  hintText: '0',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [ThousandsFormatter()],
                autofocus: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el monto';
                  }
                  final num = double.tryParse(ThousandsFormatter.getNumericValue(value));
                  if (num == null || num <= 0) {
                    return 'Por favor ingresa un valor válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _conceptoController,
                decoration: const InputDecoration(
                  labelText: 'Concepto',
                  hintText: 'Ej: Antibiótico, Bulto Inicio, etc.',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresa el concepto';
                  }
                  return null;
                },
              ),
              // Campos opcionales para alimento
              if (_tipo == BatchExpenseType.alimento) ...[
                const SizedBox(height: 16),
                // Mostrar sugerencia de tipo de alimento según etapa
                Consumer<FarmProvider>(
                  builder: (context, farmProvider, _) {
                    final batchActualizado = farmProvider.getBroilerBatchById(widget.batch.id, farmId: widget.farm.id) ?? widget.batch;
                    return Card(
                      color: Colors.blue[50],
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Etapa Actual: ${batchActualizado.etapaActualNombre}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[900],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tipo de Alimento Recomendado: ${batchActualizado.tipoAlimentoRecomendado}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue[800],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Bultos necesarios para esta etapa: ${batchActualizado.bultosNecesariosEtapaActual.toStringAsFixed(1)} bultos (40kg c/u)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[700],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cantidadController,
                  decoration: const InputDecoration(
                    labelText: 'Cantidad (Opcional)',
                    hintText: 'Ej: 1 bulto, 2 unidades',
                    prefixIcon: Icon(Icons.numbers),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _stockAgregadoController,
                  decoration: const InputDecoration(
                    labelText: 'Stock Agregado (kg) - Opcional',
                    hintText: 'Kg de alimento agregados al inventario',
                    prefixIcon: Icon(Icons.inventory),
                    border: OutlineInputBorder(),
                    helperText: 'Si ingresas este valor, se actualizará automáticamente el stock del lote',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveExpense,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.farm.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(widget.expenseToEdit != null ? 'Actualizar Gasto' : 'Registrar Gasto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

