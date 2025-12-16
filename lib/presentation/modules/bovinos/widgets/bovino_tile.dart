import 'package:flutter/material.dart';
import '../../../../domain/entities/bovinos/bovino.dart';
import '../../../../presentation/widgets/status_chip.dart';

/// Widget reutilizable para mostrar un bovino en una lista
class BovinoTile extends StatelessWidget {
  final Bovino bovino;
  final VoidCallback? onTap;

  const BovinoTile({
    super.key,
    required this.bovino,
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
              // Avatar con estado
              CircleAvatar(
                radius: 30,
                backgroundColor: _getHealthColor(bovino.healthStatus),
                child: Icon(
                  bovino.gender == BovinoGender.female ? Icons.pets : Icons.pets_outlined,
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            bovino.name ?? bovino.identification ?? 'Sin nombre',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        if (bovino.needsSpecialCare)
                          const Icon(Icons.warning, color: Colors.orange, size: 20),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${bovino.identification ?? bovino.id}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        StatusChip(
                          label: _getCategoryString(bovino.category),
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        StatusChip(
                          label: bovino.gender == BovinoGender.female ? 'Hembra' : 'Macho',
                          color: Colors.purple,
                        ),
                        const SizedBox(width: 8),
                        StatusChip(
                          label: _getHealthString(bovino.healthStatus),
                          color: _getHealthColor(bovino.healthStatus),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Peso: ${bovino.currentWeight.toStringAsFixed(1)} kg | Edad: ${bovino.ageInYears} años',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (bovino.isVeryCloseToCalving && bovino.daysUntilCalving != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: Text(
                          'Parto en ${bovino.daysUntilCalving} días',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
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

  Color _getHealthColor(HealthStatus status) {
    switch (status) {
      case HealthStatus.sano:
        return Colors.green;
      case HealthStatus.enfermo:
        return Colors.red;
      case HealthStatus.tratamiento:
        return Colors.orange;
    }
  }

  String _getHealthString(HealthStatus status) {
    switch (status) {
      case HealthStatus.sano:
        return 'Sano';
      case HealthStatus.enfermo:
        return 'Enfermo';
      case HealthStatus.tratamiento:
        return 'Tratamiento';
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
}

