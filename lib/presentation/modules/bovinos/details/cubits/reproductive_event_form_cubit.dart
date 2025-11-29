import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import '../../../../../features/cattle/domain/entities/reproductive_event_entity.dart';
import '../../../../../features/cattle/domain/usecases/add_reproductive_event.dart';
import '../../../../../core/errors/failures.dart';

// ============================================
// ESTADOS
// ============================================

/// Estados del formulario de evento reproductivo
abstract class ReproductiveEventFormState extends Equatable {
  const ReproductiveEventFormState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial del formulario
class ReproductiveEventFormInitial extends ReproductiveEventFormState {}

/// Estado de guardando
class ReproductiveEventFormLoading extends ReproductiveEventFormState {}

/// Estado de éxito
class ReproductiveEventFormSuccess extends ReproductiveEventFormState {
  final String message;

  const ReproductiveEventFormSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// Estado de error
class ReproductiveEventFormError extends ReproductiveEventFormState {
  final String message;

  const ReproductiveEventFormError(this.message);

  @override
  List<Object?> get props => [message];
}

// ============================================
// CUBIT
// ============================================

/// Cubit para manejar el formulario de eventos reproductivos
class ReproductiveEventFormCubit extends Cubit<ReproductiveEventFormState> {
  final AddReproductiveEvent _addEvent;

  ReproductiveEventFormCubit({
    required AddReproductiveEvent addEvent,
  })  : _addEvent = addEvent,
        super(ReproductiveEventFormInitial());

  /// Guarda un nuevo evento reproductivo
  Future<void> saveEvent({
    required String farmId,
    required String bovineId,
    required ReproductiveEventType type,
    required DateTime eventDate,
    required Map<String, dynamic> details,
    String? notes,
  }) async {
    emit(ReproductiveEventFormLoading());

    // Crear la entidad (el ID se generará en Firestore)
    final event = ReproductiveEventEntity(
      id: '', // Se generará en Firestore
      bovineId: bovineId,
      farmId: farmId,
      type: type,
      eventDate: eventDate,
      details: details,
      notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
      createdAt: DateTime.now(),
      updatedAt: null,
    );

    // Validar que la entidad sea válida
    if (!event.isValid) {
      emit(const ReproductiveEventFormError('Los datos del evento no son válidos'));
      return;
    }

    // Llamar al caso de uso
    final result = await _addEvent(AddReproductiveEventParams(event: event));

    // Manejar resultado
    result.fold(
      (failure) {
        emit(ReproductiveEventFormError(_getErrorMessage(failure)));
      },
      (_) {
        emit(const ReproductiveEventFormSuccess('Evento registrado exitosamente'));
      },
    );
  }

  /// Resetea el estado del formulario
  void reset() {
    emit(ReproductiveEventFormInitial());
  }

  /// Obtiene un mensaje de error legible desde un Failure
  String _getErrorMessage(Failure failure) {
    if (failure is ServerFailure) {
      return 'Error del servidor: ${failure.message}';
    } else if (failure is NetworkFailure) {
      return 'Error de conexión: ${failure.message}';
    } else if (failure is ValidationFailure) {
      return 'Error de validación: ${failure.message}';
    } else {
      return failure.message;
    }
  }
}
