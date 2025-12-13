import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/milk_production_repository.dart';
import 'usecase.dart';

/// Parámetros para eliminar un registro de producción de leche
class DeleteMilkProductionParams {
  final String id;
  final String bovineId;
  final String farmId;

  const DeleteMilkProductionParams({
    required this.id,
    required this.bovineId,
    required this.farmId,
  });
}

/// Caso de uso para eliminar un registro de producción de leche
class DeleteMilkProduction
    implements UseCase<Either<Failure, void>, DeleteMilkProductionParams> {
  final MilkProductionRepository repository;

  DeleteMilkProduction(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteMilkProductionParams params) async {
    return await repository.deleteProduction(
      params.id,
      params.bovineId,
      params.farmId,
    );
  }
}



