import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/di/dependency_injection.dart' as di;
import '../../../../../core/di/dependency_injection.dart' show sl;
import '../../../../../features/cattle/domain/entities/vacuna_bovino_entity.dart';
import '../../../../../features/cattle/domain/entities/bovine_entity.dart';
import '../../../../../features/cattle/domain/usecases/get_cattle_list.dart';
import '../cubits/farm_health_cubit.dart';
import '../../details/cubits/health_state.dart';
import '../../details/forms/vaccine_form_screen.dart';
import '../../screens/bovino_detail_screen.dart';

/// Pantalla para ver todas las vacunas de una finca
class FarmHealthScreen extends StatelessWidget {
  final String farmId;

  const FarmHealthScreen({
    super.key,
    required this.farmId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.DependencyInjection.createFarmHealthCubit()
        ..loadVacunas(farmId: farmId),
      child: _FarmHealthScreenContent(farmId: farmId),
    );
  }
}

class _FarmHealthScreenContent extends StatelessWidget {
  final String farmId;

  const _FarmHealthScreenContent({required this.farmId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sanidad y Vacunación'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.vaccines),
        label: const Text('Registrar vacuna'),
        onPressed: () => _showVaccineSelector(context),
      ),
      body: BlocConsumer<FarmHealthCubit, HealthState>(
        listener: (context, state) {
          if (state is HealthOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            context.read<FarmHealthCubit>().refresh(farmId: farmId);
          } else if (state is HealthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is HealthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HealthError) {
            return _buildErrorState(context, state.message);
          }

          if (state is HealthLoaded) {
            return _buildLoadedState(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoadedState(BuildContext context, HealthLoaded state) {
    if (state.vacunas.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () => context.read<FarmHealthCubit>().refresh(farmId: farmId),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Alertas de refuerzos
          if (state.vacunasConRefuerzoAtrasado.isNotEmpty) ...[
            _buildAlertCard(
              context,
              'Refuerzos Atrasados',
              '${state.vacunasConRefuerzoAtrasado.length} vacuna(s) requieren refuerzo urgente',
              Colors.red,
              Icons.warning,
            ),
            const SizedBox(height: 12),
          ],
          if (state.vacunasConRefuerzoPendiente.isNotEmpty) ...[
            _buildAlertCard(
              context,
              'Refuerzos Próximos',
              '${state.vacunasConRefuerzoPendiente.length} vacuna(s) requieren refuerzo pronto',
              Colors.orange,
              Icons.schedule,
            ),
            const SizedBox(height: 12),
          ],

          // Título
          Text(
            'Historial de Vacunación (${state.vacunas.length})',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          // Lista de vacunas
          ...state.vacunas.map((vacuna) => _buildVaccineTile(context, vacuna)),
        ],
      ),
    );
  }

  Widget _buildAlertCard(
    BuildContext context,
    String title,
    String message,
    Color color,
    IconData icon,
  ) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    message,
                    // Usar opacidad para un tono más suave sin depender de MaterialColor
                    style: TextStyle(color: color.withOpacity(0.7)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVaccineTile(BuildContext context, VacunaBovinoEntity vacuna) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final bool hasRefuerzo = vacuna.proximaDosis != null;
    final bool refuerzoAtrasado = vacuna.refuerzoAtrasado;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: InkWell(
        onTap: () => _navigateToBovine(context, vacuna.bovinoId),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: refuerzoAtrasado
                      ? Colors.red.withOpacity(0.15)
                      : hasRefuerzo
                          ? Colors.orange.withOpacity(0.15)
                          : Colors.green.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.vaccines,
                  color: refuerzoAtrasado
                      ? Colors.red
                      : hasRefuerzo
                          ? Colors.orange
                          : Colors.green,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            vacuna.nombreVacuna,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => _navigateToBovine(context, vacuna.bovinoId),
                          child: const Text('Ver Bovino'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          'Aplicada: ${dateFormat.format(vacuna.fechaAplicacion)}',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                    if (vacuna.lote != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.inventory_2, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            'Lote: ${vacuna.lote}',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                    if (hasRefuerzo) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            refuerzoAtrasado ? Icons.warning : Icons.schedule,
                            size: 14,
                            color: refuerzoAtrasado ? Colors.red : Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Refuerzo: ${dateFormat.format(vacuna.proximaDosis!)}',
                            style: TextStyle(
                              color: refuerzoAtrasado ? Colors.red : Colors.orange,
                              fontWeight: refuerzoAtrasado ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.vaccines_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Sin registros de sanidad',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Aún no hay vacunas registradas en esta finca.\nRegistra vacunas desde el detalle de cada bovino.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            'Error al cargar vacunas',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.read<FarmHealthCubit>().refresh(farmId: farmId),
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  /// Selector de bovino y navegación directa al formulario de vacuna
  Future<void> _showVaccineSelector(BuildContext context) async {
    try {
      final getCattleList = sl<GetCattleList>();
      final result = await getCattleList(GetCattleListParams(farmId: farmId));

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
        },
        (bovines) async {
          final List<BovineEntity> list = bovines.map((b) => b as BovineEntity).toList();

          if (list.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No hay bovinos en la finca'),
                backgroundColor: Colors.orange,
              ),
            );
            return;
          }

          final selected = await showModalBottomSheet<BovineEntity>(
            context: context,
            builder: (_) => SafeArea(
              child: ListView(
                shrinkWrap: true,
                children: [
                  const ListTile(
                    title: Text('Selecciona un bovino'),
                    subtitle: Text('Elige al que quieres registrar la vacuna'),
                  ),
                  ...list.map(
                    (b) => ListTile(
                      leading: const Icon(Icons.pets),
                      title: Text(b.identifier),
                      subtitle: Text(b.name ?? ''),
                      onTap: () => Navigator.pop(context, b),
                    ),
                  ),
                ],
              ),
            ),
          );

          if (selected == null) return;

          final resultNav = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => VaccineFormScreen(
                bovine: selected,
                farmId: farmId,
              ),
            ),
          );

          if (resultNav == true && context.mounted) {
            context.read<FarmHealthCubit>().refresh(farmId: farmId);
          }
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al abrir selector: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToBovine(BuildContext context, String bovineId) async {
    try {
      final getCattleList = sl<GetCattleList>();
      final result = await getCattleList(GetCattleListParams(farmId: farmId));

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
        },
        (bovines) {
          final bovine = bovines.firstWhere(
            (b) => b.id == bovineId,
            orElse: () => bovines.first,
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BovinoDetailScreen(
                bovine: bovine,
                farmId: farmId,
              ),
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al navegar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}


