import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../domain/entities/bovinos/bovino.dart';
import '../bovinos_viewmodel.dart';

/// Screen para listar bovinos
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BovinosViewModel>().loadBovinos(widget.farmId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bovinos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Navegar a pantalla de crear bovino
            },
          ),
        ],
      ),
      body: Consumer<BovinosViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const LoadingWidget();
          }

          if (viewModel.hasError) {
            return ErrorDisplayWidget(
              message: viewModel.errorMessage ?? 'Error desconocido',
              onRetry: () {
                viewModel.clearError();
                viewModel.loadBovinos(widget.farmId);
              },
            );
          }

          if (viewModel.bovinos.isEmpty) {
            return EmptyStateWidget(
              message: 'No hay bovinos registrados',
              icon: Icons.pets_outlined,
              actionLabel: 'Agregar Bovino',
              onAction: () {
                // TODO: Navegar a pantalla de crear bovino
              },
            );
          }

          return ListView.builder(
            itemCount: viewModel.bovinos.length,
            itemBuilder: (context, index) {
              final bovino = viewModel.bovinos[index];
              return _BovinoCard(bovino: bovino);
            },
          );
        },
      ),
    );
  }
}

class _BovinoCard extends StatelessWidget {
  final Bovino bovino;

  const _BovinoCard({required this.bovino});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(bovino.healthStatus),
          child: Icon(
            bovino.gender == BovinoGender.female ? Icons.pets : Icons.pets_outlined,
            color: Colors.white,
          ),
        ),
        title: Text(bovino.name ?? bovino.identification ?? 'Sin nombre'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${_getCategoryString(bovino.category)} - ${_getGenderString(bovino.gender)}'),
            Text('Peso: ${bovino.currentWeight.toStringAsFixed(1)} kg'),
            Text('Estado: ${_getHealthStatusString(bovino.healthStatus)}'),
          ],
        ),
        trailing: bovino.needsSpecialCare
            ? const Icon(Icons.warning, color: Colors.orange)
            : null,
        onTap: () {
          // TODO: Navegar a pantalla de detalles
        },
      ),
    );
  }

  Color _getStatusColor(HealthStatus status) {
    switch (status) {
      case HealthStatus.sano:
        return Colors.green;
      case HealthStatus.enfermo:
        return Colors.red;
      case HealthStatus.tratamiento:
        return Colors.orange;
    }
  }

  String _getCategoryString(BovinoCategory category) {
    switch (category) {
      case BovinoCategory.vaca:
        return 'Vaca';
      case BovinoCategory.toro:
        return 'Toro';
      case BovinoCategory.ternero:
        return 'Ternero';
      case BovinoCategory.novilla:
        return 'Novilla';
    }
  }

  String _getGenderString(BovinoGender gender) {
    switch (gender) {
      case BovinoGender.male:
        return 'Macho';
      case BovinoGender.female:
        return 'Hembra';
    }
  }

  String _getHealthStatusString(HealthStatus status) {
    switch (status) {
      case HealthStatus.sano:
        return 'Sano';
      case HealthStatus.enfermo:
        return 'Enfermo';
      case HealthStatus.tratamiento:
        return 'En Tratamiento';
    }
  }
}

