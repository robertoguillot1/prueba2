import '../../../core/utils/result.dart';
import '../../entities/ovinos/registro_peso_oveja.dart';

/// Repositorio abstracto para Registros de Peso de Oveja
abstract class RegistrosPesoOvejaRepository {
  /// Obtiene todos los registros de peso de una finca
  Future<Result<List<RegistroPesoOveja>>> getAllRegistros(String farmId);
  
  /// Obtiene un registro por su ID
  Future<Result<RegistroPesoOveja>> getRegistroById(String id, String farmId);
  
  /// Crea un nuevo registro de peso
  Future<Result<RegistroPesoOveja>> createRegistro(RegistroPesoOveja registro);
  
  /// Actualiza un registro existente
  Future<Result<RegistroPesoOveja>> updateRegistro(RegistroPesoOveja registro);
  
  /// Elimina un registro
  Future<Result<void>> deleteRegistro(String id, String farmId);
  
  /// Obtiene registros de una oveja específica
  Future<Result<List<RegistroPesoOveja>>> getRegistrosByOveja(String ovejaId, String farmId);
  
  /// Obtiene registros en un rango de fechas
  Future<Result<List<RegistroPesoOveja>>> getRegistrosByFecha(String farmId, DateTime fechaInicio, DateTime fechaFin);
}


