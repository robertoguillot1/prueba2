import '../../../core/utils/result.dart';
import '../../entities/bovinos/produccion_leche.dart';

/// Repositorio abstracto para Producción de Leche
abstract class ProduccionLecheRepository {
  /// Obtiene todas las producciones de leche de una finca
  Future<Result<List<ProduccionLeche>>> getAllProducciones(String farmId);
  
  /// Obtiene una producción por su ID
  Future<Result<ProduccionLeche>> getProduccionById(String id, String farmId);
  
  /// Crea una nueva producción de leche
  Future<Result<ProduccionLeche>> createProduccion(ProduccionLeche produccion);
  
  /// Actualiza una producción existente
  Future<Result<ProduccionLeche>> updateProduccion(ProduccionLeche produccion);
  
  /// Elimina una producción
  Future<Result<void>> deleteProduccion(String id, String farmId);
  
  /// Obtiene producciones de un bovino específico
  Future<Result<List<ProduccionLeche>>> getProduccionesByBovino(String bovinoId, String farmId);
  
  /// Obtiene producciones en un rango de fechas
  Future<Result<List<ProduccionLeche>>> getProduccionesByFecha(String farmId, DateTime fechaInicio, DateTime fechaFin);
}


