import '../../../../core/utils/result.dart';
import '../../../../domain/repositories/trabajadores/trabajadores_repository.dart';
import '../entities/prestamo.dart';

class UpdatePrestamo {
  final TrabajadoresRepository repository;

  UpdatePrestamo(this.repository);

  Future<Result<Prestamo>> call(Prestamo prestamo) async {
    return await repository.updatePrestamo(prestamo);
  }
}
