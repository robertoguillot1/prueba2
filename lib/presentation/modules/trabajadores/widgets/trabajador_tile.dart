import 'package:flutter/material.dart';
import '../../../../domain/entities/trabajadores/trabajador.dart';
import '../../../../presentation/widgets/status_chip.dart';
import 'package:intl/intl.dart';

/// Widget reutilizable para mostrar un trabajador en una lista
class TrabajadorTile extends StatelessWidget {
  final Trabajador trabajador;
  final VoidCallback? onTap;

  const TrabajadorTile({
    super.key,
    required this.trabajador,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar con estado
              CircleAvatar(
                radius: 30,
                backgroundColor: trabajador.isActive ? Colors.green : Colors.grey,
                child: Icon(
                  trabajador.isActive ? Icons.person : Icons.person_off,
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
                            trabajador.fullName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        if (!trabajador.isActive)
                          const Icon(Icons.cancel, color: Colors.grey, size: 20),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${trabajador.identification}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        StatusChip(
                          label: trabajador.position,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        StatusChip(
                          label: trabajador.workerType == WorkerType.fijo ? 'Fijo' : 'Por Labor',
                          color: Colors.purple,
                        ),
                        const SizedBox(width: 8),
                        StatusChip(
                          label: trabajador.isActive ? 'Activo' : 'Inactivo',
                          color: trabajador.isActive ? Colors.green : Colors.grey,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Salario: ${currencyFormat.format(trabajador.salary)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      'Contratado: ${dateFormat.format(trabajador.startDate)}',
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
}

