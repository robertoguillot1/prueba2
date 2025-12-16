import '../../../../core/utils/result.dart';
import '../../../../domain/repositories/trabajadores/trabajadores_repository.dart';
import '../entities/prestamo.dart';

class GetPrestamos {
  final TrabajadoresRepository repository;

  GetPrestamos(this.repository);

  Future<Result<List<Prestamo>>> call(String workerId) async {
    return await repository.getPrestamosByTrabajador(workerId);
  }
}
