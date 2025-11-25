import '../../../core/utils/result.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/trabajadores/trabajador.dart';
import '../../../domain/repositories/trabajadores/trabajadores_repository.dart';
import '../../datasources/trabajadores/trabajadores_datasource.dart';
import '../../models/trabajadores/trabajador_model.dart';

/// Implementación del repositorio de Trabajadores
class TrabajadoresRepositoryImpl implements TrabajadoresRepository {
  final TrabajadoresDataSource dataSource;

  TrabajadoresRepositoryImpl(this.dataSource);

  @override
  Future<Result<List<Trabajador>>> getAllTrabajadores(String farmId) async {
    try {
      final models = await dataSource.getAllTrabajadores(farmId);
      return Success(models);
    } catch (e) {
      return Error(CacheFailure('Error al obtener trabajadores: $e'));
    }
  }

  @override
  Future<Result<Trabajador>> getTrabajadorById(String id, String farmId) async {
    try {
      final model = await dataSource.getTrabajadorById(id, farmId);
      return Success(model);
    } catch (e) {
      if (e is CacheFailure) {
        return Error(e);
      }
      return Error(CacheFailure('Error al obtener trabajador: $e'));
    }
  }

  @override
  Future<Result<Trabajador>> createTrabajador(Trabajador trabajador) async {
    try {
      final model = TrabajadorModel.fromEntity(trabajador);
      final created = await dataSource.createTrabajador(model);
      return Success(created);
    } catch (e) {
      if (e is Failure) {
        return Error(e);
      }
      return Error(CacheFailure('Error al crear trabajador: $e'));
    }
  }

  @override
  Future<Result<Trabajador>> updateTrabajador(Trabajador trabajador) async {
    try {
      final model = TrabajadorModel.fromEntity(trabajador);
      final updated = await dataSource.updateTrabajador(model);
      return Success(updated);
    } catch (e) {
      if (e is Failure) {
        return Error(e);
      }
      return Error(CacheFailure('Error al actualizar trabajador: $e'));
    }
  }

  @override
  Future<Result<void>> deleteTrabajador(String id, String farmId) async {
    try {
      await dataSource.deleteTrabajador(id, farmId);
      return const Success(null);
    } catch (e) {
      return Error(CacheFailure('Error al eliminar trabajador: $e'));
    }
  }

  @override
  Future<Result<List<Trabajador>>> getTrabajadoresActivos(String farmId) async {
    try {
      final models = await dataSource.getTrabajadoresActivos(farmId);
      return Success(models);
    } catch (e) {
      return Error(CacheFailure('Error al obtener trabajadores activos: $e'));
    }
  }

  @override
  Future<Result<List<Trabajador>>> searchTrabajadores(String farmId, String query) async {
    try {
      final models = await dataSource.searchTrabajadores(farmId, query);
      return Success(models);
    } catch (e) {
      return Error(CacheFailure('Error al buscar trabajadores: $e'));
    }
  }
}

