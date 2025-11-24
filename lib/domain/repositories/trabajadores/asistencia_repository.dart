import '../../../core/utils/result.dart';
import '../../entities/trabajadores/asistencia.dart';

/// Repositorio abstracto para Asistencia
abstract class AsistenciaRepository {
  /// Obtiene todos los registros de asistencia de una finca
  Future<Result<List<Asistencia>>> getAllAsistencias(String farmId);
  
  /// Obtiene un registro por su ID
  Future<Result<Asistencia>> getAsistenciaById(String id, String farmId);
  
  /// Crea un nuevo registro de asistencia
  Future<Result<Asistencia>> createAsistencia(Asistencia asistencia);
  
  /// Actualiza un registro existente
  Future<Result<Asistencia>> updateAsistencia(Asistencia asistencia);
  
  /// Elimina un registro
  Future<Result<void>> deleteAsistencia(String id, String farmId);
  
  /// Obtiene asistencias de un trabajador específico
  Future<Result<List<Asistencia>>> getAsistenciasByTrabajador(String trabajadorId, String farmId);
  
  /// Obtiene asistencias en un rango de fechas
  Future<Result<List<Asistencia>>> getAsistenciasByFecha(String farmId, DateTime fechaInicio, DateTime fechaFin);
}



