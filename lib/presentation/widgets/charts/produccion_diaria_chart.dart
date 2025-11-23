import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

/// Gráfica de barras para producción diaria (huevos, leche, etc.)
class ProduccionDiariaChart extends StatelessWidget {
  final List<Map<String, dynamic>> data; // [{date: DateTime, cantidad: double}]
  final String title;
  final String unidad; // 'huevos', 'litros', etc.
  final Color barColor;

  const ProduccionDiariaChart({
    super.key,
    required this.data,
    this.title = 'Producción Diaria',
    this.unidad = '',
    this.barColor = Colors.green,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text('No hay datos para mostrar'),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: _calculateInterval(),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < data.length) {
                            final date = data[value.toInt()]['date'] as DateTime;
                            return Text(
                              DateFormat('dd/MM').format(date),
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  barGroups: _generateBarGroups(),
                  maxY: _getMaxY(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Promedio: ${_getPromedio().toStringAsFixed(1)} $unidad',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _generateBarGroups() {
    return data.asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value['cantidad'] as double,
            color: barColor,
            width: 12,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();
  }

  double _getMaxY() {
    if (data.isEmpty) return 100;
    final max = data.map((d) => d['cantidad'] as double).reduce((a, b) => a > b ? a : b);
    return (max * 1.2).ceilToDouble();
  }

  double _calculateInterval() {
    final max = _getMaxY();
    return max / 5;
  }

  double _getPromedio() {
    if (data.isEmpty) return 0;
    final total = data.fold<double>(0, (sum, d) => sum + (d['cantidad'] as double));
    return total / data.length;
  }
}

