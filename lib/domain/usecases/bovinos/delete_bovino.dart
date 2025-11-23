import '../../../core/utils/result.dart';
import '../../repositories/bovinos/bovinos_repository.dart';

/// Use case para eliminar un bovino
class DeleteBovino {
  final BovinosRepository repository;

  DeleteBovino(this.repository);

  Future<Result<void>> call(String id, String farmId) async {
    return await repository.deleteBovino(id, farmId);
  }
}

