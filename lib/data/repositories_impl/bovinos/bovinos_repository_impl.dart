import '../../../core/utils/result.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/bovinos/bovino.dart';
import '../../../domain/repositories/bovinos/bovinos_repository.dart';
import '../../datasources/bovinos/bovinos_datasource.dart';
import '../../models/bovinos/bovino_model.dart';

/// Implementación del repositorio de Bovinos
class BovinosRepositoryImpl implements BovinosRepository {
  final BovinosDataSource dataSource;

  BovinosRepositoryImpl(this.dataSource);

  @override
  Future<Result<List<Bovino>>> getAllBovinos(String farmId) async {
    try {
      final models = await dataSource.getAllBovinos(farmId);
      return Success(models.cast<Bovino>().toList());
    } catch (e) {
      return Error(CacheFailure('Error al obtener bovinos: $e'));
    }
  }

  @override
  Future<Result<Bovino>> getBovinoById(String id, String farmId) async {
    try {
      final model = await dataSource.getBovinoById(id, farmId);
      return Success(model as Bovino);
    } catch (e) {
      if (e is CacheFailure) {
        return Error(e);
      }
      return Error(CacheFailure('Error al obtener bovino: $e'));
    }
  }

  @override
  Future<Result<Bovino>> createBovino(Bovino bovino) async {
    try {
      final model = BovinoModel.fromEntity(bovino);
      final created = await dataSource.createBovino(model);
      return Success(created as Bovino);
    } catch (e) {
      if (e is Failure) {
        return Error(e);
      }
      return Error(CacheFailure('Error al crear bovino: $e'));
    }
  }

  @override
  Future<Result<Bovino>> updateBovino(Bovino bovino) async {
    try {
      final model = BovinoModel.fromEntity(bovino);
      final updated = await dataSource.updateBovino(model);
      return Success(updated as Bovino);
    } catch (e) {
      if (e is Failure) {
        return Error(e);
      }
      return Error(CacheFailure('Error al actualizar bovino: $e'));
    }
  }

  @override
  Future<Result<void>> deleteBovino(String id, String farmId) async {
    try {
      await dataSource.deleteBovino(id, farmId);
      return const Success(null);
    } catch (e) {
      return Error(CacheFailure('Error al eliminar bovino: $e'));
    }
  }

  @override
  Future<Result<List<Bovino>>> getBovinosByCategory(String farmId, String category) async {
    try {
      final models = await dataSource.getBovinosByCategory(farmId, category);
      return Success(models.cast<Bovino>().toList());
    } catch (e) {
      return Error(CacheFailure('Error al filtrar bovinos: $e'));
    }
  }

  @override
  Future<Result<List<Bovino>>> searchBovinos(String farmId, String query) async {
    try {
      final models = await dataSource.searchBovinos(farmId, query);
      return Success(models.cast<Bovino>().toList());
    } catch (e) {
      return Error(CacheFailure('Error al buscar bovinos: $e'));
    }
  }
}

