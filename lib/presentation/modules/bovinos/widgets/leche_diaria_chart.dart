import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../features/cattle/domain/entities/milk_production_entity.dart';

/// Widget de gráfico para producción diaria de leche
class LecheDiariaChart extends StatelessWidget {
  final List<MilkProductionEntity> registros;

  const LecheDiariaChart({
    super.key,
    required this.registros,
  });

  @override
  Widget build(BuildContext context) {
    // Validar que hay suficientes datos
    if (registros.isEmpty || registros.length < 2) {
      return _buildInsufficientDataPlaceholder(context);
    }

    // Preparar datos para el gráfico
    final sortedData = List<MilkProductionEntity>.from(registros);
    sortedData.sort((a, b) => a.recordDate.compareTo(b.recordDate));

    // Tomar los últimos 10 registros
    final displayData = sortedData.length > 10
        ? sortedData.sublist(sortedData.length - 10)
        : sortedData;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Row(
              children: [
                Icon(Icons.local_drink, color: Colors.blue.shade600, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Producción de Leche (Últimos ${displayData.length} registros)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Gráfico
            SizedBox(
              height: 250,
              child: LineChart(_buildLineChartData(displayData, context)),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye los datos del gráfico
  LineChartData _buildLineChartData(
    List<MilkProductionEntity> data,
    BuildContext context,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calcular valores min y max para el eje Y
    final litersValues = data.map((r) => r.litersProduced).whereType<double>().toList();
    if (litersValues.isEmpty) {
      return LineChartData(); // Retornar gráfico vacío si no hay datos
    }
    final minY = litersValues.reduce((a, b) => a < b ? a : b);
    final maxY = litersValues.reduce((a, b) => a > b ? a : b);

    // Agregar margen al eje Y
    final yMargin = (maxY - minY) * 0.2;
    final chartMinY = (minY - yMargin).clamp(0.0, double.infinity).toDouble();
    final chartMaxY = (maxY + yMargin).toDouble();

    // Crear puntos del gráfico
    final spots = data.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        entry.value.litersProduced,
      );
    }).toList();

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: (chartMaxY - chartMinY) / 5,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
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
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= 0 && value.toInt() < data.length) {
                final date = data[value.toInt()].recordDate;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    DateFormat('dd/MM').format(date),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
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
            reservedSize: 40,
            interval: (chartMaxY - chartMinY) / 5,
            getTitlesWidget: (value, meta) {
              return Text(
                '${value.toStringAsFixed(1)}L',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
          left: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      minX: 0,
      maxX: (data.length - 1).toDouble(),
      minY: chartMinY,
      maxY: chartMaxY,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Colors.blue,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: Colors.white,
                strokeWidth: 2,
                strokeColor: Colors.blue,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                Colors.blue.withOpacity(0.3),
                Colors.blue.withOpacity(0.05),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final date = data[spot.x.toInt()].recordDate;
              return LineTooltipItem(
                '${DateFormat('dd/MM').format(date)}\n${spot.y.toStringAsFixed(1)}L',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  /// Placeholder cuando no hay datos suficientes
  Widget _buildInsufficientDataPlaceholder(BuildContext context) {
    return Card(
      child: Container(
        height: 250,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Insuficientes datos para graficar',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Registra al menos 2 producciones de leche para ver la tendencia',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade500,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
