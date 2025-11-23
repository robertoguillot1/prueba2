import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/dependency_injection.dart';
import '../cubits/dashboard_cubit.dart';
import '../cubits/dashboard_state.dart';
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
          actions: [
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
          _buildAlertasSection(context, state.alertas),
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
                icon: Icons.pets,
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
                icon: Icons.agriculture,
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
                icon: Icons.pets_outlined,
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

  Widget _buildAlertasSection(BuildContext context, List<String> alertas) {
    if (alertas.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade700, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Todo opera con normalidad',
                style: TextStyle(
                  color: Colors.green.shade900,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: Colors.orange.shade700, size: 28),
              const SizedBox(width: 8),
              Text(
                'Alertas',
                style: TextStyle(
                  color: Colors.orange.shade900,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...alertas.map((alerta) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        alerta,
                        style: TextStyle(
                          color: Colors.orange.shade900,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

