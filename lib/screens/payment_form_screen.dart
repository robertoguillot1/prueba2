import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';
import '../models/worker.dart';
import '../models/payment.dart';
import '../utils/thousands_formatter.dart';

class PaymentFormScreen extends StatefulWidget {
  final Farm farm;
  final Worker worker;
  final Payment? paymentToEdit;

  const PaymentFormScreen({
    super.key,
    required this.farm,
    required this.worker,
    this.paymentToEdit,
  });

  @override
  State<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends State<PaymentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _observationsController = TextEditingController();
  
  DateTime _paymentDate = DateTime.now();
  PaymentType _paymentType = PaymentType.full;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.paymentToEdit != null) {
      _initializeWithPayment();
    }
  }

  void _initializeWithPayment() {
    final payment = widget.paymentToEdit!;
    // Format amount with thousands separator
    final formattedAmount = NumberFormat('#,###').format(payment.amount.toInt());
    _amountController.text = formattedAmount;
    _observationsController.text = payment.observations ?? '';
    _paymentDate = payment.paymentDate;
    _paymentType = PaymentTypeExtension.fromString(payment.type) ?? PaymentType.full;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _observationsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _paymentDate) {
      setState(() {
        _paymentDate = picked;
      });
    }
  }

  Future<void> _savePayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<FarmProvider>(context, listen: false);
      
      if (widget.paymentToEdit == null) {
        // Create new payment
        final amountValue = ThousandsFormatter.getNumericValue(_amountController.text);
        final newPayment = Payment(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          workerId: widget.worker.id,
          farmId: widget.farm.id,
          date: _paymentDate,
          amount: double.parse(amountValue),
          type: _paymentType.value,
          notes: _observationsController.text.trim().isEmpty ? null : _observationsController.text.trim(),
        );
        
        await provider.addPayment(newPayment, farmId: widget.farm.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pago registrado exitosamente')),
        );
      } else {
        // Update existing payment
        final amountValue = ThousandsFormatter.getNumericValue(_amountController.text);
        final updatedPayment = widget.paymentToEdit!.copyWith(
          date: _paymentDate,
          amount: double.parse(amountValue),
          notes: _observationsController.text.trim().isEmpty ? null : _observationsController.text.trim(),
          type: _paymentType.value,
        );
        
        await provider.updatePayment(updatedPayment, farmId: widget.farm.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pago actualizado exitosamente')),
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
        title: Text(widget.paymentToEdit == null ? 'Registrar Pago' : 'Editar Pago'),
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
              // Worker info
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: widget.farm.primaryColor.withOpacity(0.1),
                        child: Text(
                          widget.worker.fullName.isNotEmpty 
                              ? widget.worker.fullName[0].toUpperCase() 
                              : '?',
                          style: TextStyle(
                            color: widget.farm.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.worker.fullName,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.worker.position,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              'Salario: ${NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(widget.worker.salary)}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Amount
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Monto del Pago',
                  hintText: 'Ingresa el monto pagado',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  ThousandsFormatter(),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el monto';
                  }
                  final numericValue = ThousandsFormatter.getNumericValue(value);
                  final amount = double.tryParse(numericValue);
                  if (amount == null || amount <= 0) {
                    return 'Por favor ingresa un monto válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Payment date
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha del Pago',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    DateFormat('dd/MM/yyyy').format(_paymentDate),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Payment type
              Text(
                'Tipo de Pago',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: PaymentType.values.map((type) {
                      return RadioListTile<PaymentType>(
                        title: Text(type.displayName),
                        value: type,
                        groupValue: _paymentType,
                        onChanged: (value) {
                          setState(() {
                            _paymentType = value!;
                          });
                        },
                        activeColor: widget.farm.primaryColor,
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Observations
              TextFormField(
                controller: _observationsController,
                decoration: const InputDecoration(
                  labelText: 'Observaciones (Opcional)',
                  hintText: 'Notas adicionales sobre el pago',
                  prefixIcon: Icon(Icons.note),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _savePayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.farm.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          widget.paymentToEdit == null ? 'Registrar Pago' : 'Actualizar Pago',
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

