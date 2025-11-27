import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/widgets/theme_switcher.dart';
import '../cubits/dashboard_cubit.dart';
import '../cubits/dashboard_state.dart';
import '../models/dashboard_alert.dart';
import '../widgets/summary_card_widget.dart';
import '../../bovinos/screens/bovino_menu_screen.dart';
import '../../porcinos/screens/porcicultura_menu_screen.dart';
import '../../ovinos/screens/caprinos_menu_screen.dart';
import '../../avicultura/screens/avicultura_menu_screen.dart';
import '../../trabajadores/screens/trabajadores_menu_screen.dart';

/// Pantalla principal del Dashboard Operativo Inteligente
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
  late DashboardCubit _dashboardCubit;

  @override
  void initState() {
    super.initState();
    _dashboardCubit = DependencyInjection.createDashboardCubit(widget.farmId);
    // Iniciar carga de datos después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _dashboardCubit.loadDashboardData();
    });
  }

  @override
  void dispose() {
    _dashboardCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DashboardCubit>.value(
      value: _dashboardCubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard Operativo'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Volver a la lista de fincas
              Navigator.pop(context);
            },
            tooltip: 'Volver a Fincas',
          ),
          actions: [
            // Botón para cambiar de finca directamente
            IconButton(
              icon: const Icon(Icons.swap_horiz),
              onPressed: () {
                // Volver a la lista de fincas para seleccionar otra
                Navigator.pushReplacementNamed(context, '/farms');
              },
              tooltip: 'Cambiar de Finca',
            ),
            const ThemeSwitcher(),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                _dashboardCubit.loadDashboardData();
              },
              tooltip: 'Actualizar',
            ),
          ],
        ),
        body: BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is DashboardError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                    const SizedBox(height: 16),
                    Text(
                      'Error',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        _dashboardCubit.loadDashboardData();
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (state is DashboardLoaded) {
              return _buildLoadedContent(context, state);
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildLoadedContent(BuildContext context, DashboardLoaded state) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final now = DateTime.now();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado
          Text(
            'Resumen de la Finca',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            dateFormat.format(now),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 24),

          // Sección de Alertas
          _buildAlertasSection(context, state.alerts),
          const SizedBox(height: 24),

          // Resumen de Inventario
          Text(
            'Resumen de Inventario',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
            children: [
              SummaryCardWidget(
                faIcon: FontAwesomeIcons.cow,
                title: 'Bovinos',
                total: state.totalBovinos,
                color: Colors.brown,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BovinoMenuScreen(farmId: widget.farmId),
                    ),
                  );
                },
              ),
              SummaryCardWidget(
                icon: Icons.pets,
                title: 'Porcinos',
                total: state.totalCerdos,
                color: Colors.pink,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PorciculturaMenuScreen(farmId: widget.farmId),
                    ),
                  );
                },
              ),
              SummaryCardWidget(
                icon: Icons.egg,
                title: 'Avicultura',
                total: state.totalGallinas,
                color: Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AviculturaMenuScreen(farmId: widget.farmId),
                    ),
                  );
                },
              ),
              SummaryCardWidget(
                icon: Icons.grass,
                title: 'Ovinos',
                total: state.totalOvejas,
                color: Colors.grey,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CaprinosMenuScreen(farmId: widget.farmId),
                    ),
                  );
                },
              ),
              SummaryCardWidget(
                icon: Icons.people,
                title: 'Trabajadores',
                total: state.totalTrabajadores,
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TrabajadoresMenuScreen(farmId: widget.farmId),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Accesos Rápidos
          Text(
            'Acciones Rápidas',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildQuickActions(context),
        ],
      ),
    );
  }

  Widget _buildAlertasSection(BuildContext context, List<DashboardAlert> alerts) {
    // Si no hay alertas, mostrar mensaje positivo
    if (alerts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade50, Colors.green.shade100],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.shade300, width: 2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade700,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Todo en orden en la finca',
                    style: TextStyle(
                      color: Colors.green.shade900,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'No hay alertas prioritarias',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Separar alertas por tipo
    final criticalAlerts = alerts.where((a) => a.type == AlertType.critical).toList();
    final warningAlerts = alerts.where((a) => a.type == AlertType.warning).toList();
    final infoAlerts = alerts.where((a) => a.type == AlertType.info).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de la sección
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.priority_high, color: Colors.red.shade700, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              'Alertas Prioritarias',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${alerts.length}',
                style: TextStyle(
                  color: Colors.red.shade900,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Lista de alertas críticas
        if (criticalAlerts.isNotEmpty) ...[
          ...criticalAlerts.map((alert) => _buildAlertCard(context, alert)),
          const SizedBox(height: 8),
        ],

        // Lista de alertas de advertencia
        if (warningAlerts.isNotEmpty) ...[
          ...warningAlerts.map((alert) => _buildAlertCard(context, alert)),
          const SizedBox(height: 8),
        ],

        // Lista de alertas informativas
        if (infoAlerts.isNotEmpty) ...[
          ...infoAlerts.map((alert) => _buildAlertCard(context, alert)),
        ],
      ],
    );
  }

  /// Construye una tarjeta individual de alerta
  Widget _buildAlertCard(BuildContext context, DashboardAlert alert) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: alert.type == AlertType.critical ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: alert.color.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: alert.route != null
            ? () {
                // Navegar a la ruta especificada si existe
                Navigator.pushNamed(
                  context,
                  alert.route!,
                  arguments: alert.routeArguments,
                );
              }
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icono de la alerta
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: alert.color.withOpacity(isDark ? 0.3 : 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  alert.icon,
                  color: alert.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Contenido de la alerta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Etiqueta del tipo + Título
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: alert.color.withOpacity(isDark ? 0.3 : 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            alert.typeLabel.toUpperCase(),
                            style: TextStyle(
                              color: alert.color,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      alert.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alert.message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                    ),
                  ],
                ),
              ),

              // Flecha de navegación (solo si tiene ruta)
              if (alert.route != null) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                  size: 24,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildQuickActionButton(
          context,
          icon: Icons.child_care,
          label: 'Nuevo Parto',
          onTap: () {
            // TODO: Navegar a formulario de parto
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Funcionalidad en desarrollo')),
            );
          },
        ),
        _buildQuickActionButton(
          context,
          icon: Icons.receipt,
          label: 'Registrar Gasto',
          onTap: () {
            // TODO: Navegar a formulario de gasto
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Funcionalidad en desarrollo')),
            );
          },
        ),
        _buildQuickActionButton(
          context,
          icon: Icons.medical_services,
          label: 'Vacunación',
          onTap: () {
            // TODO: Navegar a formulario de vacunación
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Funcionalidad en desarrollo')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark 
                ? Colors.grey.shade700 
                : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon, 
              size: 32, 
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}


