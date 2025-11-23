import '../../../core/utils/result.dart';
import '../../entities/bovinos/bovino.dart';

/// Repositorio abstracto para Bovinos
abstract class BovinosRepository {
  /// Obtiene todos los bovinos de una finca
  Future<Result<List<Bovino>>> getAllBovinos(String farmId);
  
  /// Obtiene un bovino por su ID
  Future<Result<Bovino>> getBovinoById(String id, String farmId);
  
  /// Crea un nuevo bovino
  Future<Result<Bovino>> createBovino(Bovino bovino);
  
  /// Actualiza un bovino existente
  Future<Result<Bovino>> updateBovino(Bovino bovino);
  
  /// Elimina un bovino
  Future<Result<void>> deleteBovino(String id, String farmId);
  
  /// Obtiene bovinos filtrados por categoría
  Future<Result<List<Bovino>>> getBovinosByCategory(String farmId, String category);
  
  /// Busca bovinos por nombre o identificación
  Future<Result<List<Bovino>>> searchBovinos(String farmId, String query);
}

