import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/broiler_batch.dart';

class BroilerMortalityChart extends StatelessWidget {
  final BroilerBatch batch;

  const BroilerMortalityChart({
    super.key,
    required this.batch,
  });

  @override
  Widget build(BuildContext context) {
    final vivos = batch.cantidadActual;
    final muertos = batch.cantidadInicial - batch.cantidadActual;
    
    if (batch.cantidadInicial == 0) {
      return const Center(
        child: Text(
          'No hay datos disponibles',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final porcentajeVivos = (vivos / batch.cantidadInicial) * 100;
    final porcentajeMuertos = (muertos / batch.cantidadInicial) * 100;

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 50,
        sections: [
          PieChartSectionData(
            color: Colors.green,
            value: vivos.toDouble(),
            title: '${vivos}\n(${porcentajeVivos.toStringAsFixed(1)}%)',
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (muertos > 0)
            PieChartSectionData(
              color: Colors.red,
              value: muertos.toDouble(),
              title: '${muertos}\n(${porcentajeMuertos.toStringAsFixed(1)}%)',
              radius: 60,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}

