import 'package:flutter/material.dart';
import '../../../../domain/entities/porcinos/cerdo.dart';
import '../../../../presentation/widgets/status_chip.dart';

/// Widget reutilizable para mostrar un cerdo en una lista
class CerdoTile extends StatelessWidget {
  final Cerdo cerdo;
  final VoidCallback? onTap;

  const CerdoTile({
    super.key,
    required this.cerdo,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar con etapa
              CircleAvatar(
                radius: 30,
                backgroundColor: _getStageColor(cerdo.feedingStage),
                child: Icon(
                  cerdo.gender == CerdoGender.female ? Icons.pets : Icons.pets_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              // Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cerdo.identification ?? 'ID: ${cerdo.id.substring(0, 8)}...',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        StatusChip(
                          label: cerdo.gender == CerdoGender.female ? 'Hembra' : 'Macho',
                          color: Colors.purple,
                        ),
                        const SizedBox(width: 8),
                        StatusChip(
                          label: _getStageString(cerdo.feedingStage),
                          color: _getStageColor(cerdo.feedingStage),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Peso: ${cerdo.currentWeight.toStringAsFixed(1)} kg',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      'Edad: ${cerdo.ageInDays} días | Consumo: ${cerdo.estimatedDailyConsumption.toStringAsFixed(2)} kg/día',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              // Icono de navegación
              const Icon(Icons.chevron_right),
            ],
          ),
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

