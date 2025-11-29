import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/reproductive_event_entity.dart';
import '../repositories/reproductive_event_repository.dart';
import 'usecase.dart';

/// Parámetros para obtener un evento reproductivo por ID
class GetReproductiveEventByIdParams {
  final String id;
  final String bovineId;
  final String farmId;

  const GetReproductiveEventByIdParams({
    required this.id,
    required this.bovineId,
    required this.farmId,
  });
}

/// Caso de uso para obtener un evento reproductivo por su ID
class GetReproductiveEventById
    implements
        UseCase<Either<Failure, ReproductiveEventEntity>,
            GetReproductiveEventByIdParams> {
  final ReproductiveEventRepository repository;

  GetReproductiveEventById(this.repository);

  @override
  Future<Either<Failure, ReproductiveEventEntity>> call(
      GetReproductiveEventByIdParams params) async {
    return await repository.getEventById(
      params.id,
      params.bovineId,
      params.farmId,
    );
  }
}

