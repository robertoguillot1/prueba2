import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/milk_production_entity.dart';
import '../repositories/milk_production_repository.dart';
import 'usecase.dart';

/// Parámetros para obtener un registro de producción de leche por ID
class GetMilkProductionByIdParams {
  final String id;
  final String bovineId;
  final String farmId;

  const GetMilkProductionByIdParams({
    required this.id,
    required this.bovineId,
    required this.farmId,
  });
}

/// Caso de uso para obtener un registro de producción de leche por su ID
class GetMilkProductionById
    implements
        UseCase<Either<Failure, MilkProductionEntity>,
            GetMilkProductionByIdParams> {
  final MilkProductionRepository repository;

  GetMilkProductionById(this.repository);

  @override
  Future<Either<Failure, MilkProductionEntity>> call(
      GetMilkProductionByIdParams params) async {
    return await repository.getProductionById(
      params.id,
      params.bovineId,
      params.farmId,
    );
  }
}

