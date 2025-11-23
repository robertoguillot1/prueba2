import '../../../core/utils/result.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/avicultura/gallina.dart';
import '../../../domain/repositories/avicultura/gallinas_repository.dart';
import '../../datasources/avicultura/gallinas_datasource.dart';
import '../../models/avicultura/gallina_model.dart';

/// Implementación del repositorio de Gallinas
class GallinasRepositoryImpl implements GallinasRepository {
  final GallinasDataSource dataSource;

  GallinasRepositoryImpl(this.dataSource);

  @override
  Future<Result<List<Gallina>>> getAllGallinas(String farmId) async {
    try {
      final models = await dataSource.getAllGallinas(farmId);
      return Success(models);
    } catch (e) {
      return Error(CacheFailure('Error al obtener gallinas: $e'));
    }
  }

  @override
  Future<Result<Gallina>> getGallinaById(String id, String farmId) async {
    try {
      final model = await dataSource.getGallinaById(id, farmId);
      return Success(model);
    } catch (e) {
      if (e is CacheFailure) {
        return Error(e);
      }
      return Error(CacheFailure('Error al obtener gallina: $e'));
    }
  }

  @override
  Future<Result<Gallina>> createGallina(Gallina gallina) async {
    try {
      final model = GallinaModel.fromEntity(gallina);
      final created = await dataSource.createGallina(model);
      return Success(created);
    } catch (e) {
      if (e is Failure) {
        return Error(e);
      }
      return Error(CacheFailure('Error al crear gallina: $e'));
    }
  }

  @override
  Future<Result<Gallina>> updateGallina(Gallina gallina) async {
    try {
      final model = GallinaModel.fromEntity(gallina);
      final updated = await dataSource.updateGallina(model);
      return Success(updated);
    } catch (e) {
      if (e is Failure) {
        return Error(e);
      }
      return Error(CacheFailure('Error al actualizar gallina: $e'));
    }
  }

  @override
  Future<Result<void>> deleteGallina(String id, String farmId) async {
    try {
      await dataSource.deleteGallina(id, farmId);
      return const Success(null);
    } catch (e) {
      return Error(CacheFailure('Error al eliminar gallina: $e'));
    }
  }

  @override
  Future<Result<List<Gallina>>> getGallinasByLote(String loteId, String farmId) async {
    try {
      final models = await dataSource.getGallinasByLote(loteId, farmId);
      return Success(models);
    } catch (e) {
      return Error(CacheFailure('Error al obtener gallinas por lote: $e'));
    }
  }

  @override
  Future<Result<List<Gallina>>> searchGallinas(String farmId, String query) async {
    try {
      final models = await dataSource.searchGallinas(farmId, query);
      return Success(models);
    } catch (e) {
      return Error(CacheFailure('Error al buscar gallinas: $e'));
    }
  }
}


