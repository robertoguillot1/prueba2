import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../features/cattle/domain/entities/weight_record_entity.dart';

/// Widget de gráfico para evolución de peso
class PesoChart extends StatelessWidget {
  final List<WeightRecordEntity> registros;

  const PesoChart({
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
    final sortedData = List<WeightRecordEntity>.from(registros);
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
                Icon(Icons.show_chart, color: Colors.green.shade600, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Evolución del Peso (Últimos ${displayData.length} registros)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Indicador de ganancia
            _buildGainIndicator(context, displayData),
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

  /// Indicador de ganancia total en el periodo
  Widget _buildGainIndicator(BuildContext context, List<WeightRecordEntity> data) {
    final firstWeight = data.first.weight;
    final lastWeight = data.last.weight;
    final gain = lastWeight - firstWeight;
    final isPositive = gain >= 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (isPositive ? Colors.green : Colors.red).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            size: 16,
            color: isPositive ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 6),
          Text(
            '${isPositive ? '+' : ''}${gain.toStringAsFixed(1)} kg en este periodo',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isPositive ? Colors.green.shade700 : Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }

  /// Construye los datos del gráfico
  LineChartData _buildLineChartData(
    List<WeightRecordEntity> data,
    BuildContext context,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calcular valores min y max para el eje Y
    final weightValues = data.map((r) => r.weight).whereType<double>().toList();
    if (weightValues.isEmpty) {
      return LineChartData(); // Retornar gráfico vacío si no hay datos
    }
    final minY = weightValues.reduce((a, b) => a < b ? a : b);
    final maxY = weightValues.reduce((a, b) => a > b ? a : b);

    // Agregar margen al eje Y (20%)
    final yMargin = (maxY - minY) * 0.2;
    final chartMinY = (minY - yMargin).clamp(0.0, double.infinity).toDouble();
    final chartMaxY = (maxY + yMargin).toDouble();

    // Crear puntos del gráfico
    final spots = data.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        entry.value.weight,
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
            reservedSize: 45,
            interval: (chartMaxY - chartMinY) / 5,
            getTitlesWidget: (value, meta) {
              return Text(
                '${value.toStringAsFixed(0)} kg',
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
          color: Colors.green,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              // Resaltar el último punto (más reciente)
              final isLast = index == data.length - 1;
              return FlDotCirclePainter(
                radius: isLast ? 6 : 4,
                color: Colors.white,
                strokeWidth: 2,
                strokeColor: isLast ? Colors.green.shade700 : Colors.green,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                Colors.green.withOpacity(0.3),
                Colors.green.withOpacity(0.05),
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
              final weight = spot.y;
              
              // Calcular ganancia si no es el primer punto
              String gainText = '';
              if (spot.x.toInt() > 0) {
                final previousWeight = data[spot.x.toInt() - 1].weight;
                final gain = weight - previousWeight;
                gainText = '\n${gain >= 0 ? '+' : ''}${gain.toStringAsFixed(1)} kg';
              }
              
              return LineTooltipItem(
                '${DateFormat('dd/MM').format(date)}\n${weight.toStringAsFixed(1)} kg$gainText',
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
              'Registra al menos 2 pesajes para ver la evolución del peso',
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

