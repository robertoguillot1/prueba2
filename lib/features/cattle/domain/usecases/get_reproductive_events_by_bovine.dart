import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/reproductive_event_entity.dart';
import '../repositories/reproductive_event_repository.dart';
import 'usecase.dart';

/// Parámetros para obtener eventos reproductivos de un bovino
class GetReproductiveEventsByBovineParams {
  final String bovineId;
  final String farmId;

  const GetReproductiveEventsByBovineParams({
    required this.bovineId,
    required this.farmId,
  });
}

/// Caso de uso para obtener todos los eventos reproductivos de un bovino
class GetReproductiveEventsByBovine
    implements
        UseCase<Either<Failure, List<ReproductiveEventEntity>>,
            GetReproductiveEventsByBovineParams> {
  final ReproductiveEventRepository repository;

  GetReproductiveEventsByBovine(this.repository);

  @override
  Future<Either<Failure, List<ReproductiveEventEntity>>> call(
      GetReproductiveEventsByBovineParams params) async {
    return await repository.getEventsByBovine(
      params.bovineId,
      params.farmId,
    );
  }
}



