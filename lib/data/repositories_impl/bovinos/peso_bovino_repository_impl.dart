import '../../../core/utils/result.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/bovinos/peso_bovino.dart';
import '../../../domain/repositories/bovinos/peso_bovino_repository.dart';
import '../../datasources/bovinos/peso_bovino_datasource.dart';
import '../../models/bovinos/peso_bovino_model.dart';

/// Implementación del repositorio de Peso de Bovino
class PesoBovinoRepositoryImpl implements PesoBovinoRepository {
  final PesoBovinoDataSource dataSource;

  PesoBovinoRepositoryImpl(this.dataSource);

  @override
  Future<Result<List<PesoBovino>>> getAllRegistros(String farmId) async {
    try {
      final models = await dataSource.getAllPesos(farmId);
      return Success(models);
    } catch (e) {
      return Error(CacheFailure('Error al obtener registros de peso: $e'));
    }
  }

  @override
  Future<Result<PesoBovino>> getRegistroById(String id, String farmId) async {
    try {
      final model = await dataSource.getPesoById(id, farmId);
      return Success(model);
    } catch (e) {
      if (e is CacheFailure) {
        return Error(e);
      }
      return Error(CacheFailure('Error al obtener registro de peso: $e'));
    }
  }

  @override
  Future<Result<PesoBovino>> createRegistro(PesoBovino registro) async {
    try {
      final model = PesoBovinoModel.fromEntity(registro);
      final created = await dataSource.createPeso(model);
      return Success(created);
    } catch (e) {
      if (e is Failure) {
        return Error(e);
      }
      return Error(CacheFailure('Error al crear registro de peso: $e'));
    }
  }

  @override
  Future<Result<PesoBovino>> updateRegistro(PesoBovino registro) async {
    try {
      final model = PesoBovinoModel.fromEntity(registro);
      final updated = await dataSource.updatePeso(model);
      return Success(updated);
    } catch (e) {
      if (e is Failure) {
        return Error(e);
      }
      return Error(CacheFailure('Error al actualizar registro de peso: $e'));
    }
  }

  @override
  Future<Result<void>> deleteRegistro(String id, String farmId) async {
    try {
      await dataSource.deletePeso(id, farmId);
      return const Success(null);
    } catch (e) {
      if (e is CacheFailure) {
        return Error(e);
      }
      return Error(CacheFailure('Error al eliminar registro de peso: $e'));
    }
  }

  @override
  Future<Result<List<PesoBovino>>> getRegistrosByBovino(String bovinoId, String farmId) async {
    try {
      final models = await dataSource.getPesosByBovino(bovinoId, farmId);
      return Success(models);
    } catch (e) {
      if (e is CacheFailure) {
        return Error(e);
      }
      return Error(CacheFailure('Error al obtener registros de peso del bovino: $e'));
    }
  }

  @override
  Future<Result<List<PesoBovino>>> getRegistrosByFecha(
    String farmId,
    DateTime fechaInicio,
    DateTime fechaFin,
  ) async {
    try {
      final allPesos = await dataSource.getAllPesos(farmId);
      final filtered = allPesos.where((peso) {
        return peso.recordDate.isAfter(fechaInicio.subtract(const Duration(days: 1))) &&
               peso.recordDate.isBefore(fechaFin.add(const Duration(days: 1)));
      }).toList();
      
      return Success(filtered);
    } catch (e) {
      if (e is CacheFailure) {
        return Error(e);
      }
      return Error(CacheFailure('Error al obtener registros por fecha: $e'));
    }
  }
}

