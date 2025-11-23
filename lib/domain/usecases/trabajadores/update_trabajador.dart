import '../../../core/utils/result.dart';
import '../../../core/errors/failures.dart';
import '../../entities/trabajadores/trabajador.dart';
import '../../repositories/trabajadores/trabajadores_repository.dart';

/// Use case para actualizar un trabajador existente
class UpdateTrabajador {
  final TrabajadoresRepository repository;

  UpdateTrabajador(this.repository);

  Future<Result<Trabajador>> call(Trabajador trabajador) async {
    if (!trabajador.isValid) {
      return const Error(ValidationFailure('Datos de trabajador inválidos'));
    }
    return await repository.updateTrabajador(trabajador);
  }
}


