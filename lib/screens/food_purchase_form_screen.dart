import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';
import '../models/food_purchase.dart';

class FoodPurchaseFormScreen extends StatefulWidget {
  final Farm farm;

  const FoodPurchaseFormScreen({super.key, required this.farm});

  @override
  State<FoodPurchaseFormScreen> createState() => _FoodPurchaseFormScreenState();
}

class _FoodPurchaseFormScreenState extends State<FoodPurchaseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _foodTypeController;
  late TextEditingController _quantityController;
  late TextEditingController _priceController;
  late TextEditingController _supplierController;
  late TextEditingController _notesController;
  DateTime _purchaseDate = DateTime.now();
  bool _isProcessing = false;
  bool _isBulkPurchase = true; // true para bultos, false para kilos

  @override
  void initState() {
    super.initState();
    _foodTypeController = TextEditingController();
    _quantityController = TextEditingController();
    _priceController = TextEditingController();
    _supplierController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _foodTypeController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _supplierController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _savePurchase() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    try {
      final farmProvider = Provider.of<FarmProvider>(context, listen: false);
      final purchaseId = DateTime.now().millisecondsSinceEpoch.toString();
      
      final quantity = double.parse(_quantityController.text);
      final price = double.parse(_priceController.text);
      
      // Calcular según el tipo de compra
      double totalKg;
      double totalCost;
      
      if (_isBulkPurchase) {
        // Comprado en bultos
        totalKg = quantity * 40.0; // TODO: Usar AppConstants.bulkWeightKg después de agregar import
        totalCost = quantity * price; // Precio por bulto
      } else {
        // Comprado en kilos
        totalKg = quantity;
        totalCost = quantity * price; // Precio por kg
      }
      
      final purchase = FoodPurchase(
        id: purchaseId,
        farmId: widget.farm.id,
        date: _purchaseDate,
        amount: totalCost,
        quantity: totalKg,
        unit: _foodTypeController.text.isEmpty ? 'kg' : _foodTypeController.text,
        supplier: _supplierController.text.isEmpty ? null : _supplierController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      await farmProvider.addFoodPurchase(purchase);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Compra registrada exitosamente'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('💰 Registrar Compra de Alimento'),
        centerTitle: true,
        backgroundColor: widget.farm.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Fecha
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Fecha de compra'),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(_purchaseDate)),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _purchaseDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => _purchaseDate = date);
                  }
                },
              ),
            ),
            const SizedBox(height: 16),

            // Tipo de alimento
            TextFormField(
              controller: _foodTypeController,
              decoration: const InputDecoration(
                labelText: 'Tipo de alimento',
                hintText: 'Ej: Concentrado, Alimento completo, etc.',
                prefixIcon: Icon(Icons.restaurant_menu),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El tipo de alimento es requerido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Selector de tipo de compra
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tipo de compra',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<bool>(
                            title: const Text('Bultos'),
                            subtitle: const Text('1 bulto = 40 kg'),
                            value: true,
                            groupValue: _isBulkPurchase,
                            onChanged: (value) => setState(() => _isBulkPurchase = value!),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<bool>(
                            title: const Text('Kilos'),
                            subtitle: const Text('Compra suelta'),
                            value: false,
                            groupValue: _isBulkPurchase,
                            onChanged: (value) => setState(() => _isBulkPurchase = value!),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Cantidad
            TextFormField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: _isBulkPurchase ? 'Cantidad de bultos' : 'Cantidad (kg)',
                hintText: _isBulkPurchase ? 'Ej: 2, 5, 10' : 'Ej: 80, 160',
                prefixIcon: const Icon(Icons.scale),
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La cantidad es requerida';
                }
                final quantity = double.tryParse(value);
                if (quantity == null || quantity <= 0) {
                  return 'Ingrese una cantidad válida';
                }
                return null;
              },
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // Precio
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: _isBulkPurchase ? 'Precio por bulto' : 'Precio por kg',
                hintText: _isBulkPurchase ? 'Ej: 96000, 109000' : 'Ej: 2400, 2500',
                prefixIcon: const Icon(Icons.attach_money),
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El precio es requerido';
                }
                final price = double.tryParse(value);
                if (price == null || price <= 0) {
                  return 'Ingrese un precio válido';
                }
                return null;
              },
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // Proveedor
            TextFormField(
              controller: _supplierController,
              decoration: const InputDecoration(
                labelText: 'Proveedor (opcional)',
                hintText: 'Nombre del proveedor',
                prefixIcon: Icon(Icons.store),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Notas
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

            // Información calculada
            if (_quantityController.text.isNotEmpty && _priceController.text.isNotEmpty)
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildCalculatedInfo(),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Botón de guardar
            ElevatedButton(
              onPressed: _isProcessing ? null : _savePurchase,
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

  Widget _buildCalculatedInfo() {
    try {
      final quantity = double.parse(_quantityController.text);
      final price = double.parse(_priceController.text);
      
      double totalKg;
      double totalCost;
      double costPerKg;
      
      if (_isBulkPurchase) {
        totalKg = quantity * 40;
        totalCost = quantity * price;
      } else {
        totalKg = quantity;
        totalCost = quantity * price;
      }
      
      costPerKg = totalCost / totalKg;
      
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total en kg:'),
              Text(
                '${totalKg.toStringAsFixed(1)} kg',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total a pagar:'),
              Text(
                NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(totalCost),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Costo por kg:'),
              Text(
                NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(costPerKg),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ],
      );
    } catch (e) {
      return const SizedBox();
    }
  }
}

