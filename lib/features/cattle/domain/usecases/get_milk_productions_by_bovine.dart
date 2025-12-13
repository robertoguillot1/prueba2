import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/milk_production_entity.dart';
import '../repositories/milk_production_repository.dart';
import 'usecase.dart';

/// Parámetros para obtener producción de leche de un bovino
class GetMilkProductionsByBovineParams {
  final String bovineId;
  final String farmId;

  const GetMilkProductionsByBovineParams({
    required this.bovineId,
    required this.farmId,
  });
}

/// Caso de uso para obtener todos los registros de producción de leche de un bovino
class GetMilkProductionsByBovine
    implements
        UseCase<Either<Failure, List<MilkProductionEntity>>,
            GetMilkProductionsByBovineParams> {
  final MilkProductionRepository repository;

  GetMilkProductionsByBovine(this.repository);

  @override
  Future<Either<Failure, List<MilkProductionEntity>>> call(
      GetMilkProductionsByBovineParams params) async {
    return await repository.getProductionsByBovine(
      params.bovineId,
      params.farmId,
    );
  }
}



