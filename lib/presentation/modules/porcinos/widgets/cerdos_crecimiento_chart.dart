import 'package:flutter/material.dart';
import '../../../../presentation/widgets/charts/crecimiento_chart.dart';
import '../../../../domain/entities/porcinos/peso_cerdo.dart';

/// Widget específico para gráfica de crecimiento de cerdos
class CerdosCrecimientoChart extends StatelessWidget {
  final List<PesoCerdo> registros;

  const CerdosCrecimientoChart({
    super.key,
    required this.registros,
  });

  @override
  Widget build(BuildContext context) {
    final chartData = registros.map((r) => {
      'date': r.recordDate,
      'peso': r.weight,
    }).toList();

    return CrecimientoChart(
      data: chartData,
      title: 'Línea de Crecimiento - Cerdos',
      lineColor: Colors.purple,
    );
  }
}

