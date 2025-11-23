import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/cerdos_viewmodel.dart';
import '../edit/cerdo_edit_screen.dart';
import '../../../../domain/entities/porcinos/cerdo.dart';
import '../../../../presentation/widgets/info_card.dart';
import '../../../../presentation/widgets/status_chip.dart';
import '../../../../presentation/widgets/custom_button.dart';

/// Pantalla de detalles de un Cerdo
class CerdoDetailsScreen extends StatelessWidget {
  final Cerdo cerdo;
  final String farmId;

  const CerdoDetailsScreen({
    super.key,
    required this.cerdo,
    required this.farmId,
  });

  Future<bool> _confirmDelete(BuildContext context, CerdosViewModel viewModel) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text('¿Estás seguro de eliminar este cerdo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    return confirmed ?? false;
  }

  Future<void> _handleDelete(BuildContext context, CerdosViewModel viewModel) async {
    final confirmed = await _confirmDelete(context, viewModel);
    if (!confirmed) return;

    final success = await viewModel.deleteCerdoEntity(cerdo.id, farmId);

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cerdo eliminado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Error al eliminar cerdo'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<CerdosViewModel>(),
          child: CerdoEditScreen(cerdo: cerdo, farmId: farmId),
        ),
      ),
    ).then((result) {
      if (result == true && context.mounted) {
        Navigator.pop(context, true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(cerdo.identification ?? 'Cerdo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEdit(context),
            tooltip: 'Editar',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _handleDelete(
              context,
              context.read<CerdosViewModel>(),
            ),
            tooltip: 'Eliminar',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar y nombre
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: _getStageColor(cerdo.feedingStage),
                    child: Icon(
                      cerdo.gender == CerdoGender.female ? Icons.pets : Icons.pets_outlined,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    cerdo.identification ?? 'ID: ${cerdo.id.substring(0, 8)}...',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      StatusChip(
                        label: cerdo.gender == CerdoGender.female ? 'Hembra' : 'Macho',
                        color: Colors.purple,
                      ),
                      StatusChip(
                        label: _getStageString(cerdo.feedingStage),
                        color: _getStageColor(cerdo.feedingStage),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Información básica
            Text(
              'Información Básica',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (cerdo.identification != null)
              InfoCard(
                label: 'Identificación',
                value: cerdo.identification!,
                icon: Icons.tag,
              ),
            if (cerdo.identification != null) const SizedBox(height: 8),
            InfoCard(
              label: 'Fecha de Nacimiento',
              value: dateFormat.format(cerdo.birthDate),
              icon: Icons.calendar_today,
            ),
            const SizedBox(height: 8),
            InfoCard(
              label: 'Edad',
              value: '${cerdo.ageInDays} días',
              icon: Icons.cake,
            ),
            const SizedBox(height: 8),
            InfoCard(
              label: 'Peso Actual',
              value: '${cerdo.currentWeight.toStringAsFixed(1)} kg',
              icon: Icons.monitor_weight,
            ),
            const SizedBox(height: 8),
            InfoCard(
              label: 'Etapa de Alimentación',
              value: _getStageString(cerdo.feedingStage),
              icon: Icons.restaurant,
            ),
            const SizedBox(height: 8),
            InfoCard(
              label: 'Consumo Estimado Diario',
              value: '${cerdo.estimatedDailyConsumption.toStringAsFixed(2)} kg/día',
              icon: Icons.local_dining,
            ),
            // Notas
            if (cerdo.notes != null && cerdo.notes!.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Notas',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(cerdo.notes!),
              ),
            ],
            const SizedBox(height: 32),
            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    label: 'Editar',
                    icon: Icons.edit,
                    onPressed: () => _navigateToEdit(context),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    label: 'Eliminar',
                    icon: Icons.delete,
                    onPressed: () => _handleDelete(
                      context,
                      context.read<CerdosViewModel>(),
                    ),
                    backgroundColor: Colors.red,
                    isOutlined: true,
                  ),
                ),
              ],
            ),
          ],
        ),
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

