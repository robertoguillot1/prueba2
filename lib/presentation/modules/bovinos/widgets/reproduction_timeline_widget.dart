import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../domain/entities/bovinos/evento_reproductivo.dart';

/// Widget para mostrar la línea de tiempo de eventos reproductivos
class ReproductionTimelineWidget extends StatelessWidget {
  final List<EventoReproductivo> eventos;
  final Function(EventoReproductivo)? onEventTap;

  const ReproductionTimelineWidget({
    super.key,
    required this.eventos,
    this.onEventTap,
  });

  @override
  Widget build(BuildContext context) {
    if (eventos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.timeline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay eventos registrados',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Toca el botón + para agregar un evento',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    final dateFormat = DateFormat('dd/MM/yyyy');
    final sortedEventos = List<EventoReproductivo>.from(eventos)
      ..sort((a, b) => b.fecha.compareTo(a.fecha));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedEventos.length,
      itemBuilder: (context, index) {
        final evento = sortedEventos[index];
        final isLast = index == sortedEventos.length - 1;

        return _TimelineItem(
          evento: evento,
          dateFormat: dateFormat,
          isLast: isLast,
          onTap: onEventTap != null ? () => onEventTap!(evento) : null,
        );
      },
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final EventoReproductivo evento;
  final DateFormat dateFormat;
  final bool isLast;
  final VoidCallback? onTap;

  const _TimelineItem({
    required this.evento,
    required this.dateFormat,
    required this.isLast,
    this.onTap,
  });

  Color _getEventColor() {
    switch (evento.tipo) {
      case TipoEventoReproductivo.celo:
        return Colors.pink;
      case TipoEventoReproductivo.montaInseminacion:
        return Colors.blue;
      case TipoEventoReproductivo.palpacionTacto:
        return Colors.orange;
      case TipoEventoReproductivo.parto:
        return Colors.green;
      case TipoEventoReproductivo.aborto:
        return Colors.red;
      case TipoEventoReproductivo.secado:
        return Colors.grey;
    }
  }

  IconData _getEventIcon() {
    switch (evento.tipo) {
      case TipoEventoReproductivo.celo:
        return Icons.favorite;
      case TipoEventoReproductivo.montaInseminacion:
        return Icons.pets;
      case TipoEventoReproductivo.palpacionTacto:
        return Icons.medical_services;
      case TipoEventoReproductivo.parto:
        return Icons.child_care;
      case TipoEventoReproductivo.aborto:
        return Icons.cancel;
      case TipoEventoReproductivo.secado:
        return Icons.water_drop;
    }
  }

  String _getEventDetails() {
    final details = <String>[];
    
    switch (evento.tipo) {
      case TipoEventoReproductivo.montaInseminacion:
        if (evento.idToro != null) {
          details.add('Toro: ${evento.detalles['nombreToro'] ?? evento.idToro}');
        }
        if (evento.codigoPajilla != null) {
          details.add('Pajilla: ${evento.codigoPajilla}');
        }
        break;
      case TipoEventoReproductivo.palpacionTacto:
        if (evento.resultadoPalpacion != null) {
          details.add('Resultado: ${evento.resultadoPalpacion}');
        }
        break;
      case TipoEventoReproductivo.parto:
        if (evento.nacioCria == true) {
          details.add('Nació cría');
          if (evento.idCriaCreada != null) {
            details.add('ID Cría: ${evento.idCriaCreada}');
          }
        } else {
          details.add('Sin cría');
        }
        break;
      default:
        break;
    }

    return details.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    final color = _getEventColor();
    final icon = _getEventIcon();
    final details = _getEventDetails();

    return InkWell(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Línea vertical y punto
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: Icon(icon, size: 14, color: Colors.white),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 80,
                  color: Colors.grey.shade300,
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Contenido del evento
          Expanded(
            child: Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            evento.tipo.displayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            dateFormat.format(evento.fecha),
                            style: TextStyle(
                              color: color,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (details.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        details,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                    if (evento.notas != null && evento.notas!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        evento.notas!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

