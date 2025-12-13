import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/milk_production_entity.dart';
import '../repositories/milk_production_repository.dart';
import 'usecase.dart';

/// Parámetros para actualizar un registro de producción de leche
class UpdateMilkProductionParams {
  final MilkProductionEntity production;

  const UpdateMilkProductionParams({required this.production});
}

/// Caso de uso para actualizar un registro de producción de leche existente
class UpdateMilkProduction
    implements
        UseCase<Either<Failure, MilkProductionEntity>,
            UpdateMilkProductionParams> {
  final MilkProductionRepository repository;

  UpdateMilkProduction(this.repository);

  @override
  Future<Either<Failure, MilkProductionEntity>> call(
      UpdateMilkProductionParams params) async {
    // Validar que el registro sea válido antes de actualizarlo
    if (!params.production.isValid) {
      return Left(ValidationFailure('Los datos de producción de leche no son válidos'));
    }
    return await repository.updateProduction(params.production);
  }
}



