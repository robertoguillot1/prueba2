import '../../../core/utils/result.dart';
import '../../entities/ovinos/parto_oveja.dart';

/// Repositorio abstracto para Partos de Oveja
abstract class PartosOvejaRepository {
  /// Obtiene todos los partos de una finca
  Future<Result<List<PartoOveja>>> getAllPartos(String farmId);
  
  /// Obtiene un parto por su ID
  Future<Result<PartoOveja>> getPartoById(String id, String farmId);
  
  /// Crea un nuevo parto
  Future<Result<PartoOveja>> createParto(PartoOveja parto);
  
  /// Actualiza un parto existente
  Future<Result<PartoOveja>> updateParto(PartoOveja parto);
  
  /// Elimina un parto
  Future<Result<void>> deleteParto(String id, String farmId);
  
  /// Obtiene partos de una oveja específica
  Future<Result<List<PartoOveja>>> getPartosByOveja(String ovejaId, String farmId);
  
  /// Obtiene partos en un rango de fechas
  Future<Result<List<PartoOveja>>> getPartosByFecha(String farmId, DateTime fechaInicio, DateTime fechaFin);
}


