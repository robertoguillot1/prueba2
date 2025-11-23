import 'package:flutter/material.dart';
import '../../../../presentation/widgets/charts/asistencia_mensual_chart.dart';
import '../../../../domain/entities/trabajadores/asistencia.dart';
import 'package:intl/intl.dart';

/// Widget específico para gráfica de asistencia mensual de trabajadores
class AsistenciaMensualChartWidget extends StatelessWidget {
  final List<Asistencia> asistencias;

  const AsistenciaMensualChartWidget({
    super.key,
    required this.asistencias,
  });

  @override
  Widget build(BuildContext context) {
    // Agrupar por mes
    final Map<String, Map<String, int>> datosPorMes = {};
    
    for (final asistencia in asistencias) {
      final mes = DateFormat('MMM yyyy', 'es').format(asistencia.fecha);
      
      if (!datosPorMes.containsKey(mes)) {
        datosPorMes[mes] = {'presentes': 0, 'ausentes': 0};
      }
      
      if (asistencia.presente) {
        datosPorMes[mes]!['presentes'] = datosPorMes[mes]!['presentes']! + 1;
      } else {
        datosPorMes[mes]!['ausentes'] = datosPorMes[mes]!['ausentes']! + 1;
      }
    }

    final chartData = datosPorMes.entries.map((entry) => {
      'mes': entry.key,
      'presentes': entry.value['presentes']!,
      'ausentes': entry.value['ausentes']!,
    }).toList();

    // Ordenar por fecha
    chartData.sort((a, b) {
      final dateA = DateFormat('MMM yyyy', 'es').parse(a['mes'] as String);
      final dateB = DateFormat('MMM yyyy', 'es').parse(b['mes'] as String);
      return dateA.compareTo(dateB);
    });

    return AsistenciaMensualChart(
      data: chartData,
      title: 'Asistencia Mensual de Trabajadores',
    );
  }
}

