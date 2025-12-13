import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/weight_record_entity.dart';
import '../repositories/weight_record_repository.dart';
import 'usecase.dart';

/// Parámetros para agregar un registro de peso
class AddWeightRecordParams {
  final WeightRecordEntity record;

  const AddWeightRecordParams({required this.record});
}

/// Caso de uso para agregar un nuevo registro de peso
class AddWeightRecord
    implements
        UseCase<Either<Failure, WeightRecordEntity>, AddWeightRecordParams> {
  final WeightRecordRepository repository;

  AddWeightRecord(this.repository);

  @override
  Future<Either<Failure, WeightRecordEntity>> call(
      AddWeightRecordParams params) async {
    // Validar que el registro sea válido antes de agregarlo
    if (!params.record.isValid) {
      return Left(ValidationFailure('Los datos del registro de peso no son válidos'));
    }
    return await repository.addRecord(params.record);
  }
}



