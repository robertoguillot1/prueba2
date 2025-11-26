import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../../domain/entities/bovinos/evento_reproductivo.dart';
import '../../../../../domain/usecases/bovinos/create_evento_reproductivo.dart';
import '../../../../../core/utils/result.dart';

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
  final CreateEventoReproductivo _createEvento;

  ReproductiveEventFormCubit({
    required CreateEventoReproductivo createEvento,
  })  : _createEvento = createEvento,
        super(ReproductiveEventFormInitial());

  /// Guarda un nuevo evento reproductivo
  Future<void> saveEvent({
    required String farmId,
    required String bovineId,
    required TipoEventoReproductivo tipo,
    required DateTime fecha,
    required Map<String, dynamic> detalles,
    String? notas,
  }) async {
    emit(ReproductiveEventFormLoading());

    try {
      // Crear el evento
      final evento = EventoReproductivo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        farmId: farmId,
        idAnimal: bovineId,
        tipo: tipo,
        fecha: fecha,
        detalles: detalles,
        notas: notas?.trim().isEmpty == true ? null : notas?.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Llamar al caso de uso
      final result = await _createEvento(evento);

      // Manejar resultado
      switch (result) {
        case Success():
          emit(const ReproductiveEventFormSuccess('Evento registrado exitosamente'));
        case Error(:final failure):
          emit(ReproductiveEventFormError(failure.message));
      }
    } catch (e) {
      emit(ReproductiveEventFormError('Error inesperado: $e'));
    }
  }

  /// Resetea el estado del formulario
  void reset() {
    emit(ReproductiveEventFormInitial());
  }
}


