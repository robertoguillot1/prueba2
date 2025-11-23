import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../domain/entities/avicultura/gallina.dart';
import '../gallinas_viewmodel.dart';

/// Screen para listar gallinas
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GallinasViewModel>().loadGallinas(widget.farmId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallinas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Navegar a pantalla de crear gallina
            },
          ),
        ],
      ),
      body: Consumer<GallinasViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const LoadingWidget();
          }

          if (viewModel.hasError) {
            return ErrorDisplayWidget(
              message: viewModel.errorMessage ?? 'Error desconocido',
              onRetry: () {
                viewModel.clearError();
                viewModel.loadGallinas(widget.farmId);
              },
            );
          }

          if (viewModel.gallinas.isEmpty) {
            return EmptyStateWidget(
              message: 'No hay gallinas registradas',
              icon: Icons.pets_outlined,
              actionLabel: 'Agregar Gallina',
              onAction: () {
                // TODO: Navegar a pantalla de crear gallina
              },
            );
          }

          return ListView.builder(
            itemCount: viewModel.gallinas.length,
            itemBuilder: (context, index) {
              final gallina = viewModel.gallinas[index];
              return _GallinaCard(gallina: gallina);
            },
          );
        },
      ),
    );
  }
}

class _GallinaCard extends StatelessWidget {
  final Gallina gallina;

  const _GallinaCard({required this.gallina});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getEstadoColor(gallina.estado),
          child: Icon(
            gallina.gender == GallinaGender.female ? Icons.pets : Icons.pets_outlined,
            color: Colors.white,
          ),
        ),
        title: Text(gallina.name ?? gallina.identification ?? 'Sin nombre'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${gallina.gender == GallinaGender.female ? "Hembra" : "Macho"} - ${gallina.edadEnSemanas} semanas'),
            if (gallina.raza != null) Text('Raza: ${gallina.raza}'),
            Text('Estado: ${_getEstadoString(gallina.estado)}'),
            if (gallina.estaEnPicoProduccion)
              const Text(
                'En pico de producción',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            if (gallina.debeDescartarse)
              const Text(
                'Debe descartarse',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
          ],
        ),
        trailing: gallina.estaEnPicoProduccion
            ? const Icon(Icons.trending_up, color: Colors.green)
            : null,
        onTap: () {
          // TODO: Navegar a pantalla de detalles
        },
      ),
    );
  }

  Color _getEstadoColor(EstadoGallina estado) {
    switch (estado) {
      case EstadoGallina.activa:
        return Colors.green;
      case EstadoGallina.enferma:
        return Colors.red;
      case EstadoGallina.muerta:
        return Colors.grey;
      case EstadoGallina.descartada:
        return Colors.orange;
    }
  }

  String _getEstadoString(EstadoGallina estado) {
    switch (estado) {
      case EstadoGallina.activa:
        return 'Activa';
      case EstadoGallina.enferma:
        return 'Enferma';
      case EstadoGallina.muerta:
        return 'Muerta';
      case EstadoGallina.descartada:
        return 'Descartada';
    }
  }
}

