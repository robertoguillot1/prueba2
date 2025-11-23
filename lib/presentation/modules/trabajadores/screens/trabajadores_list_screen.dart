import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../domain/entities/trabajadores/trabajador.dart';
import '../trabajadores_viewmodel.dart';

/// Screen para listar trabajadores
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TrabajadoresViewModel>().loadTrabajadores(widget.farmId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trabajadores'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Navegar a pantalla de crear trabajador
            },
          ),
        ],
      ),
      body: Consumer<TrabajadoresViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const LoadingWidget();
          }

          if (viewModel.hasError) {
            return ErrorDisplayWidget(
              message: viewModel.errorMessage ?? 'Error desconocido',
              onRetry: () {
                viewModel.clearError();
                viewModel.loadTrabajadores(widget.farmId);
              },
            );
          }

          if (viewModel.trabajadores.isEmpty) {
            return EmptyStateWidget(
              message: 'No hay trabajadores registrados',
              icon: Icons.people_outline,
              actionLabel: 'Agregar Trabajador',
              onAction: () {
                // TODO: Navegar a pantalla de crear trabajador
              },
            );
          }

          return Column(
            children: [
              // Filtro de trabajadores activos
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
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
                ),
              ),
              // Lista de trabajadores
              Expanded(
                child: ListView.builder(
                  itemCount: viewModel.trabajadores.length,
                  itemBuilder: (context, index) {
                    final trabajador = viewModel.trabajadores[index];
                    return _TrabajadorCard(trabajador: trabajador);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TrabajadorCard extends StatelessWidget {
  final Trabajador trabajador;

  const _TrabajadorCard({required this.trabajador});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: trabajador.isActive ? Colors.green : Colors.grey,
          child: Icon(
            trabajador.isActive ? Icons.person : Icons.person_off,
            color: Colors.white,
          ),
        ),
        title: Text(trabajador.fullName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(trabajador.position),
            Text('Salario: \$${trabajador.salary.toStringAsFixed(2)}'),
          ],
        ),
        trailing: trabajador.isActive
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.cancel, color: Colors.grey),
        onTap: () {
          // TODO: Navegar a pantalla de detalles
        },
      ),
    );
  }
}

