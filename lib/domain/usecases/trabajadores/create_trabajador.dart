import '../../../core/utils/result.dart';
import '../../../core/errors/failures.dart';
import '../../entities/trabajadores/trabajador.dart';
import '../../repositories/trabajadores/trabajadores_repository.dart';

/// Use case para crear un nuevo trabajador
class CreateTrabajador {
  final TrabajadoresRepository repository;

  CreateTrabajador(this.repository);

  Future<Result<Trabajador>> call(Trabajador trabajador) async {
    if (!trabajador.isValid) {
      return const Error(ValidationFailure('Datos de trabajador inválidos'));
    }
    return await repository.createTrabajador(trabajador);
  }
}


