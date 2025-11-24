import '../../../core/utils/result.dart';
import '../../repositories/ovinos/ovejas_repository.dart';

/// Use case para eliminar una oveja
class DeleteOveja {
  final OvejasRepository repository;

  DeleteOveja(this.repository);

  Future<Result<void>> call(String id, String farmId) async {
    return await repository.deleteOveja(id, farmId);
  }
}



