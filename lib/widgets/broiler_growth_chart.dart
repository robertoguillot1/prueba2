import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/broiler_batch.dart';

class BroilerGrowthChart extends StatelessWidget {
  final BroilerBatch batch;
  final Color primaryColor;

  const BroilerGrowthChart({
    super.key,
    required this.batch,
    required this.primaryColor,
  });

  // Tabla de referencia estándar de peso por día (en gramos)
  double _getStandardWeight(int days) {
    if (days <= 7) return 150; // 0.15 kg = 150g
    if (days <= 14) return 350; // 0.35 kg = 350g
    if (days <= 21) return 650; // 0.65 kg = 650g
    if (days <= 28) return 1000; // 1.0 kg = 1000g
    if (days <= 35) return 1500; // 1.5 kg = 1500g
    if (days <= 42) return 2200; // 2.2 kg = 2200g
    return 2800; // 2.8 kg = 2800g (45+ días)
  }

  @override
  Widget build(BuildContext context) {
    final edadActual = batch.edadActualDias;
    
    if (edadActual < 7) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'Faltan datos para generar gráfica\n(Se requieren al menos 7 días)',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    // Generar puntos de datos históricos (simulado basado en edad actual)
    // En una implementación real, estos datos vendrían de registros históricos
    final List<FlSpot> actualSpots = [];
    final List<FlSpot> standardSpots = [];
    
    final diasParaGraficar = edadActual > 45 ? 45 : edadActual;
    final intervalo = diasParaGraficar > 30 ? 7 : 3; // Cada 7 días si > 30, cada 3 si <= 30
    
    for (int dia = 0; dia <= diasParaGraficar; dia += intervalo) {
      // Peso actual estimado (usando el peso actual como referencia) - en gramos
      final pesoActual = dia == edadActual 
          ? batch.pesoPromedioActual 
          : batch.pesoPromedioActual * (dia / edadActual) * 0.9; // Estimación lineal
      
      actualSpots.add(FlSpot(dia.toDouble(), pesoActual));
      standardSpots.add(FlSpot(dia.toDouble(), _getStandardWeight(dia)));
    }

    // Agregar el punto actual real
    if (!actualSpots.any((spot) => spot.x == edadActual.toDouble())) {
      actualSpots.add(FlSpot(edadActual.toDouble(), batch.pesoPromedioActual));
    }

    // Usar la meta de peso como máximo si es mayor que el peso actual
    final maxPeso = batch.metaPesoGramos > batch.pesoPromedioActual 
        ? batch.metaPesoGramos 
        : batch.pesoPromedioActual;
    final maxY = (maxPeso * 1.2).clamp(0.0, 5000.0); // Máximo 5kg = 5000g

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 500, // Cada 500 gramos
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
              interval: intervalo.toDouble(),
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${value.toInt()}',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 500, // Cada 500 gramos
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}g',
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
          // Línea de referencia estándar
          LineChartBarData(
            spots: standardSpots,
            isCurved: true,
            color: Colors.grey.withValues(alpha: 0.5),
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
          // Línea de peso actual
          LineChartBarData(
            spots: actualSpots,
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
        maxX: diasParaGraficar.toDouble(),
        minY: 0,
        maxY: maxY,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => Colors.white,
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
            return LineTooltipItem(
              'Día ${barSpot.x.toInt()}\n${(barSpot.y / 1000).toStringAsFixed(2)} kg (${barSpot.y.toInt()} g)',
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
    );
  }
}

