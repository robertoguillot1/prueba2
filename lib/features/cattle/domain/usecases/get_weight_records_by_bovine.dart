import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/weight_record_entity.dart';
import '../repositories/weight_record_repository.dart';
import 'usecase.dart';

/// Parámetros para obtener registros de peso de un bovino
class GetWeightRecordsByBovineParams {
  final String bovineId;
  final String farmId;

  const GetWeightRecordsByBovineParams({
    required this.bovineId,
    required this.farmId,
  });
}

/// Caso de uso para obtener todos los registros de peso de un bovino
class GetWeightRecordsByBovine
    implements
        UseCase<Either<Failure, List<WeightRecordEntity>>,
            GetWeightRecordsByBovineParams> {
  final WeightRecordRepository repository;

  GetWeightRecordsByBovine(this.repository);

  @override
  Future<Either<Failure, List<WeightRecordEntity>>> call(
      GetWeightRecordsByBovineParams params) async {
    return await repository.getRecordsByBovine(
      params.bovineId,
      params.farmId,
    );
  }
}

