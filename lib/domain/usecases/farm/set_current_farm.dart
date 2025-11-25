import '../../repositories/farm_repository.dart';

/// Caso de uso para establecer la finca actual del usuario
class SetCurrentFarm {
  final FarmRepository repository;

  SetCurrentFarm(this.repository);

  /// Establece la finca actual del usuario
  Future<void> call(String userId, String farmId) async {
    return await repository.setCurrentFarmId(userId, farmId);
  }
}

