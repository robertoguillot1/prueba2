import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../presentation/widgets/search_bar.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/di/dependency_injection.dart';
import '../viewmodels/cerdos_viewmodel.dart';
import '../widgets/cerdo_tile.dart';
import '../create/cerdo_create_screen.dart';
import '../details/cerdo_details_screen.dart';

/// Pantalla de lista de Cerdos
class CerdosListScreen extends StatefulWidget {
  final String farmId;

  const CerdosListScreen({
    super.key,
    required this.farmId,
  });

  @override
  State<CerdosListScreen> createState() => _CerdosListScreenState();
}

class _CerdosListScreenState extends State<CerdosListScreen> {
  late CerdosViewModel _viewModel;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = DependencyInjection.createCerdosViewModel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadCerdos(widget.farmId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    await _viewModel.loadCerdos(widget.farmId);
  }

  Future<void> _navigateToCreate() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: _viewModel,
          child: CerdoCreateScreen(farmId: widget.farmId),
        ),
      ),
    );

    if (result == true) {
      _refreshData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cerdo creado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _navigateToDetails(cerdo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: _viewModel,
          child: CerdoDetailsScreen(cerdo: cerdo, farmId: widget.farmId),
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
          title: const Text('Cerdos'),
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
                hint: 'Buscar cerdos...',
                controller: _searchController,
                onSearch: (query) {
                  // TODO: Implementar búsqueda cuando esté disponible
                  _viewModel.loadCerdos(widget.farmId);
                },
                onClear: () {
                  _viewModel.loadCerdos(widget.farmId);
                },
              ),
            ),
            // Lista
            Expanded(
              child: Consumer<CerdosViewModel>(
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

                  if (viewModel.cerdos.isEmpty) {
                    return EmptyStateWidget(
                      message: 'No hay cerdos registrados',
                      icon: Icons.pets_outlined,
                      actionLabel: 'Agregar Cerdo',
                      onAction: _navigateToCreate,
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _refreshData,
                    child: ListView.separated(
                      itemCount: viewModel.cerdos.length,
                      padding: const EdgeInsets.only(bottom: 80),
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final cerdo = viewModel.cerdos[index];
                        return CerdoTile(
                          cerdo: cerdo,
                          onTap: () => _navigateToDetails(cerdo),
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
          label: const Text('Nuevo Cerdo'),
        ),
      ),
    );
  }
}

