import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/debouncer.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../domain/entities/ovinos/oveja.dart';
import '../ovejas_viewmodel.dart';

/// Screen para listar ovejas
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
  final TextEditingController _searchController = TextEditingController();
  final _debouncer = Debouncer(delay: const Duration(milliseconds: 500));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OvejasViewModel>().loadOvejas(widget.farmId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ovejas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Navegar a pantalla de crear oveja
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar ovejas...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<OvejasViewModel>().loadOvejas(widget.farmId);
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                _debouncer.call(() {
                  if (value.isEmpty) {
                    context.read<OvejasViewModel>().loadOvejas(widget.farmId);
                  } else {
                    context.read<OvejasViewModel>().search(widget.farmId, value);
                  }
                });
              },
            ),
          ),
          // Lista de ovejas
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
                      viewModel.loadOvejas(widget.farmId);
                    },
                  );
                }

                if (viewModel.ovejas.isEmpty) {
                  return EmptyStateWidget(
                    message: 'No hay ovejas registradas',
                    icon: Icons.pets_outlined,
                    actionLabel: 'Agregar Oveja',
                    onAction: () {
                      // TODO: Navegar a pantalla de crear oveja
                    },
                  );
                }

                return ListView.builder(
                  itemCount: viewModel.ovejas.length,
                  itemBuilder: (context, index) {
                    final oveja = viewModel.ovejas[index];
                    return _OvejaCard(oveja: oveja);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OvejaCard extends StatelessWidget {
  final Oveja oveja;

  const _OvejaCard({required this.oveja});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: oveja.isNearParto ? Colors.orange : Colors.green,
          child: Icon(
            oveja.gender == OvejaGender.female ? Icons.pets : Icons.pets_outlined,
            color: Colors.white,
          ),
        ),
        title: Text(oveja.name ?? oveja.identification ?? 'Sin nombre'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${oveja.gender == OvejaGender.female ? "Hembra" : "Macho"} - ${oveja.ageInYears} años'),
            if (oveja.currentWeight != null)
              Text('Peso: ${oveja.currentWeight!.toStringAsFixed(1)} kg'),
            if (oveja.estadoReproductivo != null)
              Text('Estado: ${_getEstadoString(oveja.estadoReproductivo!)}'),
            if (oveja.isNearParto && oveja.diasRestantesParto != null)
              Text(
                'Parto en ${oveja.diasRestantesParto} días',
                style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
              ),
          ],
        ),
        trailing: oveja.isNearParto
            ? const Icon(Icons.warning, color: Colors.orange)
            : null,
        onTap: () {
          // TODO: Navegar a pantalla de detalles
        },
      ),
    );
  }

  String _getEstadoString(EstadoReproductivoOveja estado) {
    switch (estado) {
      case EstadoReproductivoOveja.vacia:
        return 'Vacía';
      case EstadoReproductivoOveja.gestante:
        return 'Gestante';
      case EstadoReproductivoOveja.lactante:
        return 'Lactante';
    }
  }
}

