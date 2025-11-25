import '../../../core/utils/result.dart';
import '../../repositories/trabajadores/trabajadores_repository.dart';

/// Use case para eliminar un trabajador
class DeleteTrabajador {
  final TrabajadoresRepository repository;

  DeleteTrabajador(this.repository);

  Future<Result<void>> call(String id, String farmId) async {
    return await repository.deleteTrabajador(id, farmId);
  }
}

