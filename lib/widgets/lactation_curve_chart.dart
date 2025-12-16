import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/milk_production.dart';

class LactationCurveChart extends StatelessWidget {
  final List<MilkProduction> milkRecords;
  final Color primaryColor;

  const LactationCurveChart({
    super.key,
    required this.milkRecords,
    this.primaryColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    if (milkRecords.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text(
              'No hay datos suficientes para generar la gráfica',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    // Ordenar registros por fecha
    final sortedRecords = List<MilkProduction>.from(milkRecords)
      ..sort((a, b) => a.recordDate.compareTo(b.recordDate));

    // Calcular estadísticas
    final promedioUltimos7Dias = _calcularPromedioUltimos7Dias(sortedRecords);
    final totalLactanciaActual = _calcularTotalLactanciaActual(sortedRecords);

    // Preparar datos para el gráfico
    final spots = <FlSpot>[];
    final minDate = sortedRecords.first.recordDate;
    
    for (int i = 0; i < sortedRecords.length; i++) {
      final record = sortedRecords[i];
      final daysSinceStart = record.recordDate.difference(minDate).inDays;
      spots.add(FlSpot(daysSinceStart.toDouble(), record.litersProduced));
    }

    // Calcular valores para los ejes
    final maxLiters = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final maxDays = spots.map((s) => s.x).reduce((a, b) => a > b ? a : b);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Estadísticas
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Promedio Diario\n(Últimos 7 días)',
                    '${promedioUltimos7Dias.toStringAsFixed(1)} L',
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Total Lactancia\nActual',
                    '${totalLactanciaActual.toStringAsFixed(1)} L',
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Título del gráfico
            const Text(
              'Curva de Lactancia',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Producción de Leche vs Días',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            // Gráfico
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxLiters > 0 ? (maxLiters / 5).ceilToDouble() : 5,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withValues(alpha: 0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: maxDays > 0 ? (maxDays / 5).ceilToDouble() : 7,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() % 7 == 0 || value == meta.min || value == meta.max) {
                            final date = minDate.add(Duration(days: value.toInt()));
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                DateFormat('dd/MM').format(date),
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
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
                        interval: maxLiters > 0 ? (maxLiters / 5).ceilToDouble() : 5,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: primaryColor,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: primaryColor,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: primaryColor.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                  minX: 0,
                  maxX: maxDays > 0 ? maxDays.toDouble() : 30,
                  minY: 0,
                  maxY: maxLiters > 0 ? (maxLiters * 1.2) : 20,
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                        return touchedSpots.map((barSpot) {
                          final date = minDate.add(Duration(days: barSpot.x.toInt()));
                          return LineTooltipItem(
                            '${DateFormat('dd/MM/yyyy').format(date)}\n${barSpot.y.toStringAsFixed(1)} L',
                            const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  double _calcularPromedioUltimos7Dias(List<MilkProduction> records) {
    if (records.isEmpty) return 0.0;
    
    final now = DateTime.now();
    final ultimos7Dias = records.where((record) {
      final daysDiff = now.difference(record.recordDate).inDays;
      return daysDiff <= 7;
    }).toList();

    if (ultimos7Dias.isEmpty) return 0.0;
    
    final total = ultimos7Dias.fold(0.0, (sum, record) => sum + record.litersProduced);
    return total / ultimos7Dias.length;
  }

  double _calcularTotalLactanciaActual(List<MilkProduction> records) {
    if (records.isEmpty) return 0.0;
    
    // Calcular desde el último parto (asumiendo que el primer registro es después del parto)
    // O simplemente sumar todos los registros
    return records.fold(0.0, (sum, record) => sum + record.litersProduced);
  }
}

