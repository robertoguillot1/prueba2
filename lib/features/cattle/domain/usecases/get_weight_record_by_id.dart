import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/weight_record_entity.dart';
import '../repositories/weight_record_repository.dart';
import 'usecase.dart';

/// Parámetros para obtener un registro de peso por ID
class GetWeightRecordByIdParams {
  final String id;
  final String bovineId;
  final String farmId;

  const GetWeightRecordByIdParams({
    required this.id,
    required this.bovineId,
    required this.farmId,
  });
}

/// Caso de uso para obtener un registro de peso por su ID
class GetWeightRecordById
    implements
        UseCase<Either<Failure, WeightRecordEntity>, GetWeightRecordByIdParams> {
  final WeightRecordRepository repository;

  GetWeightRecordById(this.repository);

  @override
  Future<Either<Failure, WeightRecordEntity>> call(
      GetWeightRecordByIdParams params) async {
    return await repository.getRecordById(
      params.id,
      params.bovineId,
      params.farmId,
    );
  }
}



