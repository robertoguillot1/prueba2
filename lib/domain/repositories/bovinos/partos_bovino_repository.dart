import '../../../core/utils/result.dart';
import '../../entities/bovinos/partos_bovino.dart';

/// Repositorio abstracto para Partos de Bovino
abstract class PartosBovinoRepository {
  /// Obtiene todos los partos de una finca
  Future<Result<List<PartosBovino>>> getAllPartos(String farmId);
  
  /// Obtiene un parto por su ID
  Future<Result<PartosBovino>> getPartoById(String id, String farmId);
  
  /// Crea un nuevo parto
  Future<Result<PartosBovino>> createParto(PartosBovino parto);
  
  /// Actualiza un parto existente
  Future<Result<PartosBovino>> updateParto(PartosBovino parto);
  
  /// Elimina un parto
  Future<Result<void>> deleteParto(String id, String farmId);
  
  /// Obtiene partos de un bovino específico
  Future<Result<List<PartosBovino>>> getPartosByBovino(String bovinoId, String farmId);
  
  /// Obtiene partos en un rango de fechas
  Future<Result<List<PartosBovino>>> getPartosByFecha(String farmId, DateTime fechaInicio, DateTime fechaFin);
}



