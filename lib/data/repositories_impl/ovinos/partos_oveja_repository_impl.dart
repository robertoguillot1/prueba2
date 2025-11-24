import '../../../core/utils/result.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/ovinos/parto_oveja.dart';
import '../../../domain/repositories/ovinos/partos_oveja_repository.dart';
import '../../datasources/ovinos/partos_oveja_datasource.dart';
import '../../models/ovinos/parto_oveja_model.dart';

/// Implementación del repositorio de Partos de Oveja
class PartosOvejaRepositoryImpl implements PartosOvejaRepository {
  final PartosOvejaDataSource dataSource;

  PartosOvejaRepositoryImpl(this.dataSource);

  @override
  Future<Result<List<PartoOveja>>> getAllPartos(String farmId) async {
    try {
      final models = await dataSource.getAllPartos(farmId);
      return Success(models);
    } catch (e) {
      return Error(CacheFailure('Error al obtener partos: $e'));
    }
  }

  @override
  Future<Result<PartoOveja>> getPartoById(String id, String farmId) async {
    try {
      final model = await dataSource.getPartoById(id, farmId);
      return Success(model);
    } catch (e) {
      if (e is CacheFailure) {
        return Error(e);
      }
      return Error(CacheFailure('Error al obtener parto: $e'));
    }
  }

  @override
  Future<Result<PartoOveja>> createParto(PartoOveja parto) async {
    try {
      final model = PartoOvejaModel.fromEntity(parto);
      final created = await dataSource.createParto(model);
      return Success(created);
    } catch (e) {
      if (e is Failure) {
        return Error(e);
      }
      return Error(CacheFailure('Error al crear parto: $e'));
    }
  }

  @override
  Future<Result<PartoOveja>> updateParto(PartoOveja parto) async {
    try {
      final model = PartoOvejaModel.fromEntity(parto);
      final updated = await dataSource.updateParto(model);
      return Success(updated);
    } catch (e) {
      if (e is Failure) {
        return Error(e);
      }
      return Error(CacheFailure('Error al actualizar parto: $e'));
    }
  }

  @override
  Future<Result<void>> deleteParto(String id, String farmId) async {
    try {
      await dataSource.deleteParto(id, farmId);
      return const Success(null);
    } catch (e) {
      return Error(CacheFailure('Error al eliminar parto: $e'));
    }
  }

  @override
  Future<Result<List<PartoOveja>>> getPartosByOveja(String ovejaId, String farmId) async {
    try {
      final models = await dataSource.getPartosByOveja(ovejaId, farmId);
      return Success(models);
    } catch (e) {
      return Error(CacheFailure('Error al obtener partos por oveja: $e'));
    }
  }

  @override
  Future<Result<List<PartoOveja>>> getPartosByFecha(String farmId, DateTime fechaInicio, DateTime fechaFin) async {
    try {
      final models = await dataSource.getPartosByFecha(farmId, fechaInicio, fechaFin);
      return Success(models);
    } catch (e) {
      return Error(CacheFailure('Error al obtener partos por fecha: $e'));
    }
  }
}



