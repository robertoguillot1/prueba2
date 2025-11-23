import '../../../core/utils/result.dart';
import '../../entities/trabajadores/trabajador.dart';
import '../../repositories/trabajadores/trabajadores_repository.dart';

/// Use case para obtener todos los trabajadores de una finca
class GetAllTrabajadores {
  final TrabajadoresRepository repository;

  GetAllTrabajadores(this.repository);

  Future<Result<List<Trabajador>>> call(String farmId) async {
    return await repository.getAllTrabajadores(farmId);
  }
}


