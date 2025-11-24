import '../../../core/utils/result.dart';
import '../../entities/ovinos/oveja.dart';
import '../../repositories/ovinos/ovejas_repository.dart';

/// Use case para buscar ovejas
class SearchOvejas {
  final OvejasRepository repository;

  SearchOvejas(this.repository);

  Future<Result<List<Oveja>>> call(String farmId, String query) async {
    if (query.trim().isEmpty) {
      return await repository.getAllOvejas(farmId);
    }
    return await repository.searchOvejas(farmId, query);
  }
}



