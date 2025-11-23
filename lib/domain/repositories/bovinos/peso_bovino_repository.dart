import '../../../core/utils/result.dart';
import '../../entities/bovinos/peso_bovino.dart';

/// Repositorio abstracto para Peso de Bovino
abstract class PesoBovinoRepository {
  /// Obtiene todos los registros de peso de una finca
  Future<Result<List<PesoBovino>>> getAllRegistros(String farmId);
  
  /// Obtiene un registro por su ID
  Future<Result<PesoBovino>> getRegistroById(String id, String farmId);
  
  /// Crea un nuevo registro de peso
  Future<Result<PesoBovino>> createRegistro(PesoBovino registro);
  
  /// Actualiza un registro existente
  Future<Result<PesoBovino>> updateRegistro(PesoBovino registro);
  
  /// Elimina un registro
  Future<Result<void>> deleteRegistro(String id, String farmId);
  
  /// Obtiene registros de un bovino específico
  Future<Result<List<PesoBovino>>> getRegistrosByBovino(String bovinoId, String farmId);
  
  /// Obtiene registros en un rango de fechas
  Future<Result<List<PesoBovino>>> getRegistrosByFecha(String farmId, DateTime fechaInicio, DateTime fechaFin);
}


