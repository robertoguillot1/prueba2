import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';
import '../models/worker.dart';
import '../models/loan.dart';
import '../utils/thousands_formatter.dart';

class LoanFormScreen extends StatefulWidget {
  final Farm farm;
  final Worker worker;
  final Loan? loanToEdit;

  const LoanFormScreen({
    super.key,
    required this.farm,
    required this.worker,
    this.loanToEdit,
  });

  @override
  State<LoanFormScreen> createState() => _LoanFormScreenState();
}

class _LoanFormScreenState extends State<LoanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime _loanDate = DateTime.now();
  LoanStatus _loanStatus = LoanStatus.pending;
  DateTime? _paidDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.loanToEdit != null) {
      _initializeWithLoan();
    }
  }

  void _initializeWithLoan() {
    final loan = widget.loanToEdit!;
    // Format amount with thousands separator
    final formattedAmount = NumberFormat('#,###').format(loan.amount.toInt());
    _amountController.text = formattedAmount;
    _descriptionController.text = loan.description;
    _notesController.text = loan.notes ?? '';
    _loanDate = loan.loanDate;
    _loanStatus = loan.status;
    _paidDate = loan.paidDate;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectLoanDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _loanDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _loanDate) {
      setState(() {
        _loanDate = picked;
      });
    }
  }

  Future<void> _selectPaidDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _paidDate ?? DateTime.now(),
      firstDate: _loanDate,
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _paidDate = picked;
        _loanStatus = LoanStatus.paid;
      });
    }
  }

  Future<void> _saveLoan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<FarmProvider>(context, listen: false);
      
      if (widget.loanToEdit == null) {
        // Create new loan
        final amountValue = ThousandsFormatter.getNumericValue(_amountController.text);
        final newLoan = Loan(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          workerId: widget.worker.id,
          farmId: widget.farm.id,
          date: _loanDate,
          amount: double.parse(amountValue),
          description: _descriptionController.text.trim(),
          status: _loanStatus,
          paymentDate: _paidDate,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        );
        
        await provider.addLoan(newLoan, farmId: widget.farm.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Préstamo registrado exitosamente')),
        );
      } else {
        // Update existing loan
        final amountValue = ThousandsFormatter.getNumericValue(_amountController.text);
        final updatedLoan = widget.loanToEdit!.copyWith(
          date: _loanDate,
          amount: double.parse(amountValue),
          description: _descriptionController.text.trim(),
          status: _loanStatus,
          paymentDate: _paidDate,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        );
        
        await provider.updateLoan(updatedLoan, farmId: widget.farm.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Préstamo actualizado exitosamente')),
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
        title: Text(widget.loanToEdit == null ? 'Registrar Préstamo' : 'Editar Préstamo'),
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
                  labelText: 'Monto del Préstamo',
                  hintText: 'Ingresa el monto prestado',
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

              // Loan date
              InkWell(
                onTap: _selectLoanDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha del Préstamo',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    DateFormat('dd/MM/yyyy').format(_loanDate),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción o Motivo',
                  hintText: 'Ej: Emergencia médica, gastos familiares, etc.',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresa la descripción';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Loan status
              Text(
                'Estado del Préstamo',
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
                    children: LoanStatus.values.map((status) {
                      return RadioListTile<LoanStatus>(
                        title: Text(status == LoanStatus.pending ? 'Pendiente' : 'Pagado'),
                        value: status,
                        groupValue: _loanStatus,
                        onChanged: (value) {
                          setState(() {
                            _loanStatus = value!;
                            if (value == LoanStatus.pending) {
                              _paidDate = null;
                            }
                          });
                        },
                        activeColor: widget.farm.primaryColor,
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Paid date (only if status is paid)
              if (_loanStatus == LoanStatus.paid) ...[
                InkWell(
                  onTap: _selectPaidDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Fecha de Pago',
                      prefixIcon: Icon(Icons.check_circle),
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      _paidDate != null 
                          ? DateFormat('dd/MM/yyyy').format(_paidDate!)
                          : 'Seleccionar fecha',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notas Adicionales (Opcional)',
                  hintText: 'Información adicional sobre el préstamo',
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
                  onPressed: _isLoading ? null : _saveLoan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.farm.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          widget.loanToEdit == null ? 'Registrar Préstamo' : 'Actualizar Préstamo',
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

