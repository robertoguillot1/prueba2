import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finanzas'),
        centerTitle: true,
      ),
      body: Consumer<FarmProvider>(
        builder: (context, farmProvider, _child) {
          if (farmProvider.farms.isEmpty) {
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
                    'No hay datos financieros',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crea una finca para comenzar',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: farmProvider.loadFarms,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Resumen General
                  _buildGeneralSummary(context, farmProvider),
                  const SizedBox(height: 24),

                  // Desglose por Finca
                  _buildPerFarmBreakdown(context, farmProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGeneralSummary(BuildContext context, FarmProvider farmProvider) {
    double totalPaid = 0;
    double totalLoaned = 0;
    double totalPendingLoans = 0;
    int totalWorkers = 0;

    for (final farm in farmProvider.farms) {
      totalPaid += farm.totalPaidThisMonth;
      totalLoaned += farm.totalLoaned;
      totalPendingLoans += farm.totalPendingLoans;
      totalWorkers += farm.activeWorkersCount;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumen General',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                context,
                'Total Pagado',
                NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(totalPaid),
                Colors.green,
                Icons.payments,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                context,
                'Préstamos Pendientes',
                NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(totalPendingLoans),
                Colors.orange,
                Icons.account_balance_wallet,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                context,
                'Total Préstamos',
                NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(totalLoaned),
                Colors.purple,
                Icons.money_off,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                context,
                'Trabajadores',
                '$totalWorkers',
                Colors.blue,
                Icons.people,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 28),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    value,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerFarmBreakdown(BuildContext context, FarmProvider farmProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Por Finca',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...farmProvider.farms.map((farm) => _buildFarmCard(context, farm)),
      ],
    );
  }

  Widget _buildFarmCard(BuildContext context, Farm farm) {
    final totalExpenses = farm.expenses.fold(0.0, (sum, expense) => sum + expense.amount);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: farm.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.agriculture, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        farm.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        farm.location ?? 'Sin ubicación',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            _buildFinancialRow(
              context,
              'Total Pagado (Mes)',
              NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(farm.totalPaidThisMonth),
              Colors.green,
            ),
            const SizedBox(height: 8),
            _buildFinancialRow(
              context,
              'Préstamos Pendientes',
              NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(farm.totalPendingLoans),
              Colors.orange,
            ),
            const SizedBox(height: 8),
            _buildFinancialRow(
              context,
              'Total Préstamos',
              NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(farm.totalLoaned),
              Colors.purple,
            ),
            const SizedBox(height: 8),
            _buildFinancialRow(
              context,
              'Gastos',
              NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(totalExpenses),
              Colors.red,
            ),
            const SizedBox(height: 8),
            _buildFinancialRow(
              context,
              'Trabajadores',
              '${farm.activeWorkersCount}',
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialRow(BuildContext context, String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

