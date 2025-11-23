import '../../../core/utils/result.dart';
import '../../repositories/porcinos/cerdos_repository.dart';

/// Use case para eliminar un cerdo
class DeleteCerdo {
  final CerdosRepository repository;

  DeleteCerdo(this.repository);

  Future<Result<void>> call(String id, String farmId) async {
    return await repository.deleteCerdo(id, farmId);
  }
}

