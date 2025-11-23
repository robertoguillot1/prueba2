import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';
import '../models/broiler_batch.dart';
import '../models/batch_expense.dart';
import '../models/batch_sale.dart';
import 'batch_sale_form_screen.dart';

class BatchBalanceScreen extends StatelessWidget {
  final Farm farm;
  final BroilerBatch batch;

  const BatchBalanceScreen({
    super.key,
    required this.farm,
    required this.batch,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<FarmProvider>(
      builder: (context, farmProvider, _child) {
        final updatedFarm = farmProvider.farms.firstWhere(
          (f) => f.id == farm.id,
          orElse: () => farm,
        );

        final updatedBatch = updatedFarm.broilerBatches.firstWhere(
          (b) => b.id == batch.id,
          orElse: () => batch,
        );

        final expenses = farmProvider.getBatchExpensesByBatchId(updatedBatch.id, farmId: updatedFarm.id);
        final sale = farmProvider.getBatchSaleByBatchId(updatedBatch.id, farmId: updatedFarm.id);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Balance del Lote'),
            backgroundColor: farm.primaryColor,
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sección de Ingresos
                _buildIncomeSection(context, sale, updatedFarm, updatedBatch, farmProvider),
                const SizedBox(height: 24),

                // Sección de Egresos
                _buildExpensesSection(context, expenses, updatedBatch),
                const SizedBox(height: 24),

                // Gráfico circular de gastos
                if (expenses.isNotEmpty) ...[
                  _buildExpensesPieChart(context, expenses),
                  const SizedBox(height: 24),
                ],

                // Resultado Final
                _buildFinalResult(context, expenses, sale, updatedBatch),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIncomeSection(
    BuildContext context,
    BatchSale? sale,
    Farm farm,
    BroilerBatch batch,
    FarmProvider farmProvider,
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
                const Text(
                  'Ingresos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (sale == null && batch.estado == BatchStatus.activo)
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BatchSaleFormScreen(
                            farm: farm,
                            batch: batch,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Registrar Venta'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: farm.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (sale == null)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'No hay venta registrada',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else ...[
              _buildIncomeRow('Peso Total Vendido', '${sale.pesoTotalVendido.toStringAsFixed(2)} kg'),
              _buildIncomeRow('Precio por Kilo', NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(sale.precioPorKilo)),
              _buildIncomeRow('Cantidad de Pollos', '${sale.cantidadPollosVendidos}'),
              const Divider(),
              _buildIncomeRow(
                'Total Venta',
                NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(sale.totalVenta),
                isTotal: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: FontWeight.bold,
              color: isTotal ? Colors.green : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesSection(BuildContext context, List<BatchExpense> expenses, BroilerBatch batch) {
    // Agrupar gastos por categoría
    final gastosAlimento = expenses.where((e) => e.tipo == BatchExpenseType.alimento).fold<double>(0.0, (sum, e) => sum + e.monto);
    final gastosSalud = expenses.where((e) => 
      e.tipo == BatchExpenseType.medicina || e.tipo == BatchExpenseType.vacunas
    ).fold<double>(0.0, (sum, e) => sum + e.monto);
    final otrosGastos = expenses.where((e) => 
      e.tipo != BatchExpenseType.alimento && 
      e.tipo != BatchExpenseType.medicina && 
      e.tipo != BatchExpenseType.vacunas
    ).fold<double>(0.0, (sum, e) => sum + e.monto);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Egresos (Costos)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildExpenseRow(
              'Costo de Pollitos',
              batch.costoCompraLote,
              Icons.pets,
              Colors.blue,
            ),
            _buildExpenseRow(
              'Total Alimento',
              gastosAlimento,
              Icons.restaurant,
              Colors.orange,
            ),
            _buildExpenseRow(
              'Total Salud (Medicinas + Vacunas)',
              gastosSalud,
              Icons.medical_services,
              Colors.red,
            ),
            _buildExpenseRow(
              'Otros Gastos',
              otrosGastos,
              Icons.more_horiz,
              Colors.grey,
            ),
            const Divider(),
            _buildExpenseRow(
              'Total Gastos',
              batch.costoCompraLote + gastosAlimento + gastosSalud + otrosGastos,
              Icons.calculate,
              Colors.red,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseRow(String label, double amount, IconData icon, Color color, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: isTotal ? 24 : 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isTotal ? 16 : 14,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                color: Colors.grey[700],
              ),
            ),
          ),
          Text(
            NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(amount),
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: FontWeight.bold,
              color: isTotal ? Colors.red : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesPieChart(BuildContext context, List<BatchExpense> expenses) {
    final batch = this.batch;
    
    // Calcular valores por categoría
    final gastosAlimento = expenses.where((e) => e.tipo == BatchExpenseType.alimento).fold<double>(0.0, (sum, e) => sum + e.monto);
    final gastosMedicina = expenses.where((e) => e.tipo == BatchExpenseType.medicina).fold<double>(0.0, (sum, e) => sum + e.monto);
    final gastosVacunas = expenses.where((e) => e.tipo == BatchExpenseType.vacunas).fold<double>(0.0, (sum, e) => sum + e.monto);
    final gastosInsumos = expenses.where((e) => e.tipo == BatchExpenseType.insumos).fold<double>(0.0, (sum, e) => sum + e.monto);
    final gastosManoObra = expenses.where((e) => e.tipo == BatchExpenseType.manoObra).fold<double>(0.0, (sum, e) => sum + e.monto);
    final otrosGastos = expenses.where((e) => e.tipo == BatchExpenseType.otros).fold<double>(0.0, (sum, e) => sum + e.monto);
    final costoPollitos = batch.costoCompraLote;

    final total = costoPollitos + gastosAlimento + gastosMedicina + gastosVacunas + gastosInsumos + gastosManoObra + otrosGastos;

    if (total == 0) {
      return const SizedBox.shrink();
    }

    final sections = <PieChartSectionData>[];

    if (costoPollitos > 0) {
      sections.add(_buildPieSection('Pollitos', costoPollitos, total, Colors.blue));
    }
    if (gastosAlimento > 0) {
      sections.add(_buildPieSection('Alimento', gastosAlimento, total, Colors.orange));
    }
    if (gastosMedicina > 0) {
      sections.add(_buildPieSection('Medicina', gastosMedicina, total, Colors.red));
    }
    if (gastosVacunas > 0) {
      sections.add(_buildPieSection('Vacunas', gastosVacunas, total, Colors.blue[300]!));
    }
    if (gastosInsumos > 0) {
      sections.add(_buildPieSection('Insumos', gastosInsumos, total, Colors.purple));
    }
    if (gastosManoObra > 0) {
      sections.add(_buildPieSection('Mano Obra', gastosManoObra, total, Colors.green));
    }
    if (otrosGastos > 0) {
      sections.add(_buildPieSection('Otros', otrosGastos, total, Colors.grey));
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
              'Distribución de Gastos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 60,
                  sections: sections,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: sections.map((section) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: section.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      section.title ?? '',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  PieChartSectionData _buildPieSection(String label, double value, double total, Color color) {
    final percentage = (value / total) * 100;
    return PieChartSectionData(
      color: color,
      value: value,
      title: percentage > 5 ? '${percentage.toStringAsFixed(1)}%' : '', // Solo mostrar si es > 5% para evitar texto pequeño
      radius: 60,
      titleStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildFinalResult(
    BuildContext context,
    List<BatchExpense> expenses,
    BatchSale? sale,
    BroilerBatch batch,
  ) {
    final totalGastos = batch.costoCompraLote + expenses.fold<double>(0.0, (sum, e) => sum + e.monto);
    final totalVenta = sale?.totalVenta ?? 0.0;
    final utilidadNeta = totalVenta - totalGastos;
    final esRentable = utilidadNeta >= 0;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: esRentable ? Colors.green[50] : Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Utilidad Neta',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(utilidadNeta),
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: esRentable ? Colors.green[700] : Colors.red[700],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      'Ingresos',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(totalVenta),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: Colors.grey[300],
                ),
                Column(
                  children: [
                    Text(
                      'Gastos',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(totalGastos),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, double value, double total, Color color) {
    final percentage = (value / total) * 100;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

