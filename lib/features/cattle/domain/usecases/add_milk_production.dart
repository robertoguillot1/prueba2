import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/milk_production_entity.dart';
import '../repositories/milk_production_repository.dart';
import 'usecase.dart';

/// Parámetros para agregar un registro de producción de leche
class AddMilkProductionParams {
  final MilkProductionEntity production;

  const AddMilkProductionParams({required this.production});
}

/// Caso de uso para agregar un nuevo registro de producción de leche
class AddMilkProduction
    implements
        UseCase<Either<Failure, MilkProductionEntity>, AddMilkProductionParams> {
  final MilkProductionRepository repository;

  AddMilkProduction(this.repository);

  @override
  Future<Either<Failure, MilkProductionEntity>> call(
      AddMilkProductionParams params) async {
    // Validar que el registro sea válido antes de agregarlo
    if (!params.production.isValid) {
      return Left(ValidationFailure('Los datos de producción de leche no son válidos'));
    }
    return await repository.addProduction(params.production);
  }
}



