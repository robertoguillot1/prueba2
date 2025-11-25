import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/report_service.dart';
import '../../../core/utils/advanced_calculations.dart';
import '../../modules/ovinos/viewmodels/ovejas_viewmodel.dart';
import '../../modules/bovinos/viewmodels/bovinos_viewmodel.dart';
import '../../modules/avicultura/viewmodels/gallinas_viewmodel.dart';
import '../../widgets/charts/pie_chart_widget.dart';
import 'package:share_plus/share_plus.dart';

/// Pantalla de dashboard con estadísticas y gráficas
class DashboardScreen extends StatefulWidget {
  final String farmId;

  const DashboardScreen({
    super.key,
    required this.farmId,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ReportService _reportService = ReportService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportReport,
            tooltip: 'Exportar reporte',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCards(),
              const SizedBox(height: 24),
              _buildChartsSection(),
              const SizedBox(height: 24),
              _buildAlertsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Consumer3<OvejasViewModel, BovinosViewModel, GallinasViewModel>(
      builder: (context, ovejasVM, bovinosVM, gallinasVM, _) {
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _SummaryCard(
              title: 'Ovinos',
              value: ovejasVM.ovejas.length.toString(),
              icon: Icons.pets,
              color: Colors.blue,
            ),
            _SummaryCard(
              title: 'Bovinos',
              value: bovinosVM.bovinos.length.toString(),
              icon: Icons.agriculture,
              color: Colors.brown,
            ),
            _SummaryCard(
              title: 'Avicultura',
              value: gallinasVM.gallinas.length.toString(),
              icon: Icons.egg,
              color: Colors.orange,
            ),
            _SummaryCard(
              title: 'Total',
              value: (ovejasVM.ovejas.length + bovinosVM.bovinos.length + gallinasVM.gallinas.length).toString(),
              icon: Icons.agriculture,
              color: Colors.green,
            ),
          ],
        );
      },
    );
  }

  Widget _buildChartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Distribución',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Consumer3<OvejasViewModel, BovinosViewModel, GallinasViewModel>(
          builder: (context, ovejasVM, bovinosVM, gallinasVM, _) {
            final total = ovejasVM.ovejas.length +
                bovinosVM.bovinos.length +
                gallinasVM.gallinas.length;
            
            if (total == 0) {
              return const Center(
                child: Text('No hay datos para mostrar'),
              );
            }

            return PieChartWidget(
              data: [
                {
                  'label': 'Ovinos',
                  'value': ovejasVM.ovejas.length.toDouble(),
                  'color': Colors.blue,
                },
                {
                  'label': 'Bovinos',
                  'value': bovinosVM.bovinos.length.toDouble(),
                  'color': Colors.brown,
                },
                {
                  'label': 'Avicultura',
                  'value': gallinasVM.gallinas.length.toDouble(),
                  'color': Colors.orange,
                },
              ],
              title: 'Distribución de Animales',
            );
          },
        ),
      ],
    );
  }

  Widget _buildAlertsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alertas',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _AlertItem(
                  icon: Icons.warning,
                  message: 'Revisar animales próximos a parto',
                  color: Colors.orange,
                ),
                const Divider(),
                _AlertItem(
                  icon: Icons.health_and_safety,
                  message: 'Vacunas pendientes',
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _refreshData() async {
    // Recargar datos de todos los ViewModels
    final ovejasVM = Provider.of<OvejasViewModel>(context, listen: false);
    final bovinosVM = Provider.of<BovinosViewModel>(context, listen: false);
    final gallinasVM = Provider.of<GallinasViewModel>(context, listen: false);

    await Future.wait([
      ovejasVM.loadOvejas(widget.farmId),
      bovinosVM.loadBovinos(widget.farmId),
      gallinasVM.loadGallinas(widget.farmId),
    ]);
  }

  Future<void> _exportReport() async {
    try {
      final file = await _reportService.generateInventoryReport(
        module: 'dashboard',
        data: [],
        farmName: 'Mi Finca',
      );
      await Share.shareXFiles([XFile(file.path)]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al exportar: $e')),
        );
      }
    }
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertItem extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color color;

  const _AlertItem({
    required this.icon,
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(message),
        ),
      ],
    );
  }
}

