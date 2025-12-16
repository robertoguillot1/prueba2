import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../features/trabajadores/domain/entities/pago.dart';
import '../cubits/pagos_cubit.dart';
import '../create/pago_form_screen.dart';

class PagosListScreen extends StatelessWidget {
  final String farmId;
  final String workerId; // Optional: filter by worker

  const PagosListScreen({super.key, required this.farmId, required this.workerId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DependencyInjection.createPagosCubit()..loadPagos(workerId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Historial de Pagos'),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PagoFormScreen(farmId: farmId, workerId: workerId),
              ),
            ).then((value) {
              if (value == true && context.mounted) {
                context.read<PagosCubit>().loadPagos(workerId);
              }
            });
          },
          label: const Text('Registrar Pago'),
          icon: const Icon(Icons.add),
        ),
        body: BlocBuilder<PagosCubit, PagosState>(
          builder: (context, state) {
            if (state is PagosLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is PagosError) {
              return Center(child: Text(state.message));
            } else if (state is PagosLoaded) {
              if (state.pagos.isEmpty) {
                return const Center(child: Text('No hay pagos registrados'));
              }
              final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
              final dateFormat = DateFormat('dd/MM/yyyy');

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.pagos.length,
                itemBuilder: (context, index) {
                  final pago = state.pagos[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(Icons.attach_money, color: Colors.white),
                      ),
                      title: Text(currencyFormat.format(pago.amount)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(pago.concept),
                          Text(dateFormat.format(pago.date)),
                          if (pago.notes != null && pago.notes!.isNotEmpty)
                            Text(
                              pago.notes!,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                        ],
                      ),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 8),
                                Text('Editar'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Eliminar', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'edit') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PagoFormScreen(
                                  farmId: farmId,
                                  workerId: workerId,
                                  pagoToEdit: pago,
                                ),
                              ),
                            ).then((value) {
                              if (value == true && context.mounted) {
                                context.read<PagosCubit>().loadPagos(workerId);
                              }
                            });
                          } else if (value == 'delete') {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Confirmar Eliminación'),
                                content: const Text('¿Estás seguro de eliminar este pago?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancelar'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      context.read<PagosCubit>().eliminarPago(workerId, pago.id);
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                    child: const Text('Eliminar'),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
