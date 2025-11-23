import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Gráfica de pastel para distribución de datos
class PieChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> data; // [{label: String, value: double, color: Color}]
  final String title;
  final double radius;

  const PieChartWidget({
    super.key,
    required this.data,
    this.title = 'Distribución',
    this.radius = 80,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text('No hay datos para mostrar'),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: radius * 2,
                  height: radius * 2,
                  child: PieChart(
                    PieChartData(
                      sections: _generateSections(),
                      sectionsSpace: 2,
                      centerSpaceRadius: radius * 0.4,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _generateLegend(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _generateSections() {
    final total = data.fold<double>(0, (sum, d) => sum + (d['value'] as double));
    
    return data.map((item) {
      final value = item['value'] as double;
      final percentage = (value / total * 100);
      
      return PieChartSectionData(
        value: value,
        title: '${percentage.toStringAsFixed(1)}%',
        color: item['color'] as Color,
        radius: radius * 0.8,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<Widget> _generateLegend(BuildContext context) {
    return data.map((item) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: item['color'] as Color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item['label'] as String,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            Text(
              '${item['value']}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      );
    }).toList();
  }
}

