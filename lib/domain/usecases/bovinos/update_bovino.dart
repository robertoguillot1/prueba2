import '../../../core/utils/result.dart';
import '../../../core/errors/failures.dart';
import '../../entities/bovinos/bovino.dart';
import '../../repositories/bovinos/bovinos_repository.dart';

/// Use case para actualizar un bovino existente
class UpdateBovino {
  final BovinosRepository repository;

  UpdateBovino(this.repository);

  Future<Result<Bovino>> call(Bovino bovino) async {
    if (!bovino.isValid) {
      return const Error(ValidationFailure('Datos de bovino inválidos'));
    }
    return await repository.updateBovino(bovino);
  }
}

