import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/layer_batch.dart';
import '../models/layer_production_record.dart';

class LayerProductionChart extends StatelessWidget {
  final LayerBatch batch;
  final List<LayerProductionRecord> records;
  final Color primaryColor;

  const LayerProductionChart({
    super.key,
    required this.batch,
    required this.records,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'Faltan datos para generar gráfica\n(Registra producción diaria)',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    // Agrupar registros por semana
    final Map<int, List<LayerProductionRecord>> recordsByWeek = {};
    
    for (final record in records) {
      final semanasDesdeNacimiento = batch.fechaNacimiento.difference(record.fecha).inDays ~/ 7;
      final semana = batch.semanasVida - semanasDesdeNacimiento;
      
      if (semana >= 0) {
        recordsByWeek.putIfAbsent(semana, () => []).add(record);
      }
    }

    if (recordsByWeek.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'Faltan datos para generar gráfica',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    // Calcular porcentaje de postura por semana
    final List<FlSpot> spots = [];
    final List<FlSpot> alertSpots = []; // Puntos de alerta (caída > 5%)
    
    final semanas = recordsByWeek.keys.toList()..sort();
    double? porcentajeAnterior;

    for (final semana in semanas) {
      final semanaRecords = recordsByWeek[semana]!;
      final totalHuevos = semanaRecords.fold<int>(0, (sum, r) => sum + r.cantidadHuevos);
      final promedioHuevos = totalHuevos / semanaRecords.length;
      final porcentajePostura = (promedioHuevos / batch.cantidadGallinas) * 100;

      spots.add(FlSpot(semana.toDouble(), porcentajePostura));

      // Detectar caída brusca (> 5%)
      if (porcentajeAnterior != null) {
        final diferencia = porcentajeAnterior - porcentajePostura;
        if (diferencia > 5) {
          alertSpots.add(FlSpot(semana.toDouble(), porcentajePostura));
        }
      }

      porcentajeAnterior = porcentajePostura;
    }

    if (spots.length < 2) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'Faltan datos para generar gráfica\n(Se requieren al menos 2 semanas)',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final maxY = (spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) * 1.1)
        .clamp(0.0, 100.0);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 10,
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
              interval: 10,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}%',
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
                // Mostrar punto rojo si es una alerta
                final isAlert = alertSpots.any((alert) => 
                  (alert.x - spot.x).abs() < 0.1 && (alert.y - spot.y).abs() < 1
                );
                
                return FlDotCirclePainter(
                  radius: isAlert ? 6 : 4,
                  color: isAlert ? Colors.red : primaryColor,
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
        minX: semanas.first.toDouble() - 1,
        maxX: semanas.last.toDouble() + 1,
        minY: 0,
        maxY: maxY,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => Colors.white,
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final isAlert = alertSpots.any((alert) => 
                  (alert.x - barSpot.x).abs() < 0.1 && (alert.y - barSpot.y).abs() < 1
                );
                
                return LineTooltipItem(
                  'Semana ${barSpot.x.toInt()}\n${barSpot.y.toStringAsFixed(1)}%${isAlert ? '\n⚠️ Alerta' : ''}',
                  TextStyle(
                    color: isAlert ? Colors.red : Colors.black87,
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

