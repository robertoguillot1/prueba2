import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/cattle_repository.dart';
import 'usecase.dart';

/// Parámetros para eliminar un bovino
class DeleteBovineParams {
  final String id;

  const DeleteBovineParams({required this.id});
}

/// Caso de uso para eliminar un bovino
class DeleteBovine implements UseCase<Either<Failure, void>, DeleteBovineParams> {
  final CattleRepository repository;

  DeleteBovine(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteBovineParams params) async {
    if (params.id.isEmpty) {
      return Left(ValidationFailure('El ID del bovino no puede estar vacío'));
    }
    return await repository.deleteBovine(params.id);
  }
}



