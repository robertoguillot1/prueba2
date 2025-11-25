import 'package:flutter/material.dart';
import '../../../../presentation/widgets/charts/produccion_diaria_chart.dart';
import '../../../../domain/entities/bovinos/produccion_leche.dart';

/// Widget específico para gráfica de producción diaria de leche
class LecheDiariaChart extends StatelessWidget {
  final List<ProduccionLeche> producciones;

  const LecheDiariaChart({
    super.key,
    required this.producciones,
  });

  @override
  Widget build(BuildContext context) {
    final chartData = producciones.map((p) => {
      'date': p.recordDate,
      'cantidad': p.litersProduced,
    }).toList();

    return ProduccionDiariaChart(
      data: chartData,
      title: 'Producción Diaria de Leche',
      unidad: 'litros',
      barColor: Colors.blue,
    );
  }
}

