import 'package:flutter/material.dart';
import '../../../../domain/entities/avicultura/gallina.dart';
import '../../../../presentation/widgets/status_chip.dart';

/// Widget reutilizable para mostrar una gallina en una lista
class GallinaTile extends StatelessWidget {
  final Gallina gallina;
  final VoidCallback? onTap;

  const GallinaTile({
    super.key,
    required this.gallina,
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
                backgroundColor: _getEstadoColor(gallina.estado),
                child: Icon(
                  gallina.gender == GallinaGender.female ? Icons.pets : Icons.pets_outlined,
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
                            gallina.name ?? gallina.identification ?? 'Sin nombre',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        if (gallina.estaEnPicoProduccion)
                          const Icon(Icons.trending_up, color: Colors.green, size: 20),
                        if (gallina.debeDescartarse)
                          const Icon(Icons.warning, color: Colors.red, size: 20),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${gallina.identification ?? gallina.id}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        StatusChip(
                          label: gallina.gender == GallinaGender.female ? 'Hembra' : 'Macho',
                          color: Colors.purple,
                        ),
                        const SizedBox(width: 8),
                        StatusChip(
                          label: _getEstadoString(gallina.estado),
                          color: _getEstadoColor(gallina.estado),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Edad: ${gallina.edadEnSemanas} semanas',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (gallina.estaEnPicoProduccion)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green),
                        ),
                        child: const Text(
                          'En pico de producción',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    if (gallina.debeDescartarse)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red),
                        ),
                        child: const Text(
                          'Debe descartarse',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
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

