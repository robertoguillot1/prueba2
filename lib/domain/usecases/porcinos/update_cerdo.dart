import '../../../core/utils/result.dart';
import '../../../core/errors/failures.dart';
import '../../entities/porcinos/cerdo.dart';
import '../../repositories/porcinos/cerdos_repository.dart';

/// Use case para actualizar un cerdo existente
class UpdateCerdo {
  final CerdosRepository repository;

  UpdateCerdo(this.repository);

  Future<Result<Cerdo>> call(Cerdo cerdo) async {
    if (!cerdo.isValid) {
      return const Error(ValidationFailure('Datos de cerdo inválidos'));
    }
    return await repository.updateCerdo(cerdo);
  }
}

