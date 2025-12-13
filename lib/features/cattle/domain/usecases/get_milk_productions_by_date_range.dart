import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/milk_production_entity.dart';
import '../repositories/milk_production_repository.dart';
import 'usecase.dart';

/// Parámetros para obtener producción de leche por rango de fechas
class GetMilkProductionsByDateRangeParams {
  final String farmId;
  final DateTime startDate;
  final DateTime endDate;

  const GetMilkProductionsByDateRangeParams({
    required this.farmId,
    required this.startDate,
    required this.endDate,
  });
}

/// Caso de uso para obtener producción de leche por rango de fechas
class GetMilkProductionsByDateRange
    implements
        UseCase<Either<Failure, List<MilkProductionEntity>>,
            GetMilkProductionsByDateRangeParams> {
  final MilkProductionRepository repository;

  GetMilkProductionsByDateRange(this.repository);

  @override
  Future<Either<Failure, List<MilkProductionEntity>>> call(
      GetMilkProductionsByDateRangeParams params) async {
    return await repository.getProductionsByDateRange(
      params.farmId,
      params.startDate,
      params.endDate,
    );
  }
}



