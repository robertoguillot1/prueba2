import '../../../core/utils/result.dart';
import '../../entities/trabajadores/trabajador.dart';

/// Repositorio abstracto para Trabajadores
abstract class TrabajadoresRepository {
  /// Obtiene todos los trabajadores de una finca
  Future<Result<List<Trabajador>>> getAllTrabajadores(String farmId);
  
  /// Obtiene un trabajador por su ID
  Future<Result<Trabajador>> getTrabajadorById(String id, String farmId);
  
  /// Crea un nuevo trabajador
  Future<Result<Trabajador>> createTrabajador(Trabajador trabajador);
  
  /// Actualiza un trabajador existente
  Future<Result<Trabajador>> updateTrabajador(Trabajador trabajador);
  
  /// Elimina un trabajador
  Future<Result<void>> deleteTrabajador(String id, String farmId);
  
  /// Obtiene trabajadores activos
  Future<Result<List<Trabajador>>> getTrabajadoresActivos(String farmId);
  
  /// Busca trabajadores por nombre, identificación o cargo
  Future<Result<List<Trabajador>>> searchTrabajadores(String farmId, String query);
}


