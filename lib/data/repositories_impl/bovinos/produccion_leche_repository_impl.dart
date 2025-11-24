import '../../../core/utils/result.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/bovinos/produccion_leche.dart';
import '../../../domain/repositories/bovinos/produccion_leche_repository.dart';
import '../../datasources/bovinos/produccion_leche_datasource.dart';
import '../../models/bovinos/produccion_leche_model.dart';

/// Implementación del repositorio de Producción de Leche
class ProduccionLecheRepositoryImpl implements ProduccionLecheRepository {
  final ProduccionLecheDataSource dataSource;

  ProduccionLecheRepositoryImpl(this.dataSource);

  @override
  Future<Result<List<ProduccionLeche>>> getAllProducciones(String farmId) async {
    try {
      final models = await dataSource.getAllProducciones(farmId);
      return Success(models);
    } catch (e) {
      return Error(CacheFailure('Error al obtener producciones: $e'));
    }
  }

  @override
  Future<Result<ProduccionLeche>> getProduccionById(String id, String farmId) async {
    try {
      final model = await dataSource.getProduccionById(id, farmId);
      return Success(model);
    } catch (e) {
      if (e is CacheFailure) {
        return Error(e);
      }
      return Error(CacheFailure('Error al obtener producción: $e'));
    }
  }

  @override
  Future<Result<ProduccionLeche>> createProduccion(ProduccionLeche produccion) async {
    try {
      final model = ProduccionLecheModel.fromEntity(produccion);
      final created = await dataSource.createProduccion(model);
      return Success(created);
    } catch (e) {
      if (e is Failure) {
        return Error(e);
      }
      return Error(CacheFailure('Error al crear producción: $e'));
    }
  }

  @override
  Future<Result<ProduccionLeche>> updateProduccion(ProduccionLeche produccion) async {
    try {
      final model = ProduccionLecheModel.fromEntity(produccion);
      final updated = await dataSource.updateProduccion(model);
      return Success(updated);
    } catch (e) {
      if (e is Failure) {
        return Error(e);
      }
      return Error(CacheFailure('Error al actualizar producción: $e'));
    }
  }

  @override
  Future<Result<void>> deleteProduccion(String id, String farmId) async {
    try {
      await dataSource.deleteProduccion(id, farmId);
      return const Success(null);
    } catch (e) {
      return Error(CacheFailure('Error al eliminar producción: $e'));
    }
  }

  @override
  Future<Result<List<ProduccionLeche>>> getProduccionesByBovino(String bovinoId, String farmId) async {
    try {
      final models = await dataSource.getProduccionesByBovino(bovinoId, farmId);
      return Success(models);
    } catch (e) {
      return Error(CacheFailure('Error al obtener producciones por bovino: $e'));
    }
  }

  @override
  Future<Result<List<ProduccionLeche>>> getProduccionesByFecha(String farmId, DateTime fechaInicio, DateTime fechaFin) async {
    try {
      final models = await dataSource.getProduccionesByFecha(farmId, fechaInicio, fechaFin);
      return Success(models);
    } catch (e) {
      return Error(CacheFailure('Error al obtener producciones por fecha: $e'));
    }
  }
}



