import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';
import '../models/food_purchase.dart';
import 'food_purchase_form_screen.dart';
import '../widgets/summary_card.dart';

class FoodCostsScreen extends StatelessWidget {
  final Farm farm;

  const FoodCostsScreen({super.key, required this.farm});

  @override
  Widget build(BuildContext context) {
    return Consumer<FarmProvider>(
      builder: (context, farmProvider, _child) {
        final updatedFarm = farmProvider.farms.firstWhere(
          (f) => f.id == farm.id,
          orElse: () => farm,
        );

        final purchases = updatedFarm.foodPurchases.toList()
          ..sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));

        // Calcular estadísticas
        final totalCost = updatedFarm.totalFoodCost;
        final totalInventory = updatedFarm.totalFoodInventory;
        final avgCostPerKg = totalInventory > 0 ? (totalCost / totalInventory) : 0.0;

        // Agrupar por mes
        final purchasesByMonth = <String, List<FoodPurchase>>{};
        for (final purchase in purchases) {
          final monthKey = DateFormat('MMMM yyyy').format(purchase.purchaseDate);
          purchasesByMonth.putIfAbsent(monthKey, () => []).add(purchase);
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('💰 Costos de Alimento'),
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
                  _buildSummarySection(context, updatedFarm, avgCostPerKg),
                  const SizedBox(height: 24),

                  // Costos por mes
                  if (purchasesByMonth.isNotEmpty) ...[
                    _buildMonthlyBreakdown(context, purchasesByMonth, updatedFarm),
                    const SizedBox(height: 24),
                  ],

                  // Lista de compras
                  _buildPurchasesList(context, purchases, updatedFarm, farmProvider),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FoodPurchaseFormScreen(farm: updatedFarm),
                ),
              );
            },
            backgroundColor: updatedFarm.primaryColor,
            icon: const Icon(Icons.add),
            label: const Text('Nueva Compra'),
          ),
        );
      },
    );
  }

  Widget _buildSummarySection(BuildContext context, Farm farm, double avgCostPerKg) {
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
        child: Text('No hay compras registradas'),
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

