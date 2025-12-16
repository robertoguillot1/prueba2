import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../features/trabajadores/domain/entities/prestamo.dart';
import '../cubits/prestamos_cubit.dart';
import '../create/prestamo_form_screen.dart';

class PrestamosListScreen extends StatelessWidget {
  final String farmId;
  final String workerId;

  const PrestamosListScreen({super.key, required this.farmId, required this.workerId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DependencyInjection.createPrestamosCubit()..loadPrestamos(workerId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Control de Préstamos'),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PrestamoFormScreen(farmId: farmId, workerId: workerId),
              ),
            ).then((value) {
              if (value == true && context.mounted) {
                context.read<PrestamosCubit>().loadPrestamos(workerId);
              }
            });
          },
          label: const Text('Nuevo Préstamo'),
          icon: const Icon(Icons.add),
        ),
        body: BlocBuilder<PrestamosCubit, PrestamosState>(
          builder: (context, state) {
             if (state is PrestamosLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is PrestamosError) {
              return Center(child: Text(state.message));
            } else if (state is PrestamosLoaded) {
               // Show debt summary
              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: Colors.red.shade50,
                    child: Column(
                      children: [
                        const Text('Deuda Total Pendiente', style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        Text(
                          NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(state.totalDebt),
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red.shade800),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.prestamos.length,
                      itemBuilder: (context, index) {
                        final prestamo = state.prestamos[index];
                        return _buildLoanCard(context, prestamo);
                      },
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildLoanCard(BuildContext context, Prestamo prestamo) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: prestamo.isPaid ? Colors.green : Colors.orange,
          child: Icon(
            prestamo.isPaid ? Icons.check : Icons.access_time,
            color: Colors.white,
          ),
        ),
        title: Text(currencyFormat.format(prestamo.amount), style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(prestamo.description),
            Text(dateFormat.format(prestamo.date)),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            if (!prestamo.isPaid)
              const PopupMenuItem(
                value: 'pay',
                child: Row(
                  children: [
                    Icon(Icons.check, size: 20),
                    SizedBox(width: 8),
                    Text('Marcar como Pagado'),
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
            if (value == 'pay') {
              context.read<PrestamosCubit>().marcarComoPagado(prestamo);
            } else if (value == 'delete') {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirmar Eliminación'),
                  content: const Text('¿Estás seguro de eliminar este préstamo?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.read<PrestamosCubit>().eliminarPrestamo(workerId, prestamo.id);
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
          child: !prestamo.isPaid
              ? const Icon(Icons.more_vert)
              : const Text('Pagado', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
