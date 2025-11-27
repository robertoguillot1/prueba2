import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../../domain/entities/bovinos/evento_reproductivo.dart';
import '../../../../../domain/usecases/bovinos/get_eventos_reproductivos_by_bovino.dart';

// ============================================
// ESTADOS
// ============================================

/// Estados del historial reproductivo
abstract class ReproductionState extends Equatable {
  const ReproductionState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class ReproductionInitial extends ReproductionState {}

/// Estado de carga
class ReproductionLoading extends ReproductionState {}

/// Estado con datos cargados
class ReproductionLoaded extends ReproductionState {
  final List<EventoReproductivo> events;

  const ReproductionLoaded(this.events);

  @override
  List<Object?> get props => [events];
}

/// Estado de error
class ReproductionError extends ReproductionState {
  final String message;

  const ReproductionError(this.message);

  @override
  List<Object?> get props => [message];
}

// ============================================
// CUBIT
// ============================================

/// Cubit para gestionar el historial reproductivo de un bovino
class ReproductionCubit extends Cubit<ReproductionState> {
  final GetEventosReproductivosByBovino _getEventos;
  StreamSubscription<List<EventoReproductivo>>? _eventsSubscription;

  ReproductionCubit({
    required GetEventosReproductivosByBovino getEventos,
  })  : _getEventos = getEventos,
        super(ReproductionInitial());

  /// Carga todos los eventos reproductivos de un bovino
  void loadEvents(String bovineId) {
    _eventsSubscription?.cancel(); // Cancelar suscripción previa
    emit(ReproductionLoading());

    try {
      // Suscribirse al Stream de eventos reproductivos
      _eventsSubscription = _getEventos(bovineId).listen(
        (eventos) {
          try {
            // Ordenar eventos por fecha (más reciente primero)
            final sortedEvents = List<EventoReproductivo>.from(eventos);
            sortedEvents.sort((a, b) => b.fecha.compareTo(a.fecha));

            emit(ReproductionLoaded(sortedEvents));
          } catch (e) {
            emit(ReproductionError('Error al procesar eventos: ${e.toString()}'));
          }
        },
        onError: (error) {
          emit(ReproductionError('Error al cargar eventos: ${error.toString()}'));
        },
      );
    } catch (e) {
      emit(ReproductionError('Error al cargar eventos: ${e.toString()}'));
    }
  }

  /// Recarga los eventos (útil después de agregar/editar)
  void refresh(String bovineId) {
    loadEvents(bovineId);
  }

  @override
  Future<void> close() {
    _eventsSubscription?.cancel();
    return super.close();
  }
}




