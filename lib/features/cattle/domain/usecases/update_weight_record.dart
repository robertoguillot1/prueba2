import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/weight_record_entity.dart';
import '../repositories/weight_record_repository.dart';
import 'usecase.dart';

/// Parámetros para actualizar un registro de peso
class UpdateWeightRecordParams {
  final WeightRecordEntity record;

  const UpdateWeightRecordParams({required this.record});
}

/// Caso de uso para actualizar un registro de peso existente
class UpdateWeightRecord
    implements
        UseCase<Either<Failure, WeightRecordEntity>, UpdateWeightRecordParams> {
  final WeightRecordRepository repository;

  UpdateWeightRecord(this.repository);

  @override
  Future<Either<Failure, WeightRecordEntity>> call(
      UpdateWeightRecordParams params) async {
    // Validar que el registro sea válido antes de actualizarlo
    if (!params.record.isValid) {
      return Left(ValidationFailure('Los datos del registro de peso no son válidos'));
    }
    return await repository.updateRecord(params.record);
  }
}

