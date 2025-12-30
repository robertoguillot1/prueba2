import '../../../core/utils/result.dart';
import '../../entities/trabajadores/trabajador.dart';
import '../../repositories/trabajadores/trabajadores_repository.dart';

/// Use case para buscar trabajadores por nombre, identificación o cargo
class SearchTrabajadores {
  final TrabajadoresRepository repository;

  SearchTrabajadores(this.repository);

  Future<Result<List<Trabajador>>> call(String farmId, String query) async {
    return await repository.searchTrabajadores(farmId, query);
  }
}








