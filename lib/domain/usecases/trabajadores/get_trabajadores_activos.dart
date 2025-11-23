import '../../../core/utils/result.dart';
import '../../entities/trabajadores/trabajador.dart';
import '../../repositories/trabajadores/trabajadores_repository.dart';

/// Use case para obtener trabajadores activos
class GetTrabajadoresActivos {
  final TrabajadoresRepository repository;

  GetTrabajadoresActivos(this.repository);

  Future<Result<List<Trabajador>>> call(String farmId) async {
    return await repository.getTrabajadoresActivos(farmId);
  }
}


