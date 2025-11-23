import '../../../core/utils/result.dart';
import '../../../core/errors/failures.dart';
import '../../entities/ovinos/oveja.dart';
import '../../repositories/ovinos/ovejas_repository.dart';

/// Use case para crear una nueva oveja
class CreateOveja {
  final OvejasRepository repository;

  CreateOveja(this.repository);

  Future<Result<Oveja>> call(Oveja oveja) async {
    if (!oveja.isValid) {
      return const Error(ValidationFailure('Datos de oveja inválidos'));
    }
    return await repository.createOveja(oveja);
  }
}

