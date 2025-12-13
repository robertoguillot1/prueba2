import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/weight_record_repository.dart';
import 'usecase.dart';

/// Parámetros para eliminar un registro de peso
class DeleteWeightRecordParams {
  final String id;
  final String bovineId;
  final String farmId;

  const DeleteWeightRecordParams({
    required this.id,
    required this.bovineId,
    required this.farmId,
  });
}

/// Caso de uso para eliminar un registro de peso
class DeleteWeightRecord
    implements UseCase<Either<Failure, void>, DeleteWeightRecordParams> {
  final WeightRecordRepository repository;

  DeleteWeightRecord(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteWeightRecordParams params) async {
    return await repository.deleteRecord(
      params.id,
      params.bovineId,
      params.farmId,
    );
  }
}



