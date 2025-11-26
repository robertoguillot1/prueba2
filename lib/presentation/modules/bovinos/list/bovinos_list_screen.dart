import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../presentation/widgets/search_bar.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/di/dependency_injection.dart';
import '../viewmodels/bovinos_viewmodel.dart';
import '../widgets/bovino_tile.dart';
import '../create/bovino_create_screen.dart';
import '../screens/bovino_detail_screen.dart';
import '../mappers/bovino_mapper.dart';

/// Pantalla de lista de Bovinos
class BovinosListScreen extends StatefulWidget {
  final String farmId;

  const BovinosListScreen({
    super.key,
    required this.farmId,
  });

  @override
  State<BovinosListScreen> createState() => _BovinosListScreenState();
}

class _BovinosListScreenState extends State<BovinosListScreen> {
  late BovinosViewModel _viewModel;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = DependencyInjection.createBovinosViewModel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadBovinos(widget.farmId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    await _viewModel.loadBovinos(widget.farmId);
  }

  Future<void> _navigateToCreate() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: _viewModel,
          child: BovinoCreateScreen(farmId: widget.farmId),
        ),
      ),
    );

    if (result == true) {
      _refreshData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bovino creado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _navigateToDetails(bovino) {
    // Convertir el Bovino viejo a BovineEntity nuevo usando el mapper
    final bovineEntity = BovinoMapper.toEntity(bovino);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BovinoDetailScreen(
          bovine: bovineEntity,
          farmId: widget.farmId,
        ),
      ),
    ).then((result) {
      // Recargar la lista al volver por si se editó algo en el detalle
      if (result == true) {
        _refreshData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bovinos'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshData,
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
                  // TODO: Implementar búsqueda cuando esté disponible en ViewModel
                  _viewModel.loadBovinos(widget.farmId);
                },
                onClear: () {
                  _viewModel.loadBovinos(widget.farmId);
                },
              ),
            ),
            // Lista
            Expanded(
              child: Consumer<BovinosViewModel>(
                builder: (context, viewModel, child) {
                  if (viewModel.isLoading) {
                    return const LoadingWidget();
                  }

                  if (viewModel.hasError) {
                    return ErrorDisplayWidget(
                      message: viewModel.errorMessage ?? 'Error desconocido',
                      onRetry: () {
                        viewModel.clearError();
                        _refreshData();
                      },
                    );
                  }

                  if (viewModel.bovinos.isEmpty) {
                    return EmptyStateWidget(
                      message: 'No hay bovinos registrados',
                      icon: Icons.pets_outlined,
                      actionLabel: 'Agregar Bovino',
                      onAction: _navigateToCreate,
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _refreshData,
                    child: ListView.separated(
                      itemCount: viewModel.bovinos.length,
                      padding: const EdgeInsets.only(bottom: 80),
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final bovino = viewModel.bovinos[index];
                        return BovinoTile(
                          bovino: bovino,
                          onTap: () => _navigateToDetails(bovino),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _navigateToCreate,
          icon: const Icon(Icons.add),
          label: const Text('Nuevo Bovino'),
        ),
      ),
    );
  }
}

