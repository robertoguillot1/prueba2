import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../features/trabajadores/domain/entities/pago.dart';
import '../cubits/pagos_cubit.dart';

class PagoFormScreen extends StatefulWidget {
  final String farmId;
  final String workerId;
  final Pago? pagoToEdit;

  const PagoFormScreen({
    super.key,
    required this.farmId,
    required this.workerId,
    this.pagoToEdit,
  });

  @override
  State<PagoFormScreen> createState() => _PagoFormScreenState();
}

class _PagoFormScreenState extends State<PagoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _conceptController = TextEditingController();
  final _notesController = TextEditingController();
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.pagoToEdit != null) {
      _amountController.text = widget.pagoToEdit!.amount.toString();
      _conceptController.text = widget.pagoToEdit!.concept;
      _notesController.text = widget.pagoToEdit!.notes ?? '';
      _selectedDate = widget.pagoToEdit!.date;
    } else {
      _selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _conceptController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DependencyInjection.createPagosCubit(),
      child: BlocListener<PagosCubit, PagosState>(
        listener: (context, state) {
          if (state is PagosLoaded) { // After successful op (though our cubit emits loaded after loadPagos, we need to handle success better)
             // Cubit creates -> then reloads -> emits Loaded.
             Navigator.pop(context, true);
          } else if (state is PagosError) {
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Builder(
          builder: (context) {
            return Scaffold(
              appBar: AppBar(title: Text(widget.pagoToEdit == null ? 'Nuevo Pago' : 'Editar Pago')),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        controller: _amountController,
                        decoration: const InputDecoration(labelText: 'Monto'),
                        keyboardType: TextInputType.number,
                        validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _conceptController,
                        decoration: const InputDecoration(labelText: 'Concepto (e.g. Salario, Bono)'),
                        validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        title: const Text('Fecha'),
                        subtitle: Text("${_selectedDate.toLocal()}".split(' ')[0]),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) setState(() => _selectedDate = picked);
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                         decoration: const InputDecoration(labelText: 'Notas (Opcional)'),
                         maxLines: 3,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final pago = Pago(
                              id: widget.pagoToEdit?.id ?? const Uuid().v4(),
                              workerId: widget.workerId,
                              farmId: widget.farmId,
                              amount: double.parse(_amountController.text),
                              date: _selectedDate,
                              concept: _conceptController.text,
                              notes: _notesController.text.isEmpty ? null : _notesController.text,
                            );
                            if (widget.pagoToEdit == null) {
                              context.read<PagosCubit>().registrarPago(pago);
                            } else {
                              context.read<PagosCubit>().actualizarPago(pago);
                            }
                          }
                        },
                        child: Text(widget.pagoToEdit == null ? 'Guardar' : 'Actualizar'),
                      )
                    ],
                  ),
                ),
              ),
            );
          }
        ),
      ),
    );
  }
}
