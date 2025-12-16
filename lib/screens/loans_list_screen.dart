import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';
import '../models/loan.dart';
import '../widgets/loan_card.dart';
import 'loan_form_screen.dart';

class LoansListScreen extends StatelessWidget {
  final Farm farm;

  const LoansListScreen({super.key, required this.farm});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Préstamos - ${farm.name}'),
        centerTitle: true,
        backgroundColor: farm.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<FarmProvider>(
        builder: (context, farmProvider, _child) {
          final loans = farm.loans.toList()
            ..sort((a, b) => b.loanDate.compareTo(a.loanDate));
          
          final pendingLoans = loans.where((l) => l.status == LoanStatus.pending).toList();
          final paidLoans = loans.where((l) => l.status == LoanStatus.paid).toList();
          
          if (loans.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay préstamos registrados',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Los préstamos aparecerán aquí cuando se registren',
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
              // Summary cards
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text(
                                'Pendientes',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                NumberFormat.currency(symbol: '\$', decimalDigits: 0)
                                    .format(farm.totalPendingLoans),
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                              Text(
                                '${pendingLoans.length} préstamos',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text(
                                'Pagados',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                NumberFormat.currency(symbol: '\$', decimalDigits: 0)
                                    .format(paidLoans.fold(0.0, (sum, loan) => sum + loan.amount)),
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              Text(
                                '${paidLoans.length} préstamos',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Loans list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: loans.length,
                  itemBuilder: (context, index) {
                    final loan = loans[index];
                    final worker = farmProvider.getWorkerById(loan.workerId);
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: LoanCard(
                        loan: loan,
                        worker: worker,
                        farm: farm,
                        onTap: () {
                          if (worker != null) {
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
                          }
                        },
                        onDelete: () => _confirmDelete(context, farmProvider, loan),
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
        label: const Text('Registrar Préstamo'),
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
          final activeWorkers = farm.activeWorkers;
          
          if (activeWorkers.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: const Center(
                child: Text('No hay trabajadores activos para registrar préstamos'),
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
                      backgroundColor: farm.primaryColor.withValues(alpha: 0.1),
                      child: Text(
                        worker.fullName.isNotEmpty ? worker.fullName[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: farm.primaryColor,
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
                          builder: (context) => LoanFormScreen(
                            farm: farm,
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

  void _confirmDelete(BuildContext context, FarmProvider farmProvider, Loan loan) {
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
              await farmProvider.deleteLoan(loan.id, farmId: farm.id);
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

