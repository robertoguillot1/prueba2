import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/reproductive_event_repository.dart';
import 'usecase.dart';

/// Parámetros para eliminar un evento reproductivo
class DeleteReproductiveEventParams {
  final String id;
  final String bovineId;
  final String farmId;

  const DeleteReproductiveEventParams({
    required this.id,
    required this.bovineId,
    required this.farmId,
  });
}

/// Caso de uso para eliminar un evento reproductivo
class DeleteReproductiveEvent
    implements UseCase<Either<Failure, void>, DeleteReproductiveEventParams> {
  final ReproductiveEventRepository repository;

  DeleteReproductiveEvent(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteReproductiveEventParams params) async {
    return await repository.deleteEvent(
      params.id,
      params.bovineId,
      params.farmId,
    );
  }
}

