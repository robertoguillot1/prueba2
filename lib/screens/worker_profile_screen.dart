import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';
import '../models/worker.dart';
import '../models/loan.dart';
import '../widgets/summary_card.dart';
import 'payment_form_screen.dart';
import 'worker_form_screen.dart';
import 'loan_form_screen.dart';

class WorkerProfileScreen extends StatelessWidget {
  final Worker worker;
  final Farm farm;

  const WorkerProfileScreen({
    super.key,
    required this.worker,
    required this.farm,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<FarmProvider>(
      builder: (context, farmProvider, _child) {
        // Get the updated farm and worker from provider to ensure we see the latest data
        final updatedFarm = farmProvider.farms.firstWhere(
          (f) => f.id == farm.id,
          orElse: () => farm,
        );
        final updatedWorker = updatedFarm.workers.firstWhere(
          (w) => w.id == worker.id,
          orElse: () => worker,
        );
        
        final payments = farmProvider.getPaymentsByWorker(updatedWorker.id, farmId: updatedFarm.id);
        final loans = farmProvider.getLoansByWorker(updatedWorker.id, farmId: updatedFarm.id);
        final totalPaid = farmProvider.getWorkerTotalPaid(updatedWorker.id, farmId: updatedFarm.id);
        final pendingLoans = farmProvider.getWorkerPendingLoans(updatedWorker.id, farmId: updatedFarm.id);
        final netSalary = farmProvider.getWorkerNetSalary(updatedWorker.id, farmId: updatedFarm.id);

        return Scaffold(
          appBar: AppBar(
            title: Text(updatedWorker.fullName),
            centerTitle: true,
            backgroundColor: updatedFarm.primaryColor,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WorkerFormScreen(
                        farm: updatedFarm,
                        workerToEdit: updatedWorker,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Worker header
                _buildWorkerHeader(context, updatedWorker, updatedFarm),
                const SizedBox(height: 24),

                // Quick stats
                _buildQuickStats(context, totalPaid, pendingLoans, netSalary),
                const SizedBox(height: 24),

                // Action buttons
                _buildActionButtons(context, updatedWorker, updatedFarm),
                const SizedBox(height: 24),

                // Recent payments
                _buildRecentPayments(context, payments),
                const SizedBox(height: 24),

                // Recent loans
                _buildRecentLoans(context, loans, updatedFarm, updatedWorker),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWorkerHeader(BuildContext context, Worker worker, Farm farm) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              farm.primaryColor.withOpacity(0.1),
              farm.primaryColor.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: farm.primaryColor.withOpacity(0.1),
              child: Text(
                worker.fullName.isNotEmpty ? worker.fullName[0].toUpperCase() : '?',
                style: TextStyle(
                  color: farm.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              worker.fullName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: farm.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              worker.position,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: worker.isActive ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                worker.isActive ? 'ACTIVO' : 'INACTIVO',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildInfoItem(context, Icons.badge, 'Cédula', worker.identification),
                _buildInfoItem(context, Icons.attach_money, 'Salario', 
                    NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(worker.salary)),
                _buildInfoItem(context, Icons.calendar_today, 'Ingreso', 
                    DateFormat('dd/MM/yyyy').format(worker.startDate)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
            fontSize: 10,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildQuickStats(BuildContext context, double totalPaid, double pendingLoans, double netSalary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumen Financiero',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                title: 'Total Pagado',
                value: NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(totalPaid),
                color: Colors.green,
                icon: Icons.payments,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SummaryCard(
                title: 'Préstamos Pendientes',
                value: NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(pendingLoans),
                color: Colors.orange,
                icon: Icons.account_balance_wallet,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SummaryCard(
          title: 'Salario Neto Disponible',
          value: NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(netSalary),
          color: netSalary >= 0 ? Colors.blue : Colors.red,
          icon: Icons.account_balance,
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, Worker worker, Farm farm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acciones Rápidas',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentFormScreen(
                        farm: farm,
                        worker: worker,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.payments),
                label: const Text('Registrar Pago'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoanFormScreen(
                        farm: farm,
                        worker: worker,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.account_balance_wallet),
                label: const Text('Registrar Préstamo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentPayments(BuildContext context, List payments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pagos Recientes',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: payments.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('No hay pagos registrados'),
                    ),
                  )
                : Column(
                    children: payments.take(5).map((payment) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.payments, size: 16, color: Colors.green),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    NumberFormat.currency(symbol: '\$', decimalDigits: 0)
                                        .format(payment.amount),
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    DateFormat('dd/MM/yyyy').format(payment.paymentDate),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              payment.typeDisplayName,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentLoans(BuildContext context, List loans, Farm farm, Worker worker) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Préstamos Recientes',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: loans.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('No hay préstamos registrados'),
                    ),
                  )
                : Column(
                    children: loans.take(5).map((loan) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.account_balance_wallet, size: 16, color: Colors.orange),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    NumberFormat.currency(symbol: '\$', decimalDigits: 0)
                                        .format(loan.amount),
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    DateFormat('dd/MM/yyyy').format(loan.loanDate),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: loan.status == LoanStatus.pending ? Colors.orange : Colors.green,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    loan.status.displayName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 16),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LoanFormScreen(
                                          farm: farm,
                                          worker: worker,
                                          loanToEdit: loan,
                                        ),
                                      ),
                                    );
                                  },
                                  tooltip: 'Editar préstamo',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                                  onPressed: () => _confirmDeleteLoan(context, loan, farm, worker),
                                  tooltip: 'Eliminar préstamo',
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ),
      ],
    );
  }

  void _confirmDeleteLoan(BuildContext context, Loan loan, Farm farm, Worker worker) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Préstamo'),
        content: Text(
          '¿Estás seguro de que quieres eliminar este préstamo de '
          '${NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(loan.amount)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final provider = Provider.of<FarmProvider>(context, listen: false);
              await provider.deleteLoan(loan.id, farmId: farm.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Préstamo eliminado')),
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
