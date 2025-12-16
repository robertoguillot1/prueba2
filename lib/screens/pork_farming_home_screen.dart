import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';
import '../widgets/summary_card.dart';
import 'pigs_inventory_screen.dart';
import 'food_management_screen.dart';
import 'weight_history_screen.dart';
import 'pig_vaccines_screen.dart';

class PorkFarmingHomeScreen extends StatelessWidget {
  final Farm farm;

  const PorkFarmingHomeScreen({super.key, required this.farm});

  @override
  Widget build(BuildContext context) {
    return Consumer<FarmProvider>(
      builder: (context, farmProvider, _child) {
        final updatedFarm = farmProvider.farms.firstWhere(
          (f) => f.id == farm.id,
          orElse: () => farm,
        );

        return Scaffold(
          appBar: AppBar(
            title: const Text('🐷 Porcicultura'),
            centerTitle: true,
            backgroundColor: farm.primaryColor,
            foregroundColor: Colors.white,
          ),
          body: RefreshIndicator(
            onRefresh: farmProvider.loadFarms,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Resumen rápido
                  _buildQuickSummary(context, updatedFarm),
                  const SizedBox(height: 24),

                  // Estadísticas de alimentación
                  _buildFeedingStats(context, updatedFarm),
                  const SizedBox(height: 24),

                  // Módulos de gestión
                  _buildManagementModules(context, updatedFarm),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickSummary(BuildContext context, Farm farm) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              farm.primaryColor.withValues(alpha: 0.1),
              Colors.pink.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              '🐷',
              style: TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 12),
            Text(
              'Inventario de Cerdos',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: farm.primaryColor,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Total de Cerdos',
                    '${farm.pigsCount}',
                    Icons.pets,
                    Colors.pink[300]!,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Peso Promedio',
                    '${farm.averagePigWeight.toStringAsFixed(1)} kg',
                    Icons.monitor_weight,
                    Colors.blue[300]!,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFeedingStats(BuildContext context, Farm farm) {
    final daysLeft = farm.daysUntilFoodRunsOut;
    final hasCriticalAlert = daysLeft != null && daysLeft <= 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Análisis de Alimentación',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                title: 'Consumo Diario',
                value: '${farm.totalDailyFeedingConsumption.toStringAsFixed(1)} kg/día',
                color: Colors.orange,
                icon: Icons.restaurant,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SummaryCard(
                title: 'Inventario',
                value: '${farm.totalFoodInventory.toStringAsFixed(1)} kg',
                color: Colors.green,
                icon: Icons.inventory,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (daysLeft != null)
          Card(
            elevation: 2,
            color: hasCriticalAlert ? Colors.red[50] : Colors.orange[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    hasCriticalAlert ? Icons.warning : Icons.info,
                    color: hasCriticalAlert ? Colors.red : Colors.orange,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasCriticalAlert ? '⚠️ Alerta' : '⏱️ Estado',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: hasCriticalAlert ? Colors.red : Colors.orange,
                              ),
                        ),
                        Text(
                          daysLeft > 0
                              ? 'El alimento durará ${daysLeft.toStringAsFixed(1)} días'
                              : '⚠️ El alimento está agotado',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildManagementModules(BuildContext context, Farm farm) {
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
              icon: Icons.list,
              title: 'Inventario',
              subtitle: '${farm.pigsCount} cerdos',
              color: Colors.pink[300]!,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PigsInventoryScreen(farm: farm),
                  ),
                );
              },
            ),
            _buildModuleButton(
              context,
              icon: Icons.restaurant_menu,
              title: 'Gestión de Alimento',
              subtitle: 'Análisis y costos',
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FoodManagementScreen(farm: farm),
                  ),
                );
              },
            ),
            _buildModuleButton(
              context,
              icon: Icons.trending_up,
              title: 'Historial de Pesos',
              subtitle: 'Evolución de peso',
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WeightHistoryScreen(farm: farm),
                  ),
                );
              },
            ),
            _buildModuleButton(
              context,
              icon: Icons.medical_services,
              title: 'Control de Vacunas',
              subtitle: 'Registro y seguimiento',
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PigVaccinesScreen(farm: farm),
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
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontSize: 11,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


