import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';
import '../widgets/summary_card.dart';
import 'workers_list_screen.dart';
import 'payments_list_screen.dart';
import 'loans_list_screen.dart';
import 'expenses_list_screen.dart';
import 'farm_form_screen.dart';
import 'farm_statistics_screen.dart';
import 'pork_farming_home_screen.dart';
import 'cattle_home_screen.dart';

class FarmProfileScreen extends StatelessWidget {
  final Farm farm;

  const FarmProfileScreen({super.key, required this.farm});

  @override
  Widget build(BuildContext context) {
    return Consumer<FarmProvider>(
      builder: (context, farmProvider, child) {
        // Get the updated farm from provider to ensure we see the latest data
        final updatedFarm = farmProvider.farms.firstWhere(
          (f) => f.id == farm.id,
          orElse: () => farm,
        );
        
        return Scaffold(
          appBar: AppBar(
            title: Text(updatedFarm.name),
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
                      builder: (context) => FarmFormScreen(farmToEdit: updatedFarm),
                    ),
                  );
                },
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: farmProvider.loadFarms,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Farm header
                  _buildFarmHeader(context, updatedFarm),
                  const SizedBox(height: 24),

                  // Quick stats
                  _buildQuickStats(context, updatedFarm),
                  const SizedBox(height: 24),

                  // Module access buttons
                  _buildModuleAccess(context, updatedFarm),
                  const SizedBox(height: 24),

                  // Recent activity
                  _buildRecentActivity(context, updatedFarm),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFarmHeader(BuildContext context, Farm farm) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              farm.primaryColor.withValues(alpha: 0.1),
              farm.primaryColor.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: farm.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.agriculture,
                color: farm.primaryColor,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              farm.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: farm.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            if (farm.location != null) ...[
              const SizedBox(height: 8),
              Text(
                farm.location!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Creada el: ${DateFormat('dd/MM/yyyy').format(farm.createdAt)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
            if (farm.description != null && farm.description!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                farm.description!,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, Farm farm) {
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
              child: SummaryCard(
                title: 'Trabajadores Activos',
                value: '${farm.activeWorkersCount}',
                color: Colors.blue,
                icon: Icons.people,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SummaryCard(
                title: 'Total Pagado (Mes)',
                value: NumberFormat.currency(symbol: '\$', decimalDigits: 0)
                    .format(farm.totalPaidThisMonth),
                color: Colors.green,
                icon: Icons.payments,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                title: 'Préstamos Pendientes',
                value: NumberFormat.currency(symbol: '\$', decimalDigits: 0)
                    .format(farm.totalPendingLoans),
                color: Colors.orange,
                icon: Icons.account_balance_wallet,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SummaryCard(
                title: 'Total Préstamos',
                value: NumberFormat.currency(symbol: '\$', decimalDigits: 0)
                    .format(farm.totalLoaned),
                color: Colors.purple,
                icon: Icons.money_off,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModuleAccess(BuildContext context, Farm farm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Módulos de Gestión',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildModuleButton(
              context,
              icon: Icons.people,
              title: 'Trabajadores',
              subtitle: '${farm.activeWorkersCount} activos',
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkersListScreen(farm: farm),
                  ),
                );
              },
            ),
            _buildModuleButton(
              context,
              icon: Icons.payments,
              title: 'Pagos',
              subtitle: '${farm.payments.length} registros',
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentsListScreen(farm: farm),
                  ),
                );
              },
            ),
            _buildModuleButton(
              context,
              icon: Icons.account_balance_wallet,
              title: 'Préstamos',
              subtitle: '${farm.loans.length} registros',
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoansListScreen(farm: farm),
                  ),
                );
              },
            ),
            _buildModuleButton(
              context,
              icon: Icons.receipt_long,
              title: 'Gastos',
              subtitle: '${farm.expenses.length} registros',
              color: Colors.red,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExpensesListScreen(farm: farm),
                  ),
                );
              },
            ),
            _buildModuleButton(
              context,
              icon: Icons.bar_chart,
              title: 'Estadísticas',
              subtitle: 'Análisis completo',
              color: Colors.purple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FarmStatisticsScreen(farm: farm),
                  ),
                );
              },
            ),
            _buildModuleButton(
              context,
              icon: Icons.pets,
              title: 'Porcicultura',
              subtitle: '${farm.pigsCount} cerdos',
              color: Colors.pink[300]!,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PorkFarmingHomeScreen(farm: farm),
                  ),
                );
              },
            ),
            _buildModuleButton(
              context,
              icon: Icons.agriculture,
              title: 'Ganadería',
              subtitle: '${farm.cattleCount} cabezas',
              color: Colors.brown,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CattleHomeScreen(farm: farm),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModuleButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, Farm farm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actividad Reciente',
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
            child: Column(
              children: [
                _buildActivityItem(
                  context,
                  Icons.people,
                  'Trabajadores registrados',
                  '${farm.workers.length} trabajadores en total',
                  Colors.blue,
                ),
                const Divider(),
                _buildActivityItem(
                  context,
                  Icons.payments,
                  'Pagos realizados',
                  '${farm.payments.length} pagos registrados',
                  Colors.green,
                ),
                const Divider(),
                _buildActivityItem(
                  context,
                  Icons.account_balance_wallet,
                  'Préstamos otorgados',
                  '${farm.loans.length} préstamos registrados',
                  Colors.orange,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


