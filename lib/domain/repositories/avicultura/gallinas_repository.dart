import '../../../core/utils/result.dart';
import '../../entities/avicultura/gallina.dart';

/// Repositorio abstracto para Gallinas
abstract class GallinasRepository {
  /// Obtiene todas las gallinas de una finca
  Future<Result<List<Gallina>>> getAllGallinas(String farmId);
  
  /// Obtiene una gallina por su ID
  Future<Result<Gallina>> getGallinaById(String id, String farmId);
  
  /// Crea una nueva gallina
  Future<Result<Gallina>> createGallina(Gallina gallina);
  
  /// Actualiza una gallina existente
  Future<Result<Gallina>> updateGallina(Gallina gallina);
  
  /// Elimina una gallina
  Future<Result<void>> deleteGallina(String id, String farmId);
  
  /// Obtiene gallinas de un lote específico
  Future<Result<List<Gallina>>> getGallinasByLote(String loteId, String farmId);
  
  /// Busca gallinas por nombre o identificación
  Future<Result<List<Gallina>>> searchGallinas(String farmId, String query);
}



