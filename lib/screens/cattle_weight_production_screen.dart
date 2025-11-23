import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';
import '../models/cattle.dart';
import '../models/cattle_weight_record.dart';
import 'cattle_weight_form_screen.dart';

class CattleWeightProductionScreen extends StatelessWidget {
  final Farm farm;
  final Cattle cattle;

  const CattleWeightProductionScreen({
    super.key,
    required this.farm,
    required this.cattle,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<FarmProvider>(
      builder: (context, farmProvider, _child) {
        final updatedFarm = farmProvider.farms.firstWhere(
          (f) => f.id == farm.id,
          orElse: () => farm,
        );

        final weightRecords = farmProvider.getCattleWeightRecords(cattle.id, farmId: updatedFarm.id);
        
        // Calcular cambios de peso
        final weightChanges = <Map<String, dynamic>>[];
        for (int i = 1; i < weightRecords.length; i++) {
          final change = weightRecords[i - 1].weight - weightRecords[i].weight;
          weightChanges.add({
            'from': weightRecords[i].weight,
            'to': weightRecords[i - 1].weight,
            'change': change,
            'date': weightRecords[i - 1].recordDate,
          });
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Producción - ${cattle.name ?? cattle.identification ?? 'Vaca'}'),
            centerTitle: true,
            backgroundColor: farm.primaryColor,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CattleWeightFormScreen(
                        farm: updatedFarm,
                        selectedCattle: cattle,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: weightRecords.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.trending_up, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text(
                        'No hay registros de peso',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Agrega registros para ver la producción',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Resumen
                      _buildSummaryCard(context, weightRecords),
                      const SizedBox(height: 16),

                      // Gráfico de evolución de peso
                      _buildWeightChart(context, weightRecords),
                      const SizedBox(height: 16),

                      // Tabla de registros
                      _buildWeightTable(context, weightRecords, weightChanges),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildSummaryCard(BuildContext context, List<CattleWeightRecord> records) {
    final latestRecord = records.first;
    final oldestRecord = records.last;
    final totalChange = latestRecord.weight - oldestRecord.weight;
    final avgWeight = records.fold(0.0, (sum, r) => sum + r.weight) / records.length;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _buildSummaryItem(
                context,
                'Peso Actual',
                '${latestRecord.weight.toStringAsFixed(1)} kg',
                Icons.monitor_weight,
                Colors.blue,
              ),
            ),
            Expanded(
              child: _buildSummaryItem(
                context,
                'Cambio Total',
                '${totalChange >= 0 ? "+" : ""}${totalChange.toStringAsFixed(1)} kg',
                Icons.trending_up,
                totalChange >= 0 ? Colors.green : Colors.red,
              ),
            ),
            Expanded(
              child: _buildSummaryItem(
                context,
                'Promedio',
                '${avgWeight.toStringAsFixed(1)} kg',
                Icons.analytics,
                Colors.purple,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context, String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildWeightChart(BuildContext context, List<CattleWeightRecord> records) {
    if (records.length < 2) {
      return const SizedBox.shrink();
    }

    // Preparar datos para el gráfico
    final spots = records.reversed.map((record) {
      return FlSpot(
        (records.length - records.indexOf(record)).toDouble() - 1,
        record.weight,
      );
    }).toList();

    final minWeight = records.map((r) => r.weight).reduce((a, b) => a < b ? a : b);
    final maxWeight = records.map((r) => r.weight).reduce((a, b) => a > b ? a : b);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Evolución de Peso',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  lineTouchData: LineTouchData(enabled: true),
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < records.length) {
                            final record = records[records.length - value.toInt() - 1];
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                DateFormat('dd/MM').format(record.recordDate),
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
                            value.toStringAsFixed(0),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: farm.primaryColor,
                      barWidth: 3,
                      dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: farm.primaryColor,
                        );
                      }),
                    ),
                  ],
                  minY: minWeight - 20,
                  maxY: maxWeight + 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightTable(BuildContext context, List<CattleWeightRecord> records, List<Map<String, dynamic>> changes) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Historial de Pesos',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Table(
              border: TableBorder(
                horizontalInside: BorderSide(color: Colors.grey[300]!),
              ),
              children: [
                TableRow(
                  decoration: BoxDecoration(color: farm.primaryColor.withOpacity(0.1)),
                  children: [
                    _buildTableCell('Fecha', isHeader: true),
                    _buildTableCell('Peso (kg)', isHeader: true),
                    _buildTableCell('Cambio', isHeader: true),
                  ],
                ),
                ...records.asMap().entries.map((entry) {
                  final index = entry.key;
                  final record = entry.value;
                  final change = index < changes.length 
                      ? changes[index]['change'] 
                      : 0.0;
                  final changeText = index > 0
                      ? '${change >= 0 ? "+" : ""}${change.toStringAsFixed(1)} kg'
                      : '-';
                  final changeColor = index > 0
                      ? (change >= 0 ? Colors.green : Colors.red)
                      : Colors.grey;

                  return TableRow(
                    children: [
                      _buildTableCell(DateFormat('dd/MM/yyyy').format(record.recordDate)),
                      _buildTableCell(record.weight.toStringAsFixed(1)),
                      _buildTableCell(changeText, color: changeColor),
                    ],
                  );
                }).toList(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: color ?? (isHeader ? farm.primaryColor : Colors.black),
        ),
      ),
    );
  }
}























