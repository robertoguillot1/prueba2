import '../../../../core/utils/result.dart';
import '../../../../domain/repositories/trabajadores/trabajadores_repository.dart';
import '../entities/prestamo.dart';

class AddPrestamo {
  final TrabajadoresRepository repository;

  AddPrestamo(this.repository);

  Future<Result<Prestamo>> call(Prestamo prestamo) async {
    return await repository.createPrestamo(prestamo);
  }
}
