import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/di/dependency_injection.dart' as di;
import '../../../../../features/cattle/domain/entities/bovine_entity.dart';
import '../../../../../features/cattle/domain/entities/reproductive_event_entity.dart';
import '../cubits/reproduction_cubit.dart';
import '../screens/reproductive_event_form_screen.dart';

/// Pestaña de Historial Reproductivo en el detalle del bovino
class ReproductionTab extends StatelessWidget {
  final BovineEntity bovine;
  final String farmId;

  const ReproductionTab({
    super.key,
    required this.bovine,
    required this.farmId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.DependencyInjection.createReproductionCubit()
        ..loadEvents(bovine.id, farmId),
      child: _ReproductionTabContent(
        bovine: bovine,
        farmId: farmId,
      ),
    );
  }
}

class _ReproductionTabContent extends StatelessWidget {
  final BovineEntity bovine;
  final String farmId;

  const _ReproductionTabContent({
    required this.bovine,
    required this.farmId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReproductionCubit, ReproductionState>(
      builder: (context, state) {
        if (state is ReproductionLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is ReproductionError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar eventos',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<ReproductionCubit>().refresh(bovine.id, farmId);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        if (state is ReproductionLoaded) {
          final events = state.events;

          if (events.isEmpty) {
            return _buildEmptyState(context);
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ReproductionCubit>().refresh(bovine.id, farmId);
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: events.length + 1, // +1 para el botón de agregar
              itemBuilder: (context, index) {
                // Botón de agregar al final
                if (index == events.length) {
                  return _buildAddButton(context);
                }

                final event = events[index];
                return ReproductionEventTile(
                  event: event,
                  onTap: () => _navigateToEventDetail(context, event),
                );
              },
            ),
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  /// Widget para estado vacío
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pregnant_woman,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 24),
            Text(
              'Sin registros reproductivos aún',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Comienza a registrar eventos como celos, inseminaciones, partos y más.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade500,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _navigateToCreateEvent(context),
              icon: const Icon(Icons.add),
              label: const Text('Registrar Primer Evento'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Botón de agregar al final de la lista
  Widget _buildAddButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: OutlinedButton.icon(
        onPressed: () => _navigateToCreateEvent(context),
        icon: const Icon(Icons.add),
        label: const Text('Registrar Nuevo Evento'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  /// Navegar al formulario de crear evento
  void _navigateToCreateEvent(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ReproductiveEventFormScreen(
          bovine: bovine,
          farmId: farmId,
        ),
      ),
    );

    if (result == true && context.mounted) {
      context.read<ReproductionCubit>().refresh(bovine.id, farmId);
    }
  }

  /// Navegar al detalle del evento (por ahora solo muestra info)
  void _navigateToEventDetail(BuildContext context, ReproductiveEventEntity event) {
    // Por ahora, solo mostramos un diálogo con la información
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.type.displayName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fecha: ${DateFormat('dd/MM/yyyy').format(event.eventDate)}'),
            const SizedBox(height: 8),
            if (event.notes != null && event.notes!.isNotEmpty) ...[
              const Text('Notas:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(event.notes!),
              const SizedBox(height: 8),
            ],
            if (event.details.isNotEmpty) ...[
              const Text('Detalles:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              ...event.details.entries.map(
                (e) => Text('• ${e.key}: ${e.value}'),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta individual para un evento reproductivo
class ReproductionEventTile extends StatelessWidget {
  final ReproductiveEventEntity event;
  final VoidCallback? onTap;

  const ReproductionEventTile({
    super.key,
    required this.event,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final color = _getColorForEventType(event.type);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icono del tipo de evento
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconForEventType(event.type),
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),

              // Información del evento
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tipo de evento
                    Text(
                      event.type.displayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),

                    // Fecha
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          dateFormat.format(event.eventDate),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey.shade700,
                              ),
                        ),
                      ],
                    ),

                    // Información adicional según el tipo
                    if (_getEventSummary(event).isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        _getEventSummary(event),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Flecha de navegación
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Obtiene el icono según el tipo de evento
  IconData _getIconForEventType(ReproductiveEventType type) {
    switch (type) {
      case ReproductiveEventType.heat:
        return Icons.favorite;
      case ReproductiveEventType.insemination:
        return Icons.pets;
      case ReproductiveEventType.palpation:
        return Icons.medical_services;
      case ReproductiveEventType.calving:
        return Icons.child_care;
      case ReproductiveEventType.abortion:
        return Icons.cancel;
      case ReproductiveEventType.drying:
        return Icons.water_drop;
    }
  }

  /// Obtiene el color según el tipo de evento
  Color _getColorForEventType(ReproductiveEventType type) {
    switch (type) {
      case ReproductiveEventType.heat:
        return Colors.pink;
      case ReproductiveEventType.insemination:
        return Colors.blue;
      case ReproductiveEventType.palpation:
        return Colors.teal;
      case ReproductiveEventType.calving:
        return Colors.green;
      case ReproductiveEventType.abortion:
        return Colors.red;
      case ReproductiveEventType.drying:
        return Colors.indigo;
    }
  }

  /// Obtiene un resumen del evento según su tipo
  String _getEventSummary(ReproductiveEventEntity event) {
    switch (event.type) {
      case ReproductiveEventType.palpation:
        final resultado = event.palpationResult;
        return resultado != null ? 'Resultado: $resultado' : '';
      case ReproductiveEventType.calving:
        final nacioCria = event.calfBorn;
        if (nacioCria == true) {
          return 'Cría nacida exitosamente';
        }
        return 'Sin cría';
      case ReproductiveEventType.insemination:
        final toro = event.fatherId;
        final pajilla = event.semenCode;
        if (toro != null) return 'Toro: $toro';
        if (pajilla != null) return 'Pajilla: $pajilla';
        return '';
      default:
        return event.notes ?? '';
    }
  }
}

