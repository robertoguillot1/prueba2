import '../../../core/utils/result.dart';
import '../../entities/ovinos/oveja.dart';

/// Repositorio abstracto para Ovejas
abstract class OvejasRepository {
  /// Obtiene todas las ovejas de una finca
  Future<Result<List<Oveja>>> getAllOvejas(String farmId);
  
  /// Obtiene una oveja por su ID
  Future<Result<Oveja>> getOvejaById(String id, String farmId);
  
  /// Crea una nueva oveja
  Future<Result<Oveja>> createOveja(Oveja oveja);
  
  /// Actualiza una oveja existente
  Future<Result<Oveja>> updateOveja(Oveja oveja);
  
  /// Elimina una oveja
  Future<Result<void>> deleteOveja(String id, String farmId);
  
  /// Obtiene ovejas filtradas por estado reproductivo
  Future<Result<List<Oveja>>> getOvejasByEstadoReproductivo(
    String farmId,
    EstadoReproductivoOveja estado,
  );
  
  /// Busca ovejas por nombre o identificación
  Future<Result<List<Oveja>>> searchOvejas(String farmId, String query);
}

