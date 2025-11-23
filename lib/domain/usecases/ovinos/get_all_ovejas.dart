import '../../../core/utils/result.dart';
import '../../entities/ovinos/oveja.dart';
import '../../repositories/ovinos/ovejas_repository.dart';

/// Use case para obtener todas las ovejas de una finca
class GetAllOvejas {
  final OvejasRepository repository;

  GetAllOvejas(this.repository);

  Future<Result<List<Oveja>>> call(String farmId) async {
    return await repository.getAllOvejas(farmId);
  }
}


