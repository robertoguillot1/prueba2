import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../presentation/widgets/search_bar.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/di/dependency_injection.dart' as di;
import '../../../../features/cattle/domain/entities/bovine_entity.dart';
import '../screens/bovino_form_screen.dart';
import '../screens/bovino_detail_screen.dart';
import 'cubits/bovine_list_cubit.dart';
import 'cubits/bovine_list_state.dart';

/// Pantalla de lista de Bovinos (migrada a Clean Architecture + Firestore)
class BovinosListScreen extends StatelessWidget {
  final String farmId;

  const BovinosListScreen({
    super.key,
    required this.farmId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.DependencyInjection.createBovineListCubit()
        ..loadBovines(farmId),
      child: _BovinosListContent(farmId: farmId),
    );
  }
}

class _BovinosListContent extends StatefulWidget {
  final String farmId;

  const _BovinosListContent({required this.farmId});

  @override
  State<_BovinosListContent> createState() => _BovinosListContentState();
}

class _BovinosListContentState extends State<_BovinosListContent> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshData(BuildContext context) async {
    context.read<BovineListCubit>().refresh(widget.farmId);
  }

  Future<void> _navigateToCreate(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BovinoFormScreen(
          farmId: widget.farmId,
        ),
      ),
    );

    if (result == true && context.mounted) {
      context.read<BovineListCubit>().refresh(widget.farmId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bovino creado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _navigateToDetails(BuildContext context, bovine) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BovinoDetailScreen(
          bovine: bovine,
          farmId: widget.farmId,
        ),
      ),
    );

    // Recargar la lista al volver por si se editó algo en el detalle
    if (result == true && context.mounted) {
      context.read<BovineListCubit>().refresh(widget.farmId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bovinos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshData(context),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomSearchBar(
              hint: 'Buscar bovinos...',
              controller: _searchController,
              onSearch: (query) {
                context.read<BovineListCubit>().search(query);
              },
              onClear: () {
                _searchController.clear();
                context.read<BovineListCubit>().clearSearch();
              },
            ),
          ),
          // Lista
          Expanded(
            child: BlocBuilder<BovineListCubit, BovineListState>(
              builder: (context, state) {
                if (state is BovineListLoading) {
                  return const LoadingWidget();
                }

                if (state is BovineListError) {
                  return ErrorDisplayWidget(
                    message: state.message,
                    onRetry: () => _refreshData(context),
                  );
                }

                if (state is BovineListLoaded) {
                  final bovines = state.filteredBovines;

                  if (bovines.isEmpty) {
                    return EmptyStateWidget(
                      message: state.searchQuery != null && state.searchQuery!.isNotEmpty
                          ? 'No se encontraron bovinos con "${state.searchQuery}"'
                          : 'No hay bovinos registrados',
                      icon: Icons.pets_outlined,
                      actionLabel: 'Agregar Bovino',
                      onAction: () => _navigateToCreate(context),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => _refreshData(context),
                    child: ListView.separated(
                      itemCount: bovines.length,
                      padding: const EdgeInsets.only(bottom: 80),
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final bovine = bovines[index];
                        return _buildBovineCard(context, bovine);
                      },
                    ),
                  );
                }

                return const Center(child: Text('Estado desconocido'));
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreate(context),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Bovino'),
        heroTag: 'add_bovine_fab',
      ),
    );
  }

  Widget _buildBovineCard(BuildContext context, bovine) {
    final theme = Theme.of(context);
    
    // Colores según el género
    final genderColor = bovine.gender == BovineGender.female 
        ? Colors.pink 
        : Colors.blue;
    
    // Color según el estado
    final statusColor = bovine.status == BovineStatus.active
        ? Colors.green
        : (bovine.status == BovineStatus.sold ? Colors.orange : Colors.red);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListTile(
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: genderColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.pets,
            color: genderColor,
            size: 28,
          ),
        ),
        title: Text(
          bovine.identifier,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (bovine.name != null) ...[
              const SizedBox(height: 4),
              Text(bovine.name!),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Chip(
                  label: Text(
                    bovine.breed,
                    style: const TextStyle(fontSize: 11),
                  ),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(
                    '${bovine.age} ${bovine.age == 1 ? 'año' : 'años'}',
                    style: const TextStyle(fontSize: 11),
                  ),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ],
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: theme.colorScheme.primary,
        ),
        onTap: () => _navigateToDetails(context, bovine),
      ),
    );
  }
}

