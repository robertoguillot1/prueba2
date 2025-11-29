import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import '../../../../../features/cattle/domain/entities/reproductive_event_entity.dart';
import '../../../../../features/cattle/domain/usecases/get_reproductive_events_by_bovine.dart';
import '../../../../../core/errors/failures.dart';

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
  final List<ReproductiveEventEntity> events;

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
  final GetReproductiveEventsByBovine _getEvents;

  ReproductionCubit({
    required GetReproductiveEventsByBovine getEvents,
  })  : _getEvents = getEvents,
        super(ReproductionInitial());

  /// Carga todos los eventos reproductivos de un bovino
  Future<void> loadEvents(String bovineId, String farmId) async {
    emit(ReproductionLoading());

    final result = await _getEvents(
      GetReproductiveEventsByBovineParams(
        bovineId: bovineId,
        farmId: farmId,
      ),
    );

    result.fold(
      (failure) {
        emit(ReproductionError(_getErrorMessage(failure)));
      },
      (events) {
        // Ordenar eventos por fecha (más reciente primero)
        final sortedEvents = List<ReproductiveEventEntity>.from(events);
        sortedEvents.sort((a, b) => b.eventDate.compareTo(a.eventDate));
        emit(ReproductionLoaded(sortedEvents));
      },
    );
  }

  /// Recarga los eventos (útil después de agregar/editar)
  Future<void> refresh(String bovineId, String farmId) async {
    await loadEvents(bovineId, farmId);
  }

  /// Obtiene un mensaje de error legible desde un Failure
  String _getErrorMessage(Failure failure) {
    if (failure is ServerFailure) {
      return 'Error del servidor: ${failure.message}';
    } else if (failure is NetworkFailure) {
      return 'Error de conexión: ${failure.message}';
    } else if (failure is CacheFailure) {
      return 'Error de almacenamiento: ${failure.message}';
    } else {
      return failure.message;
    }
  }
}
