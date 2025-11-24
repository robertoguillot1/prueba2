import '../../../core/utils/result.dart';
import '../../../core/errors/failures.dart';
import '../../entities/bovinos/bovino.dart';
import '../../repositories/bovinos/bovinos_repository.dart';

/// Use case para crear un nuevo bovino
class CreateBovino {
  final BovinosRepository repository;

  CreateBovino(this.repository);

  Future<Result<Bovino>> call(Bovino bovino) async {
    if (!bovino.isValid) {
      return const Error(ValidationFailure('Datos de bovino inválidos'));
    }
    return await repository.createBovino(bovino);
  }
}



