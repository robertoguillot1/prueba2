import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';
import '../models/loan.dart';
import '../models/cattle.dart';
import '../widgets/summary_card.dart';

class FarmStatisticsScreen extends StatelessWidget {
  final Farm farm;

  const FarmStatisticsScreen({super.key, required this.farm});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Estadísticas - ${farm.name}'),
        centerTitle: true,
        backgroundColor: farm.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<FarmProvider>(
        builder: (context, farmProvider, _child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Monthly summary
                _buildMonthlySummary(context),
                const SizedBox(height: 24),

                // Milk production stats
                _buildMilkProductionStats(context, farmProvider),
                const SizedBox(height: 24),

                // Charts section
                _buildChartsSection(context, farmProvider),
                const SizedBox(height: 24),

                // Workers analysis
                _buildWorkersAnalysis(context, farmProvider),
                const SizedBox(height: 24),

                // Financial summary
                _buildFinancialSummary(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMonthlySummary(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumen del Mes',
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
                value: NumberFormat.currency(symbol: '\$', decimalDigits: 0)
                    .format(farm.totalPaidThisMonth),
                color: Colors.green,
                icon: Icons.payments,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SummaryCard(
                title: 'Préstamos Pendientes',
                value: NumberFormat.currency(symbol: '\$', decimalDigits: 0)
                    .format(farm.totalPendingLoans),
                color: Colors.orange,
                icon: Icons.account_balance_wallet,
              ),
            ),
          ],
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

  Widget _buildChartsSection(BuildContext context, FarmProvider farmProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Análisis Visual',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Payments by worker chart
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pagos por Trabajador',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: _buildPaymentsChart(context, farmProvider),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Loan status chart
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estado de Préstamos',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: _buildLoansChart(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentsChart(BuildContext context, FarmProvider farmProvider) {
    final activeWorkers = farm.activeWorkers;
    
    if (activeWorkers.isEmpty) {
      return const Center(
        child: Text('No hay trabajadores activos'),
      );
    }

    final paymentsByWorker = activeWorkers.map((worker) {
      final totalPaid = farmProvider.getWorkerTotalPaid(worker.id);
      return totalPaid;
    }).toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: paymentsByWorker.isNotEmpty 
            ? paymentsByWorker.reduce((a, b) => a > b ? a : b) * 1.2 
            : 100,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < activeWorkers.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      activeWorkers[value.toInt()].fullName.split(' ').first,
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  NumberFormat.compactCurrency(symbol: '\$', decimalDigits: 0)
                      .format(value),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: activeWorkers.asMap().entries.map((entry) {
          final index = entry.key;
          final worker = entry.value;
          final totalPaid = farmProvider.getWorkerTotalPaid(worker.id);
          
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: totalPaid,
                color: farm.primaryColor,
                width: 20,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLoansChart(BuildContext context) {
    final pendingLoans = farm.loans.where((l) => l.status == LoanStatus.pending).length;
    final paidLoans = farm.loans.where((l) => l.status == LoanStatus.paid).length;
    
    if (farm.loans.isEmpty) {
      return const Center(
        child: Text('No hay préstamos registrados'),
      );
    }

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: [
          PieChartSectionData(
            color: Colors.orange,
            value: pendingLoans.toDouble(),
            title: '$pendingLoans\nPendientes',
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            color: Colors.green,
            value: paidLoans.toDouble(),
            title: '$paidLoans\nPagados',
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkersAnalysis(BuildContext context, FarmProvider farmProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Análisis de Trabajadores',
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
              children:               farm.activeWorkers.map((worker) {
                final totalPaid = farmProvider.getWorkerTotalPaid(worker.id);
                final pendingLoans = farmProvider.getWorkerPendingLoans(worker.id);
                // final netSalary = farmProvider.getWorkerNetSalary(worker.id); // Available if needed
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: farm.primaryColor.withValues(alpha: 0.1),
                        child: Text(
                          worker.fullName.isNotEmpty ? worker.fullName[0].toUpperCase() : '?',
                          style: TextStyle(
                            color: farm.primaryColor,
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
                              worker.fullName,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              worker.position,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(totalPaid),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Préstamos: ${NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(pendingLoans)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.orange,
                            ),
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

  Widget _buildFinancialSummary(BuildContext context) {
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
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildFinancialRow(
                  context,
                  'Total Pagado (Mes)',
                  NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(farm.totalPaidThisMonth),
                  Colors.green,
                ),
                const Divider(),
                _buildFinancialRow(
                  context,
                  'Total Préstamos Otorgados',
                  NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(farm.totalLoaned),
                  Colors.purple,
                ),
                const Divider(),
                _buildFinancialRow(
                  context,
                  'Préstamos Pendientes',
                  NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(farm.totalPendingLoans),
                  Colors.orange,
                ),
                const Divider(),
                _buildFinancialRow(
                  context,
                  'Préstamos Pagados',
                  NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(
                    farm.totalLoaned - farm.totalPendingLoans
                  ),
                  Colors.blue,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialRow(BuildContext context, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilkProductionStats(BuildContext context, FarmProvider farmProvider) {
    // Obtener todas las vacas
    final femaleCattle = farm.cattle.where((c) => c.gender == CattleGender.female).toList();
    
    if (femaleCattle.isEmpty) {
      return const SizedBox.shrink();
    }

    // Calcular producción total y promedio
    double totalLiters = 0;
    int recordCount = 0;
    
    // Obtener el último litraje por vaca
    Map<String, double> lastProduction = {};
    
    for (final cow in femaleCattle) {
      final records = farmProvider.getMilkProductionRecords(cow.id, farmId: farm.id);
      if (records.isNotEmpty) {
        lastProduction[cow.id] = records.first.litersProduced;
        for (final record in records) {
          totalLiters += record.litersProduced;
          recordCount++;
        }
      }
    }

    final averageLiters = recordCount > 0 ? totalLiters / recordCount : 0.0;
    final totalCurrentLiters = lastProduction.values.fold(0.0, (sum, liters) => sum + liters);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Producción de Leche',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                title: 'Total Litros (Actual)',
                value: totalCurrentLiters.toStringAsFixed(0) + ' L',
                color: Colors.blue,
                icon: Icons.water_drop,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SummaryCard(
                title: 'Promedio por Vaca',
                value: averageLiters.toStringAsFixed(1) + ' L',
                color: Colors.cyan,
                icon: Icons.analytics,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Producción Individual',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...femaleCattle.where((cow) => lastProduction.containsKey(cow.id)).map((cow) {
                  final liters = lastProduction[cow.id]!;
                  final records = farmProvider.getMilkProductionRecords(cow.id, farmId: farm.id);
                  final avgForCow = records.isNotEmpty
                      ? records.fold(0.0, (sum, r) => sum + r.litersProduced) / records.length
                      : 0.0;
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: cow.currentWeight >= avgForCow
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.orange.withValues(alpha: 0.1),
                          child: Icon(
                            cow.currentWeight >= avgForCow
                                ? Icons.trending_up
                                : Icons.trending_down,
                            color: cow.currentWeight >= avgForCow ? Colors.green : Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cow.name ?? cow.identification ?? 'Sin ID',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Último: ${liters.toStringAsFixed(1)} L | Promedio: ${avgForCow.toStringAsFixed(1)} L',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
