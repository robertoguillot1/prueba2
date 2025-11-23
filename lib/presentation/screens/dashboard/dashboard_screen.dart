import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../modules/bovinos/list/bovinos_list_screen.dart';
import '../../modules/porcinos/list/cerdos_list_screen.dart';
import '../../modules/ovinos/list/ovejas_list_screen.dart';
import '../../modules/avicultura/list/gallinas_list_screen.dart';
import '../../modules/trabajadores/list/trabajadores_list_screen.dart';
import 'viewmodels/dashboard_viewmodel.dart';
import 'models/dashboard_alert.dart';
import 'models/inventory_summary.dart';

/// Dashboard Operativo Inteligente
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<DashboardViewModel>();
      viewModel.loadDashboardData(widget.farmId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          final viewModel = context.read<DashboardViewModel>();
          await viewModel.refresh(widget.farmId);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeHeader(),
              const SizedBox(height: 24),
              _buildAlertsSection(),
              const SizedBox(height: 24),
              _buildInventorySummary(),
              const SizedBox(height: 24),
              _buildQuickActions(),
            ],
          ),
        ),
      ),
    );
  }

  /// Encabezado de Bienvenida
  Widget _buildWelcomeHeader() {
    final dateFormat = DateFormat('EEEE, d \'de\' MMMM \'de\' yyyy');
    final timeFormat = DateFormat('HH:mm');
    final now = DateTime.now();
    
    String saludo;
    final hour = now.hour;
    if (hour >= 6 && hour < 12) {
      saludo = 'Buenos días';
    } else if (hour >= 12 && hour < 19) {
      saludo = 'Buenas tardes';
    } else {
      saludo = 'Buenas noches';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$saludo,',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            dateFormat.format(now),
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            timeFormat.format(now),
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  /// Sección de Alertas Dinámicas
  Widget _buildAlertsSection() {
    return Consumer<DashboardViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final alerts = viewModel.alerts;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.notifications_active,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Atención Requerida',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (alerts.isEmpty)
              _buildNoAlertsCard()
            else
              ...alerts.map((alert) => _buildAlertCard(alert)),
          ],
        );
      },
    );
  }

  Widget _buildNoAlertsCard() {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Todo bajo control en la finca',
                style: TextStyle(
                  color: Colors.green.shade900,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(DashboardAlert alert) {
    MaterialColor alertColor;
    IconData alertIcon;

    switch (alert.severidad) {
      case AlertSeverity.critica:
        alertColor = Colors.red;
        alertIcon = Icons.error;
        break;
      case AlertSeverity.media:
        alertColor = Colors.orange;
        alertIcon = Icons.warning;
        break;
      case AlertSeverity.baja:
        alertColor = Colors.blue;
        alertIcon = Icons.info;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: alertColor.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: alertColor.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(alertIcon, color: alertColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.titulo,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: alertColor.shade900,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    alert.mensaje,
                    style: TextStyle(
                      color: alertColor.shade800,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Resumen de Inventario
  Widget _buildInventorySummary() {
    return Consumer<DashboardViewModel>(
      builder: (context, viewModel, child) {
        final summary = viewModel.summary;

        if (summary == null) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen de Inventario',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                _SummaryCard(
                  title: 'Vacas',
                  value: '${summary.totalBovinos}',
                  subtitle: '${summary.vacasEnOrdeno} en produccion',
                  icon: Icons.agriculture,
                  color: Colors.brown,
                  onTap: () => _navigateToBovinos(context),
                ),
                _SummaryCard(
                  title: 'Cerdos',
                  value: '${summary.totalCerdos}',
                  icon: Icons.pets,
                  color: Colors.pink,
                  onTap: () => _navigateToCerdos(context),
                ),
                _SummaryCard(
                  title: 'Aves',
                  value: '${summary.totalAves}',
                  icon: Icons.egg,
                  color: Colors.orange,
                  onTap: () => _navigateToAves(context),
                ),
                _SummaryCard(
                  title: 'Ovinos',
                  value: '${summary.totalOvinos}',
                  icon: Icons.pets_outlined,
                  color: Colors.blue,
                  onTap: () => _navigateToOvinos(context),
                ),
                _SummaryCard(
                  title: 'Trabajadores',
                  value: '${summary.trabajadoresActivos}',
                  subtitle: 'activos',
                  icon: Icons.people,
                  color: Colors.green,
                  onTap: () => _navigateToTrabajadores(context),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  /// Accesos Rápidos
  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Accesos Rápidos',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _QuickActionButton(
              icon: Icons.opacity,
              label: 'Registrar\nLeche',
              color: Colors.blue,
              onTap: () {
                // TODO: Navegar a registro de leche
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Funcionalidad en desarrollo')),
                );
              },
            ),
            _QuickActionButton(
              icon: Icons.egg,
              label: 'Registrar\nHuevos',
              color: Colors.orange,
              onTap: () {
                // TODO: Navegar a registro de huevos
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Funcionalidad en desarrollo')),
                );
              },
            ),
            _QuickActionButton(
              icon: Icons.child_care,
              label: 'Nuevo\nNacimiento',
              color: Colors.green,
              onTap: () {
                // TODO: Navegar a nuevo nacimiento
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Funcionalidad en desarrollo')),
                );
              },
            ),
            _QuickActionButton(
              icon: Icons.payment,
              label: 'Registrar\nGasto',
              color: Colors.red,
              onTap: () {
                // TODO: Navegar a registro de gasto
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Funcionalidad en desarrollo')),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  // Métodos de navegación
  void _navigateToBovinos(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BovinosListScreen(farmId: widget.farmId),
      ),
    );
  }

  void _navigateToCerdos(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CerdosListScreen(farmId: widget.farmId),
      ),
    );
  }

  void _navigateToOvinos(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OvejasListScreen(farmId: widget.farmId),
      ),
    );
  }

  void _navigateToAves(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GallinasListScreen(farmId: widget.farmId),
      ),
    );
  }

  void _navigateToTrabajadores(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TrabajadoresListScreen(farmId: widget.farmId),
      ),
    );
  }
}

/// Widget para tarjeta de resumen
class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _SummaryCard({
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget para botón de acción rápida
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
