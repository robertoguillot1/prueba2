import '../../repositories/farm_repository.dart';

/// Caso de uso para eliminar una finca
class DeleteFarm {
  final FarmRepository repository;

  DeleteFarm(this.repository);

  /// Elimina una finca
  Future<void> call(String userId, String farmId) async {
    return await repository.deleteFarm(userId, farmId);
  }
}





