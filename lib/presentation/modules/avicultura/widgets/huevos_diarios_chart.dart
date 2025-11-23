import 'package:flutter/material.dart';
import '../../../../presentation/widgets/charts/produccion_diaria_chart.dart';
import '../../../../domain/entities/avicultura/produccion_huevos.dart';

/// Widget específico para gráfica de producción diaria de huevos
class HuevosDiariosChart extends StatelessWidget {
  final List<ProduccionHuevos> producciones;

  const HuevosDiariosChart({
    super.key,
    required this.producciones,
  });

  @override
  Widget build(BuildContext context) {
    final chartData = producciones.map((p) => {
      'date': p.fecha,
      'cantidad': p.cantidadHuevos.toDouble(),
    }).toList();

    return ProduccionDiariaChart(
      data: chartData,
      title: 'Producción Diaria de Huevos',
      unidad: 'huevos',
      barColor: Colors.orange,
    );
  }
}

