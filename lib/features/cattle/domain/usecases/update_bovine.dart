import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/bovine_entity.dart';
import '../repositories/cattle_repository.dart';
import 'usecase.dart';

/// Parámetros para actualizar un bovino
class UpdateBovineParams {
  final BovineEntity bovine;

  const UpdateBovineParams({required this.bovine});
}

/// Caso de uso para actualizar un bovino existente
class UpdateBovine implements UseCase<Either<Failure, BovineEntity>, UpdateBovineParams> {
  final CattleRepository repository;

  UpdateBovine(this.repository);

  @override
  Future<Either<Failure, BovineEntity>> call(UpdateBovineParams params) async {
    // Validar que el bovino sea válido antes de actualizarlo
    if (!params.bovine.isValid) {
      return Left(ValidationFailure('Los datos del bovino no son válidos'));
    }
    return await repository.updateBovine(params.bovine);
  }
}


