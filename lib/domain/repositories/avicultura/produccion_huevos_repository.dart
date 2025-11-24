import '../../../core/utils/result.dart';
import '../../entities/avicultura/produccion_huevos.dart';

/// Repositorio abstracto para Producción de Huevos
abstract class ProduccionHuevosRepository {
  /// Obtiene todas las producciones de huevos de una finca
  Future<Result<List<ProduccionHuevos>>> getAllProducciones(String farmId);
  
  /// Obtiene una producción por su ID
  Future<Result<ProduccionHuevos>> getProduccionById(String id, String farmId);
  
  /// Crea una nueva producción de huevos
  Future<Result<ProduccionHuevos>> createProduccion(ProduccionHuevos produccion);
  
  /// Actualiza una producción existente
  Future<Result<ProduccionHuevos>> updateProduccion(ProduccionHuevos produccion);
  
  /// Elimina una producción
  Future<Result<void>> deleteProduccion(String id, String farmId);
  
  /// Obtiene producciones de una gallina específica
  Future<Result<List<ProduccionHuevos>>> getProduccionesByGallina(String gallinaId, String farmId);
  
  /// Obtiene producciones de un lote específico
  Future<Result<List<ProduccionHuevos>>> getProduccionesByLote(String loteId, String farmId);
  
  /// Obtiene producciones en un rango de fechas
  Future<Result<List<ProduccionHuevos>>> getProduccionesByFecha(String farmId, DateTime fechaInicio, DateTime fechaFin);
}



