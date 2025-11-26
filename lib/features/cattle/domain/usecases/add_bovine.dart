import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/bovine_entity.dart';
import '../repositories/cattle_repository.dart';
import 'usecase.dart';

/// Parámetros para agregar un bovino
class AddBovineParams {
  final BovineEntity bovine;

  const AddBovineParams({required this.bovine});
}

/// Caso de uso para agregar un nuevo bovino
class AddBovine implements UseCase<Either<Failure, BovineEntity>, AddBovineParams> {
  final CattleRepository repository;

  AddBovine(this.repository);

  @override
  Future<Either<Failure, BovineEntity>> call(AddBovineParams params) async {
    // Validar que el bovino sea válido antes de agregarlo
    if (!params.bovine.isValid) {
      return Left(ValidationFailure('Los datos del bovino no son válidos'));
    }
    return await repository.addBovine(params.bovine);
  }
}


