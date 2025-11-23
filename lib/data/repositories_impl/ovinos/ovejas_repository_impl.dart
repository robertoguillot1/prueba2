import '../../../core/utils/result.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/ovinos/oveja.dart';
import '../../../domain/repositories/ovinos/ovejas_repository.dart';
import '../../datasources/ovinos/ovejas_datasource.dart';
import '../../models/ovinos/oveja_model.dart';

/// Implementación del repositorio de Ovejas
class OvejasRepositoryImpl implements OvejasRepository {
  final OvejasDataSource dataSource;

  OvejasRepositoryImpl(this.dataSource);

  @override
  Future<Result<List<Oveja>>> getAllOvejas(String farmId) async {
    try {
      final models = await dataSource.getAllOvejas(farmId);
      return Success(models.cast<Oveja>().toList());
    } catch (e) {
      return Error(CacheFailure('Error al obtener ovejas: $e'));
    }
  }

  @override
  Future<Result<Oveja>> getOvejaById(String id, String farmId) async {
    try {
      final model = await dataSource.getOvejaById(id, farmId);
      return Success(model as Oveja);
    } catch (e) {
      if (e is CacheFailure) {
        return Error(e);
      }
      return Error(CacheFailure('Error al obtener oveja: $e'));
    }
  }

  @override
  Future<Result<Oveja>> createOveja(Oveja oveja) async {
    try {
      final model = OvejaModel.fromEntity(oveja);
      final created = await dataSource.createOveja(model);
      return Success(created as Oveja);
    } catch (e) {
      if (e is Failure) {
        return Error(e);
      }
      return Error(CacheFailure('Error al crear oveja: $e'));
    }
  }

  @override
  Future<Result<Oveja>> updateOveja(Oveja oveja) async {
    try {
      final model = OvejaModel.fromEntity(oveja);
      final updated = await dataSource.updateOveja(model);
      return Success(updated as Oveja);
    } catch (e) {
      if (e is Failure) {
        return Error(e);
      }
      return Error(CacheFailure('Error al actualizar oveja: $e'));
    }
  }

  @override
  Future<Result<void>> deleteOveja(String id, String farmId) async {
    try {
      await dataSource.deleteOveja(id, farmId);
      return const Success(null);
    } catch (e) {
      return Error(CacheFailure('Error al eliminar oveja: $e'));
    }
  }

  @override
  Future<Result<List<Oveja>>> getOvejasByEstadoReproductivo(
    String farmId,
    EstadoReproductivoOveja estado,
  ) async {
    try {
      final models = await dataSource.getOvejasByEstadoReproductivo(
        farmId,
        estado.name,
      );
      return Success(models.cast<Oveja>().toList());
    } catch (e) {
      return Error(CacheFailure('Error al filtrar ovejas: $e'));
    }
  }

  @override
  Future<Result<List<Oveja>>> searchOvejas(String farmId, String query) async {
    try {
      final models = await dataSource.searchOvejas(farmId, query);
      return Success(models.cast<Oveja>().toList());
    } catch (e) {
      return Error(CacheFailure('Error al buscar ovejas: $e'));
    }
  }
}

