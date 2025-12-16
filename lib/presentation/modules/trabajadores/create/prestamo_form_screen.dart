import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../features/trabajadores/domain/entities/prestamo.dart';
import '../cubits/prestamos_cubit.dart';

class PrestamoFormScreen extends StatefulWidget {
  final String farmId;
  final String workerId;

  const PrestamoFormScreen({super.key, required this.farmId, required this.workerId});

  @override
  State<PrestamoFormScreen> createState() => _PrestamoFormScreenState();
}

class _PrestamoFormScreenState extends State<PrestamoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DependencyInjection.createPrestamosCubit(),
      child: BlocListener<PrestamosCubit, PrestamosState>(
        listener: (context, state) {
           if (state is PrestamosLoaded) { // Success
             Navigator.pop(context, true);
           } else if (state is PrestamosError) {
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
           }
        },
        child: Builder(
          builder: (context) {
            return Scaffold(
              appBar: AppBar(title: const Text('Nuevo Préstamo')),
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
                        controller: _descriptionController,
                        decoration: const InputDecoration(labelText: 'Descripción/Motivo'),
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
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final prestamo = Prestamo(
                              id: const Uuid().v4(),
                              workerId: widget.workerId,
                              farmId: widget.farmId,
                              amount: double.parse(_amountController.text),
                              date: _selectedDate,
                              description: _descriptionController.text,
                              isPaid: false,
                            );
                            context.read<PrestamosCubit>().registrarPrestamo(prestamo);
                          }
                        },
                        child: const Text('Guardar'),
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
