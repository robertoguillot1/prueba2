import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../presentation/widgets/search_bar.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/di/dependency_injection.dart';
import '../viewmodels/gallinas_viewmodel.dart';
import '../widgets/gallina_tile.dart';
import '../create/gallina_create_screen.dart';
import '../details/gallina_details_screen.dart';

/// Pantalla de lista de Gallinas
class GallinasListScreen extends StatefulWidget {
  final String farmId;

  const GallinasListScreen({
    super.key,
    required this.farmId,
  });

  @override
  State<GallinasListScreen> createState() => _GallinasListScreenState();
}

class _GallinasListScreenState extends State<GallinasListScreen> {
  late GallinasViewModel _viewModel;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = DependencyInjection.createGallinasViewModel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadGallinas(widget.farmId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    await _viewModel.loadGallinas(widget.farmId);
  }

  Future<void> _navigateToCreate() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: _viewModel,
          child: GallinaCreateScreen(farmId: widget.farmId),
        ),
      ),
    );

    if (result == true) {
      _refreshData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gallina creada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _navigateToDetails(gallina) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: _viewModel,
          child: GallinaDetailsScreen(gallina: gallina, farmId: widget.farmId),
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
          title: const Text('Gallinas'),
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
                hint: 'Buscar gallinas...',
                controller: _searchController,
                onSearch: (query) {
                  // TODO: Implementar búsqueda cuando esté disponible
                  _viewModel.loadGallinas(widget.farmId);
                },
                onClear: () {
                  _viewModel.loadGallinas(widget.farmId);
                },
              ),
            ),
            // Lista
            Expanded(
              child: Consumer<GallinasViewModel>(
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

                  if (viewModel.gallinas.isEmpty) {
                    return EmptyStateWidget(
                      message: 'No hay gallinas registradas',
                      icon: Icons.pets_outlined,
                      actionLabel: 'Agregar Gallina',
                      onAction: _navigateToCreate,
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _refreshData,
                    child: ListView.separated(
                      itemCount: viewModel.gallinas.length,
                      padding: const EdgeInsets.only(bottom: 80),
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final gallina = viewModel.gallinas[index];
                        return GallinaTile(
                          gallina: gallina,
                          onTap: () => _navigateToDetails(gallina),
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
          label: const Text('Nueva Gallina'),
        ),
      ),
    );
  }
}

