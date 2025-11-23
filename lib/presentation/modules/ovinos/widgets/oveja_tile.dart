import 'package:flutter/material.dart';
import '../../../../domain/entities/ovinos/oveja.dart';
import '../../../../presentation/widgets/status_chip.dart';

/// Widget reutilizable para mostrar una oveja en una lista
class OvejaTile extends StatelessWidget {
  final Oveja oveja;
  final VoidCallback? onTap;

  const OvejaTile({
    super.key,
    required this.oveja,
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
                backgroundColor: _getStatusColor(oveja.estadoReproductivo),
                child: Icon(
                  oveja.gender == OvejaGender.female ? Icons.pets : Icons.pets_outlined,
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
                      oveja.name ?? oveja.identification ?? 'Sin nombre',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${oveja.identification ?? oveja.id}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        StatusChip(
                          label: oveja.gender == OvejaGender.female ? 'Hembra' : 'Macho',
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        if (oveja.estadoReproductivo != null)
                          StatusChip(
                            label: _getEstadoString(oveja.estadoReproductivo!),
                            color: _getStatusColor(oveja.estadoReproductivo),
                          ),
                      ],
                    ),
                    if (oveja.currentWeight != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Peso: ${oveja.currentWeight!.toStringAsFixed(1)} kg',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    if (oveja.isNearParto && oveja.diasRestantesParto != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: Text(
                          'Parto en ${oveja.diasRestantesParto} días',
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

  Color _getStatusColor(EstadoReproductivoOveja? estado) {
    if (estado == null) return Colors.grey;
    switch (estado) {
      case EstadoReproductivoOveja.vacia:
        return Colors.green;
      case EstadoReproductivoOveja.gestante:
        return Colors.orange;
      case EstadoReproductivoOveja.lactante:
        return Colors.blue;
    }
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

