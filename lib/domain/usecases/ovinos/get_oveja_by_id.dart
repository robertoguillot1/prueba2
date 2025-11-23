import '../../../core/utils/result.dart';
import '../../entities/ovinos/oveja.dart';
import '../../repositories/ovinos/ovejas_repository.dart';

/// Use case para obtener una oveja por su ID
class GetOvejaById {
  final OvejasRepository repository;

  GetOvejaById(this.repository);

  Future<Result<Oveja>> call(String id, String farmId) async {
    return await repository.getOvejaById(id, farmId);
  }
}


