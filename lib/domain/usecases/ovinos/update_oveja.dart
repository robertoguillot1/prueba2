import '../../../core/utils/result.dart';
import '../../../core/errors/failures.dart';
import '../../entities/ovinos/oveja.dart';
import '../../repositories/ovinos/ovejas_repository.dart';

/// Use case para actualizar una oveja existente
class UpdateOveja {
  final OvejasRepository repository;

  UpdateOveja(this.repository);

  Future<Result<Oveja>> call(Oveja oveja) async {
    if (!oveja.isValid) {
      return const Error(ValidationFailure('Datos de oveja inválidos'));
    }
    return await repository.updateOveja(oveja);
  }
}

