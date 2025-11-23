import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../domain/entities/porcinos/cerdo.dart';
import '../cerdos_viewmodel.dart';

/// Screen para listar cerdos
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CerdosViewModel>().loadCerdos(widget.farmId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cerdos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Navegar a pantalla de crear cerdo
            },
          ),
        ],
      ),
      body: Consumer<CerdosViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const LoadingWidget();
          }

          if (viewModel.hasError) {
            return ErrorDisplayWidget(
              message: viewModel.errorMessage ?? 'Error desconocido',
              onRetry: () {
                viewModel.clearError();
                viewModel.loadCerdos(widget.farmId);
              },
            );
          }

          if (viewModel.cerdos.isEmpty) {
            return EmptyStateWidget(
              message: 'No hay cerdos registrados',
              icon: Icons.pets_outlined,
              actionLabel: 'Agregar Cerdo',
              onAction: () {
                // TODO: Navegar a pantalla de crear cerdo
              },
            );
          }

          return ListView.builder(
            itemCount: viewModel.cerdos.length,
            itemBuilder: (context, index) {
              final cerdo = viewModel.cerdos[index];
              return _CerdoCard(cerdo: cerdo);
            },
          );
        },
      ),
    );
  }
}

class _CerdoCard extends StatelessWidget {
  final Cerdo cerdo;

  const _CerdoCard({required this.cerdo});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStageColor(cerdo.feedingStage),
          child: Icon(
            cerdo.gender == CerdoGender.female ? Icons.pets : Icons.pets_outlined,
            color: Colors.white,
          ),
        ),
        title: Text(cerdo.identification ?? 'Sin identificación'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${cerdo.gender == CerdoGender.female ? "Hembra" : "Macho"} - ${cerdo.ageInDays} días'),
            Text('Peso: ${cerdo.currentWeight.toStringAsFixed(1)} kg'),
            Text('Etapa: ${_getStageString(cerdo.feedingStage)}'),
            Text('Consumo estimado: ${cerdo.estimatedDailyConsumption.toStringAsFixed(2)} kg/día'),
          ],
        ),
        onTap: () {
          // TODO: Navegar a pantalla de detalles
        },
      ),
    );
  }

  Color _getStageColor(FeedingStage stage) {
    switch (stage) {
      case FeedingStage.inicio:
        return Colors.blue;
      case FeedingStage.levante:
        return Colors.green;
      case FeedingStage.engorde:
        return Colors.orange;
    }
  }

  String _getStageString(FeedingStage stage) {
    switch (stage) {
      case FeedingStage.inicio:
        return 'Inicio';
      case FeedingStage.levante:
        return 'Levante';
      case FeedingStage.engorde:
        return 'Engorde';
    }
  }
}

