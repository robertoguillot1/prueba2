import '../../../core/utils/result.dart';
import '../../../core/errors/failures.dart';
import '../../entities/porcinos/cerdo.dart';
import '../../repositories/porcinos/cerdos_repository.dart';

/// Use case para crear un nuevo cerdo
class CreateCerdo {
  final CerdosRepository repository;

  CreateCerdo(this.repository);

  Future<Result<Cerdo>> call(Cerdo cerdo) async {
    if (!cerdo.isValid) {
      return const Error(ValidationFailure('Datos de cerdo inválidos'));
    }
    return await repository.createCerdo(cerdo);
  }
}


