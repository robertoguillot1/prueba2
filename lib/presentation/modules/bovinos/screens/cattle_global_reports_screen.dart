import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart'; // For charts if needed
import '../../../../../core/di/dependency_injection.dart';
import '../../../widgets/custom_card.dart';
import '../list/cubits/cattle_global_reports_cubit.dart';

class CattleGlobalReportsScreen extends StatelessWidget {
  final String farmId;

  const CattleGlobalReportsScreen({super.key, required this.farmId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes Globales'),
      ),
      body: BlocProvider(
        create: (context) => CattleGlobalReportsCubit(
          sl(), // Inject GetCattleList directly using helper or add factory if preferred
        )..loadReports(farmId),
        child: BlocBuilder<CattleGlobalReportsCubit, CattleGlobalReportsState>(
          builder: (context, state) {
            if (state is ReportsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ReportsError) {
              return Center(child: Text(state.message));
            }

            if (state is ReportsLoaded) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSummaryCards(context, state),
                    const SizedBox(height: 24),
                    _buildStatusDistributionChart(context, state),
                    // Add more charts here (e.g. Weight distribution, etc)
                  ],
                ),
              );
            }
            
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, ReportsLoaded state) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context,
                title: 'Total Animales',
                value: state.totalCattle.toString(),
                icon: Icons.pets,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                context,
                title: 'Peso Promedio',
                value: '${state.averageWeight.toStringAsFixed(1)} kg',
                icon: Icons.monitor_weight,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildMetricCard(
          context,
          title: 'Vacas Lecheras (Propósito)',
          value: state.totalMilkCows.toString(),
          icon: Icons.water_drop,
          color: Colors.blueAccent,
        ),
      ],
    );
  }

  Widget _buildMetricCard(BuildContext context, {required String title, required String value, required IconData icon, required Color color}) {
    return CustomCard(
       elevation: 2,
       child: Column(
         children: [
           Icon(icon, size: 32, color: color),
           const SizedBox(height: 8),
           Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
           Text(title, style: TextStyle(fontSize: 14, color: Colors.grey.shade600), textAlign: TextAlign.center),
         ],
       ),
    );
  }

  Widget _buildStatusDistributionChart(BuildContext context, ReportsLoaded state) {
    // Basic placeholder for a pie chart or list
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Distribución por Estado', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          // Simple list implementation instead of complex Chart for speed
          ...state.statusDistribution.entries.map((e) => ListTile(
            title: Text(e.key),
            trailing: Text(e.value.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
            leading: CircleAvatar(
              radius: 5, 
              backgroundColor: _getColorForStatus(e.key),
            ),
          )),
        ],
      ),
    );
  }

  Color _getColorForStatus(String status) {
    if (status.contains('active')) return Colors.green;
    if (status.contains('sold')) return Colors.orange;
    if (status.contains('dead')) return Colors.red;
    return Colors.grey;
  }
}
