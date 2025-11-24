import '../../../core/utils/result.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/porcinos/cerdo.dart';
import '../../../domain/repositories/porcinos/cerdos_repository.dart';
import '../../datasources/porcinos/cerdos_datasource.dart';
import '../../models/porcinos/cerdo_model.dart';

/// Implementación del repositorio de Cerdos
class CerdosRepositoryImpl implements CerdosRepository {
  final CerdosDataSource dataSource;

  CerdosRepositoryImpl(this.dataSource);

  @override
  Future<Result<List<Cerdo>>> getAllCerdos(String farmId) async {
    try {
      final models = await dataSource.getAllCerdos(farmId);
      return Success(models);
    } catch (e) {
      return Error(CacheFailure('Error al obtener cerdos: $e'));
    }
  }

  @override
  Future<Result<Cerdo>> getCerdoById(String id, String farmId) async {
    try {
      final model = await dataSource.getCerdoById(id, farmId);
      return Success(model);
    } catch (e) {
      if (e is CacheFailure) {
        return Error(e);
      }
      return Error(CacheFailure('Error al obtener cerdo: $e'));
    }
  }

  @override
  Future<Result<Cerdo>> createCerdo(Cerdo cerdo) async {
    try {
      final model = CerdoModel.fromEntity(cerdo);
      final created = await dataSource.createCerdo(model);
      return Success(created);
    } catch (e) {
      if (e is Failure) {
        return Error(e);
      }
      return Error(CacheFailure('Error al crear cerdo: $e'));
    }
  }

  @override
  Future<Result<Cerdo>> updateCerdo(Cerdo cerdo) async {
    try {
      final model = CerdoModel.fromEntity(cerdo);
      final updated = await dataSource.updateCerdo(model);
      return Success(updated);
    } catch (e) {
      if (e is Failure) {
        return Error(e);
      }
      return Error(CacheFailure('Error al actualizar cerdo: $e'));
    }
  }

  @override
  Future<Result<void>> deleteCerdo(String id, String farmId) async {
    try {
      await dataSource.deleteCerdo(id, farmId);
      return const Success(null);
    } catch (e) {
      return Error(CacheFailure('Error al eliminar cerdo: $e'));
    }
  }

  @override
  Future<Result<List<Cerdo>>> getCerdosByStage(String farmId, String stage) async {
    try {
      final models = await dataSource.getCerdosByStage(farmId, stage);
      return Success(models);
    } catch (e) {
      return Error(CacheFailure('Error al filtrar cerdos: $e'));
    }
  }

  @override
  Future<Result<List<Cerdo>>> searchCerdos(String farmId, String query) async {
    try {
      final models = await dataSource.searchCerdos(farmId, query);
      return Success(models);
    } catch (e) {
      return Error(CacheFailure('Error al buscar cerdos: $e'));
    }
  }
}



