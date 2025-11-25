import '../entities/farm/farm.dart';

/// Repositorio abstracto para Fincas
abstract class FarmRepository {
  /// Obtiene un stream de todas las fincas de un usuario
  Stream<List<Farm>> getFarmsStream(String userId);

  /// Obtiene una finca por su ID
  Future<Farm?> getFarmById(String userId, String farmId);

  /// Crea una nueva finca
  Future<Farm> createFarm(Farm farm);

  /// Actualiza una finca existente
  Future<Farm> updateFarm(Farm farm);

  /// Elimina una finca
  Future<void> deleteFarm(String userId, String farmId);

  /// Establece la finca actual del usuario
  Future<void> setCurrentFarmId(String userId, String farmId);

  /// Obtiene el ID de la finca actual del usuario
  Future<String?> getCurrentFarmId(String userId);

  /// Obtiene todas las fincas de un usuario de forma inmediata (sin stream)
  Future<List<Farm>> getFarms(String userId);
}

