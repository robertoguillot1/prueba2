import 'package:flutter/material.dart';
import '../../../../presentation/widgets/charts/peso_chart.dart';
import '../../../../domain/entities/ovinos/registro_peso_oveja.dart';

/// Widget específico para gráfica de peso de ovejas
class OvejasPesoChart extends StatelessWidget {
  final List<RegistroPesoOveja> registros;

  const OvejasPesoChart({
    super.key,
    required this.registros,
  });

  @override
  Widget build(BuildContext context) {
    final chartData = registros.map((r) => {
      'date': r.fechaRegistro,
      'peso': r.peso,
    }).toList();

    return PesoChart(
      data: chartData,
      title: 'Evolución de Peso - Ovejas',
      lineColor: Colors.blue,
    );
  }
}

