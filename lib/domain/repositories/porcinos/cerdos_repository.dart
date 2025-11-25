import '../../../core/utils/result.dart';
import '../../entities/porcinos/cerdo.dart';

/// Repositorio abstracto para Cerdos
abstract class CerdosRepository {
  /// Obtiene todos los cerdos de una finca
  Future<Result<List<Cerdo>>> getAllCerdos(String farmId);
  
  /// Obtiene un cerdo por su ID
  Future<Result<Cerdo>> getCerdoById(String id, String farmId);
  
  /// Crea un nuevo cerdo
  Future<Result<Cerdo>> createCerdo(Cerdo cerdo);
  
  /// Actualiza un cerdo existente
  Future<Result<Cerdo>> updateCerdo(Cerdo cerdo);
  
  /// Elimina un cerdo
  Future<Result<void>> deleteCerdo(String id, String farmId);
  
  /// Obtiene cerdos filtrados por etapa de alimentación
  Future<Result<List<Cerdo>>> getCerdosByStage(String farmId, String stage);
  
  /// Busca cerdos por identificación
  Future<Result<List<Cerdo>>> searchCerdos(String farmId, String query);
}

