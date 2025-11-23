import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';
import '../models/pig.dart';
import '../widgets/summary_card.dart';

class FeedingAnalysisScreen extends StatelessWidget {
  final Farm farm;

  const FeedingAnalysisScreen({super.key, required this.farm});

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
            title: const Text('🍽️ Análisis de Alimentación'),
            centerTitle: true,
            backgroundColor: updatedFarm.primaryColor,
            foregroundColor: Colors.white,
          ),
          body: RefreshIndicator(
            onRefresh: farmProvider.loadFarms,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Resumen general
                  _buildSummarySection(context, updatedFarm),
                  const SizedBox(height: 24),

                  // Consumo por etapa
                  _buildConsumptionByStage(context, updatedFarm),
                  const SizedBox(height: 24),

                  // Duración del alimento
                  _buildFoodDurationInfo(context, updatedFarm),
                  const SizedBox(height: 24),

                  // Predicción de necesidades
                  _buildPredictionSection(context, updatedFarm),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummarySection(BuildContext context, Farm farm) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 Resumen General',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    title: 'Total Cerdos',
                    value: '${farm.pigsCount}',
                    color: Colors.pink[300]!,
                    icon: Icons.pets,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SummaryCard(
                    title: 'Consumo Diario',
                    value: '${farm.totalDailyFeedingConsumption.toStringAsFixed(1)} kg',
                    color: Colors.orange,
                    icon: Icons.restaurant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    title: 'Inventario',
                    value: '${farm.totalFoodInventory.toStringAsFixed(1)} kg',
                    color: Colors.green,
                    icon: Icons.inventory,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SummaryCard(
                    title: 'En Bultos',
                    value: '${(farm.totalFoodInventory / 40).toStringAsFixed(1)}',
                    color: Colors.blue,
                    icon: Icons.store,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsumptionByStage(BuildContext context, Farm farm) {
    final consumptionByStage = <FeedingStage, double>{};

    for (final pig in farm.pigs) {
      consumptionByStage[pig.feedingStage] =
          (consumptionByStage[pig.feedingStage] ?? 0) + pig.estimatedDailyConsumption;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🍽️ Consumo por Etapa',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...consumptionByStage.entries.map((entry) {
              final stageName = _getStageName(entry.key);
              return _buildStageConsumptionCard(context, stageName, entry.value);
            }),
            if (consumptionByStage.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No hay cerdos registrados'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStageConsumptionCard(BuildContext context, String stageName, double consumption) {
    final stageColor = _getStageColor(stageName);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: stageColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: stageColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            stageName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            '${consumption.toStringAsFixed(2)} kg/día',
            style: TextStyle(color: stageColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _getStageName(FeedingStage stage) {
    switch (stage) {
      case FeedingStage.inicio:
        return 'Inicio';
      case FeedingStage.desarrollo:
        return 'Desarrollo';
      case FeedingStage.finalizacion:
        return 'Engorde';
    }
  }

  Color _getStageColor(String stageName) {
    switch (stageName) {
      case 'Inicio':
        return Colors.green;
      case 'Levante':
        return Colors.orange;
      case 'Engorde':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildFoodDurationInfo(BuildContext context, Farm farm) {
    final daysLeft = farm.daysUntilFoodRunsOut;

    return Card(
      elevation: 2,
      color: daysLeft != null && daysLeft <= 5 ? Colors.red[50] : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⏱️ Duración del Alimento',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (daysLeft == null || farm.totalDailyFeedingConsumption == 0)
              const Center(
                child: Text('No hay suficiente información para calcular la duración'),
              )
            else ...[
              _buildDurationItem(
                context,
                'Días restantes',
                daysLeft.toStringAsFixed(1),
                daysLeft <= 2 ? Colors.red : daysLeft <= 5 ? Colors.orange : Colors.green,
              ),
              const SizedBox(height: 12),
              _buildDurationItem(
                context,
                'Semanas restantes',
                (daysLeft / 7).toStringAsFixed(1),
                Colors.blue,
              ),
              const SizedBox(height: 12),
              if (daysLeft <= 5)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '⚠️ ¡Alerta! El alimento está por agotarse',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDurationItem(BuildContext context, String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildPredictionSection(BuildContext context, Farm farm) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📈 Predicciones',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildPredictionCard(
              context,
              'Consumo mensual estimado',
              '${(farm.totalDailyFeedingConsumption * 30).toStringAsFixed(1)} kg',
              Icons.calendar_today,
            ),
            const SizedBox(height: 12),
            _buildPredictionCard(
              context,
              'Alimento necesario para 30 días',
              '${(farm.totalDailyFeedingConsumption * 30).toStringAsFixed(1)} kg',
              Icons.restaurant_menu,
            ),
            const SizedBox(height: 12),
            _buildPredictionCard(
              context,
              'Alimento necesario para 60 días',
              '${(farm.totalDailyFeedingConsumption * 60).toStringAsFixed(1)} kg',
              Icons.restaurant_menu,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: farm.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: farm.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: farm.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

