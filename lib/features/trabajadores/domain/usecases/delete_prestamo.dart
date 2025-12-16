import '../../../../core/utils/result.dart';
import '../../../../domain/repositories/trabajadores/trabajadores_repository.dart';

class DeletePrestamo {
  final TrabajadoresRepository repository;

  DeletePrestamo(this.repository);

  Future<Result<void>> call(String workerId, String prestamoId) async {
    return await repository.deletePrestamo(workerId, prestamoId);
  }
}


