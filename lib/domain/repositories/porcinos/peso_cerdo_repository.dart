import '../../../core/utils/result.dart';
import '../../entities/porcinos/peso_cerdo.dart';

/// Repositorio abstracto para Peso de Cerdo
abstract class PesoCerdoRepository {
  /// Obtiene todos los registros de peso de una finca
  Future<Result<List<PesoCerdo>>> getAllRegistros(String farmId);
  
  /// Obtiene un registro por su ID
  Future<Result<PesoCerdo>> getRegistroById(String id, String farmId);
  
  /// Crea un nuevo registro de peso
  Future<Result<PesoCerdo>> createRegistro(PesoCerdo registro);
  
  /// Actualiza un registro existente
  Future<Result<PesoCerdo>> updateRegistro(PesoCerdo registro);
  
  /// Elimina un registro
  Future<Result<void>> deleteRegistro(String id, String farmId);
  
  /// Obtiene registros de un cerdo específico
  Future<Result<List<PesoCerdo>>> getRegistrosByCerdo(String cerdoId, String farmId);
  
  /// Obtiene registros en un rango de fechas
  Future<Result<List<PesoCerdo>>> getRegistrosByFecha(String farmId, DateTime fechaInicio, DateTime fechaFin);
}



