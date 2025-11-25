import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/di/dependency_injection.dart' as di;
import '../../domain/entities/bovine_entity.dart';
import '../cubit/cattle_cubit.dart';
import '../cubit/cattle_state.dart';

/// Pantalla principal para listar bovinos de una finca
class CattleListScreen extends StatelessWidget {
  final String farmId;

  const CattleListScreen({
    super.key,
    required this.farmId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.DependencyInjection.createCattleCubit()..loadCattle(farmId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ganado Bovino'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {
                // TODO: Implementar filtros
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Filtros próximamente')),
                );
              },
              tooltip: 'Filtrar',
            ),
          ],
        ),
        body: BlocConsumer<CattleCubit, CattleState>(
          listener: (context, state) {
            if (state is CattleOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
              // Recargar la lista después de una operación exitosa
              context.read<CattleCubit>().loadCattle(farmId);
            }
          },
          builder: (context, state) {
            if (state is CattleLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is CattleError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 80,
                      color: Colors.red.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        state.message,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<CattleCubit>().loadCattle(farmId);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (state is CattleLoaded) {
              if (state.cattle.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FaIcon(
                        FontAwesomeIcons.cow,
                        size: 100,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No hay bovinos registrados',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Comienza agregando tu primer animal',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade500,
                            ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () {
                          _navigateToCreateBovine(context);
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Agregar Bovino'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<CattleCubit>().loadCattle(farmId);
                },
                child: ListView.builder(
                  itemCount: state.cattle.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final bovine = state.cattle[index];
                    return _BovineCard(
                      bovine: bovine,
                      onTap: () => _navigateToBovineDetail(context, bovine),
                    );
                  },
                ),
              );
            }

            // Estado inicial
            return const Center(
              child: Text('Cargando...'),
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _navigateToCreateBovine(context),
          icon: const Icon(Icons.add),
          label: const Text('Nuevo Bovino'),
          tooltip: 'Agregar nuevo bovino',
        ),
      ),
    );
  }

  void _navigateToCreateBovine(BuildContext context) {
    // TODO: Navegar a la pantalla de crear bovino
    debugPrint('Ir a crear vaca');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Formulario de creación próximamente'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _navigateToBovineDetail(BuildContext context, BovineEntity bovine) {
    // TODO: Navegar a la pantalla de detalles
    debugPrint('Navegar a detalle de: ${bovine.identifier}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ver detalles de ${bovine.identifier}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

/// Widget de tarjeta individual para cada bovino
class _BovineCard extends StatelessWidget {
  final BovineEntity bovine;
  final VoidCallback? onTap;

  const _BovineCard({
    required this.bovine,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar con indicador de género
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _getGenderColor(bovine.gender).withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _getGenderColor(bovine.gender),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    _getGenderIcon(bovine.gender),
                    color: _getGenderColor(bovine.gender),
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Información del bovino
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Identificador / Nombre
                    Text(
                      bovine.name ?? bovine.identifier,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Raza
                    Row(
                      children: [
                        Icon(
                          Icons.pets,
                          size: 14,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            bovine.breed,
                            style: theme.textTheme.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Edad y peso
                    Row(
                      children: [
                        Icon(
                          Icons.cake,
                          size: 14,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${bovine.age} ${bovine.age == 1 ? 'año' : 'años'}',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.monitor_weight,
                          size: 14,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${bovine.weight.toStringAsFixed(1)} kg',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Indicadores de propósito y estado
              Column(
                children: [
                  // Chip de propósito
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getPurposeColor(bovine.purpose).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getPurposeLabel(bovine.purpose),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: _getPurposeColor(bovine.purpose),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Icono de estado
                  Icon(
                    _getStatusIcon(bovine.status),
                    color: _getStatusColor(bovine.status),
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helpers para colores e iconos
  IconData _getGenderIcon(BovineGender gender) {
    switch (gender) {
      case BovineGender.male:
        return Icons.male;
      case BovineGender.female:
        return Icons.female;
    }
  }

  Color _getGenderColor(BovineGender gender) {
    switch (gender) {
      case BovineGender.male:
        return Colors.blue;
      case BovineGender.female:
        return Colors.pink;
    }
  }

  String _getPurposeLabel(BovinePurpose purpose) {
    switch (purpose) {
      case BovinePurpose.meat:
        return 'Carne';
      case BovinePurpose.milk:
        return 'Leche';
      case BovinePurpose.dual:
        return 'Dual';
    }
  }

  Color _getPurposeColor(BovinePurpose purpose) {
    switch (purpose) {
      case BovinePurpose.meat:
        return Colors.red;
      case BovinePurpose.milk:
        return Colors.blue;
      case BovinePurpose.dual:
        return Colors.purple;
    }
  }

  IconData _getStatusIcon(BovineStatus status) {
    switch (status) {
      case BovineStatus.active:
        return Icons.check_circle;
      case BovineStatus.sold:
        return Icons.sell;
      case BovineStatus.dead:
        return Icons.dangerous;
    }
  }

  Color _getStatusColor(BovineStatus status) {
    switch (status) {
      case BovineStatus.active:
        return Colors.green;
      case BovineStatus.sold:
        return Colors.orange;
      case BovineStatus.dead:
        return Colors.red;
    }
  }
}

