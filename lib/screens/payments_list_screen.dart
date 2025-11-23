import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';
import '../models/payment.dart';
import '../widgets/payment_card.dart';
import 'payment_form_screen.dart';

class PaymentsListScreen extends StatelessWidget {
  final Farm farm;

  const PaymentsListScreen({super.key, required this.farm});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pagos - ${farm.name}'),
        centerTitle: true,
        backgroundColor: farm.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<FarmProvider>(
        builder: (context, farmProvider, _child) {
          // Get the updated farm from provider to ensure we see the latest payments
          final updatedFarm = farmProvider.farms.firstWhere(
            (f) => f.id == farm.id,
            orElse: () => farm,
          );
          final payments = updatedFarm.payments.toList()
            ..sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
          
          if (payments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.payments_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay pagos registrados',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Los pagos aparecerán aquí cuando se registren',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Summary card
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'Total Pagado (Mes)',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                NumberFormat.currency(symbol: '\$', decimalDigits: 0)
                                    .format(updatedFarm.totalPaidThisMonth),
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 40,
                          width: 1,
                          color: Colors.grey[300],
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'Total Pagos',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                '${payments.length}',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: updatedFarm.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Payments list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: payments.length,
                  itemBuilder: (context, index) {
                    final payment = payments[index];
                    final worker = farmProvider.getWorkerById(payment.workerId);
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: PaymentCard(
                        payment: payment,
                        worker: worker,
                        farm: updatedFarm,
                        onTap: () {
                          if (worker != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PaymentFormScreen(
                                  farm: farm,
                                  worker: worker,
                                  paymentToEdit: payment,
                                ),
                              ),
                            );
                          }
                        },
                        onDelete: () => _confirmDelete(context, farmProvider, payment),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showWorkerSelection(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Registrar Pago'),
        backgroundColor: farm.primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _showWorkerSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Consumer<FarmProvider>(
          builder: (context, farmProvider, _child) {
          // Get the updated farm
          final updatedFarm = farmProvider.farms.firstWhere(
            (f) => f.id == farm.id,
            orElse: () => farm,
          );
          final activeWorkers = updatedFarm.activeWorkers;
          
          if (activeWorkers.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: const Center(
                child: Text('No hay trabajadores activos para registrar pagos'),
              ),
            );
          }

          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Seleccionar Trabajador',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...activeWorkers.map((worker) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: updatedFarm.primaryColor.withOpacity(0.1),
                      child: Text(
                        worker.fullName.isNotEmpty ? worker.fullName[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: updatedFarm.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(worker.fullName),
                    subtitle: Text(worker.position),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentFormScreen(
                            farm: updatedFarm,
                            worker: worker,
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, FarmProvider farmProvider, Payment payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Pago'),
        content: Text(
          '¿Estás seguro de que quieres eliminar este pago de '
          '${NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(payment.amount)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await farmProvider.deletePayment(payment.id, farmId: farm.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pago eliminado')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

