import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../presentation/widgets/search_bar.dart';
import '../../../../presentation/widgets/widgets.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../domain/entities/ovinos/oveja.dart';
import '../viewmodels/ovejas_viewmodel.dart';
import '../widgets/oveja_tile.dart';
import '../create/oveja_create_screen.dart';
import '../details/oveja_details_screen.dart';

/// Pantalla de lista de Ovejas
class OvejasListScreen extends StatefulWidget {
  final String farmId;

  const OvejasListScreen({
    super.key,
    required this.farmId,
  });

  @override
  State<OvejasListScreen> createState() => _OvejasListScreenState();
}

class _OvejasListScreenState extends State<OvejasListScreen> {
  late OvejasViewModel _viewModel;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = DependencyInjection.createOvejasViewModel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadOvejas(widget.farmId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    await _viewModel.loadOvejas(widget.farmId);
  }

  Future<void> _navigateToCreate() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: _viewModel,
          child: OvejaCreateScreen(farmId: widget.farmId),
        ),
      ),
    );

    if (result == true) {
      _refreshData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Oveja creada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _navigateToDetails(Oveja oveja) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: _viewModel,
          child: OvejaDetailsScreen(oveja: oveja, farmId: widget.farmId),
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
          title: const Text('Ovejas'),
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
                hint: 'Buscar ovejas...',
                controller: _searchController,
                onSearch: (query) {
                  if (query.isEmpty) {
                    _viewModel.loadOvejas(widget.farmId);
                  } else {
                    _viewModel.search(widget.farmId, query);
                  }
                },
                onClear: () {
                  _viewModel.loadOvejas(widget.farmId);
                },
              ),
            ),
            // Lista
            Expanded(
              child: Consumer<OvejasViewModel>(
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

                  if (viewModel.ovejas.isEmpty) {
                    return EmptyStateWidget(
                      message: 'No hay ovejas registradas',
                      icon: Icons.pets_outlined,
                      actionLabel: 'Agregar Oveja',
                      onAction: _navigateToCreate,
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _refreshData,
                    child: ListView.separated(
                      itemCount: viewModel.ovejas.length,
                      padding: const EdgeInsets.only(bottom: 80),
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final oveja = viewModel.ovejas[index];
                        return OvejaTile(
                          oveja: oveja,
                          onTap: () => _navigateToDetails(oveja),
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
          label: const Text('Nueva Oveja'),
        ),
      ),
    );
  }
}

