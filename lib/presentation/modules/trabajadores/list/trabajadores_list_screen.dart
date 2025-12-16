import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../presentation/widgets/search_bar.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/di/dependency_injection.dart';
import '../viewmodels/trabajadores_viewmodel.dart';
import '../widgets/trabajador_tile.dart';
import '../create/trabajador_create_screen.dart';
import '../details/trabajador_details_screen.dart';

/// Pantalla de lista de Trabajadores
class TrabajadoresListScreen extends StatefulWidget {
  final String farmId;

  const TrabajadoresListScreen({
    super.key,
    required this.farmId,
  });

  @override
  State<TrabajadoresListScreen> createState() => _TrabajadoresListScreenState();
}

class _TrabajadoresListScreenState extends State<TrabajadoresListScreen> {
  late TrabajadoresViewModel _viewModel;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = DependencyInjection.createTrabajadoresViewModel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadTrabajadores(widget.farmId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    await _viewModel.loadTrabajadores(widget.farmId);
  }

  Future<void> _navigateToCreate() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: _viewModel,
          child: TrabajadorCreateScreen(farmId: widget.farmId),
        ),
      ),
    );

    if (result == true) {
      _refreshData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Trabajador creado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _navigateToDetails(trabajador) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: _viewModel,
          child: TrabajadorDetailsScreen(trabajador: trabajador, farmId: widget.farmId),
        ),
      ),
    ).then((result) {
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
          title: const Text('Trabajadores'),
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
            // Barra de búsqueda y filtro
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CustomSearchBar(
                    hint: 'Buscar trabajadores...',
                    controller: _searchController,
                    onSearch: (query) {
                      if (query.trim().isEmpty) {
                        _viewModel.loadTrabajadores(widget.farmId);
                      } else {
                        _viewModel.searchTrabajadoresByQuery(widget.farmId, query);
                      }
                    },
                    onClear: () {
                      _viewModel.loadTrabajadores(widget.farmId);
                    },
                  ),
                  const SizedBox(height: 8),
                  Consumer<TrabajadoresViewModel>(
                    builder: (context, viewModel, child) {
                      return Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Mostrar solo activos',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                          Switch(
                            value: viewModel.showOnlyActivos,
                            onChanged: (_) => viewModel.toggleShowOnlyActivos(),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            // Lista
            Expanded(
              child: Consumer<TrabajadoresViewModel>(
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

                  if (viewModel.trabajadores.isEmpty) {
                    return EmptyStateWidget(
                      message: 'No hay trabajadores registrados',
                      icon: Icons.people_outline,
                      actionLabel: 'Agregar Trabajador',
                      onAction: _navigateToCreate,
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _refreshData,
                    child: ListView.separated(
                      itemCount: viewModel.trabajadores.length,
                      padding: const EdgeInsets.only(bottom: 80),
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final trabajador = viewModel.trabajadores[index];
                        return TrabajadorTile(
                          trabajador: trabajador,
                          onTap: () => _navigateToDetails(trabajador),
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
          label: const Text('Nuevo Trabajador'),
        ),
      ),
    );
  }
}

