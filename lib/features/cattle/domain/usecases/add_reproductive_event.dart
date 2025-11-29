import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/reproductive_event_entity.dart';
import '../repositories/reproductive_event_repository.dart';
import 'usecase.dart';

/// Parámetros para agregar un evento reproductivo
class AddReproductiveEventParams {
  final ReproductiveEventEntity event;

  const AddReproductiveEventParams({required this.event});
}

/// Caso de uso para agregar un nuevo evento reproductivo
class AddReproductiveEvent
    implements
        UseCase<Either<Failure, ReproductiveEventEntity>,
            AddReproductiveEventParams> {
  final ReproductiveEventRepository repository;

  AddReproductiveEvent(this.repository);

  @override
  Future<Either<Failure, ReproductiveEventEntity>> call(
      AddReproductiveEventParams params) async {
    // Validar que el evento sea válido antes de agregarlo
    if (!params.event.isValid) {
      return Left(ValidationFailure('Los datos del evento reproductivo no son válidos'));
    }
    return await repository.addEvent(params.event);
  }
}

