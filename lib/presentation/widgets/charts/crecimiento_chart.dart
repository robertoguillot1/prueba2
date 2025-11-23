import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

/// Gráfica de línea para mostrar crecimiento (peso de cerdos)
class CrecimientoChart extends StatelessWidget {
  final List<Map<String, dynamic>> data; // [{date: DateTime, peso: double}]
  final String title;
  final Color lineColor;

  const CrecimientoChart({
    super.key,
    required this.data,
    this.title = 'Línea de Crecimiento',
    this.lineColor = Colors.purple,
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
              child: LineChart(
                LineChartData(
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
                  minX: 0,
                  maxX: (data.length - 1).toDouble(),
                  minY: _getMinY(),
                  maxY: _getMaxY(),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _generateSpots(),
                      isCurved: true,
                      color: lineColor,
                      barWidth: 4,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: lineColor,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: lineColor.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  label: 'Peso inicial',
                  value: '${data.first['peso'].toStringAsFixed(1)} kg',
                ),
                _StatItem(
                  label: 'Peso actual',
                  value: '${data.last['peso'].toStringAsFixed(1)} kg',
                ),
                _StatItem(
                  label: 'Ganancia',
                  value: '${(data.last['peso'] - data.first['peso']).toStringAsFixed(1)} kg',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _generateSpots() {
    return data.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        entry.value['peso'] as double,
      );
    }).toList();
  }

  double _getMinY() {
    if (data.isEmpty) return 0;
    final min = data.map((d) => d['peso'] as double).reduce((a, b) => a < b ? a : b);
    return (min * 0.9).floorToDouble();
  }

  double _getMaxY() {
    if (data.isEmpty) return 100;
    final max = data.map((d) => d['peso'] as double).reduce((a, b) => a > b ? a : b);
    return (max * 1.1).ceilToDouble();
  }

  double _calculateInterval() {
    final min = _getMinY();
    final max = _getMaxY();
    return (max - min) / 5;
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }
}


