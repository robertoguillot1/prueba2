import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';
import '../models/pig.dart';
import '../models/food_purchase.dart';
import '../widgets/summary_card.dart';
import 'food_purchase_form_screen.dart';

class FoodManagementScreen extends StatefulWidget {
  final Farm farm;

  const FoodManagementScreen({super.key, required this.farm});

  @override
  State<FoodManagementScreen> createState() => _FoodManagementScreenState();
}

class _FoodManagementScreenState extends State<FoodManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Actualizar UI cuando cambia la pestaña
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FarmProvider>(
      builder: (context, farmProvider, _child) {
        final updatedFarm = farmProvider.farms.firstWhere(
          (f) => f.id == widget.farm.id,
          orElse: () => widget.farm,
        );

        return Scaffold(
          appBar: AppBar(
            title: const Text('🍽️ Gestión de Alimento'),
            centerTitle: true,
            backgroundColor: updatedFarm.primaryColor,
            foregroundColor: Colors.white,
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(text: 'Análisis', icon: Icon(Icons.analytics)),
                Tab(text: 'Costos', icon: Icon(Icons.payments)),
              ],
            ),
          ),
          body: RefreshIndicator(
            onRefresh: farmProvider.loadFarms,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAnalysisTab(context, updatedFarm),
                _buildCostsTab(context, updatedFarm, farmProvider),
              ],
            ),
          ),
          floatingActionButton: Builder(
            builder: (context) {
              return _tabController.index == 1
                  ? FloatingActionButton.extended(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FoodPurchaseFormScreen(farm: updatedFarm),
                          ),
                        );
                        if (result == true && mounted) {
                          // Refrescar datos
                        }
                      },
                      backgroundColor: updatedFarm.primaryColor,
                      icon: const Icon(Icons.add),
                      label: const Text('Nueva Compra'),
                    )
                  : const SizedBox.shrink();
            },
          ),
        );
      },
    );
  }

  Widget _buildAnalysisTab(BuildContext context, Farm farm) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resumen general
          _buildSummarySection(context, farm),
          const SizedBox(height: 24),

          // Consumo por etapa
          _buildConsumptionByStage(context, farm),
          const SizedBox(height: 24),

          // Duración del alimento
          _buildFoodDurationInfo(context, farm),
          const SizedBox(height: 24),

          // Predicción de necesidades
          _buildPredictionSection(context, farm),
        ],
      ),
    );
  }

  Widget _buildCostsTab(BuildContext context, Farm farm, FarmProvider farmProvider) {
    final purchases = farm.foodPurchases.toList()
      ..sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));

    // Calcular estadísticas
    final totalCost = farm.totalFoodCost;
    final totalInventory = farm.totalFoodInventory;
    final avgCostPerKg = totalInventory > 0 ? (totalCost / totalInventory) : 0.0;

    // Agrupar por mes
    final purchasesByMonth = <String, List<FoodPurchase>>{};
    for (final purchase in purchases) {
      final monthKey = DateFormat('MMMM yyyy').format(purchase.purchaseDate);
      purchasesByMonth.putIfAbsent(monthKey, () => []).add(purchase);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resumen de costos
          _buildCostsSummarySection(context, farm, avgCostPerKg),
          const SizedBox(height: 24),

          // Costos por mes
          if (purchasesByMonth.isNotEmpty) ...[
            _buildMonthlyBreakdown(context, purchasesByMonth, farm),
            const SizedBox(height: 24),
          ],

          // Lista de compras
          _buildPurchasesList(context, purchases, farm, farmProvider),
        ],
      ),
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
      case FeedingStage.levante:
        return 'Levante';
      case FeedingStage.engorde:
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
        color: widget.farm.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: widget.farm.primaryColor),
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
              color: widget.farm.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostsSummarySection(BuildContext context, Farm farm, double avgCostPerKg) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 Resumen de Costos',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    title: 'Total Gastado',
                    value: NumberFormat.currency(symbol: '\$', decimalDigits: 0)
                        .format(farm.totalFoodCost),
                    color: Colors.red,
                    icon: Icons.payments,
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
            if (avgCostPerKg > 0)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Costo promedio: ${NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(avgCostPerKg)}/kg',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyBreakdown(
    BuildContext context,
    Map<String, List<FoodPurchase>> purchasesByMonth,
    Farm farm,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📅 Costos por Mes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...purchasesByMonth.entries.map((entry) {
              final monthTotal = entry.value.fold<double>(
                0.0,
                (sum, purchase) => sum + purchase.totalCost,
              );
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: farm.primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${entry.value.length} compra(s)',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      NumberFormat.currency(symbol: '\$', decimalDigits: 0)
                          .format(monthTotal),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: farm.primaryColor,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchasesList(
    BuildContext context,
    List<FoodPurchase> purchases,
    Farm farm,
    FarmProvider farmProvider,
  ) {
    if (purchases.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('No hay compras registradas'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📋 Historial de Compras',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...purchases.map((purchase) => Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: farm.primaryColor.withOpacity(0.1),
                  child: Icon(Icons.shopping_cart, color: farm.primaryColor),
                ),
                title: Text(
                  purchase.foodType,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(DateFormat('dd/MM/yyyy').format(purchase.purchaseDate)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${purchase.quantity.toStringAsFixed(1)} kg',
                          style: TextStyle(fontSize: 12),
                        ),
                        const Text(' • '),
                        Text(
                          NumberFormat.currency(symbol: '\$', decimalDigits: 0)
                              .format(purchase.totalCost),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Eliminar', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) async {
                    if (value == 'delete') {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Eliminar compra'),
                          content: const Text('¿Eliminar esta compra?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await farmProvider.deleteFoodPurchase(purchase.id);
                      }
                    }
                  },
                ),
              ),
            )),
      ],
    );
  }
}

