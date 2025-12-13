import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/reproductive_event_entity.dart';
import '../repositories/reproductive_event_repository.dart';
import 'usecase.dart';

/// Parámetros para actualizar un evento reproductivo
class UpdateReproductiveEventParams {
  final ReproductiveEventEntity event;

  const UpdateReproductiveEventParams({required this.event});
}

/// Caso de uso para actualizar un evento reproductivo existente
class UpdateReproductiveEvent
    implements
        UseCase<Either<Failure, ReproductiveEventEntity>,
            UpdateReproductiveEventParams> {
  final ReproductiveEventRepository repository;

  UpdateReproductiveEvent(this.repository);

  @override
  Future<Either<Failure, ReproductiveEventEntity>> call(
      UpdateReproductiveEventParams params) async {
    // Validar que el evento sea válido antes de actualizarlo
    if (!params.event.isValid) {
      return Left(ValidationFailure('Los datos del evento reproductivo no son válidos'));
    }
    return await repository.updateEvent(params.event);
  }
}



