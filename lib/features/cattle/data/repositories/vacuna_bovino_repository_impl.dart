import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/vacuna_bovino_entity.dart';
import '../../domain/repositories/vacuna_bovino_repository.dart';
import '../datasources/vacuna_bovino_remote_datasource.dart';
import '../models/vacuna_bovino_model.dart';

/// Implementación del repositorio de vacunas usando el datasource remoto
class VacunaBovinoRepositoryImpl implements VacunaBovinoRepository {
  final VacunaBovinoRemoteDataSource remoteDataSource;

  VacunaBovinoRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<List<VacunaBovinoEntity>>> getVacunasByBovino(
    String bovinoId,
    String farmId,
  ) async {
    try {
      final models = await remoteDataSource.getVacunasByBovino(bovinoId, farmId);
      return Success(models);
    } catch (e) {
      if (e is Failure) {
        return Error(e);
      }
      return Error(ServerFailure('Error al obtener vacunas: $e'));
    }
  }

  @override
  Future<Result<VacunaBovinoEntity>> getVacunaById(
    String id,
    String bovinoId,
    String farmId,
  ) async {
    try {
      final model = await remoteDataSource.getVacunaById(id, bovinoId, farmId);
      return Success(model);
    } catch (e) {
      if (e is Failure) {
        return Error(e);
      }
      return Error(ServerFailure('Error al obtener vacuna: $e'));
    }
  }

  @override
  Future<Result<VacunaBovinoEntity>> addVacuna(VacunaBovinoEntity vacuna) async {
    try {
      final model = VacunaBovinoModel.fromEntity(vacuna);
      final created = await remoteDataSource.addVacuna(model);
      return Success(created);
    } catch (e) {
      if (e is Failure) {
        return Error(e);
      }
      return Error(ServerFailure('Error al crear vacuna: $e'));
    }
  }

  @override
  Future<Result<VacunaBovinoEntity>> updateVacuna(
    VacunaBovinoEntity vacuna,
  ) async {
    try {
      final model = VacunaBovinoModel.fromEntity(vacuna);
      final updated = await remoteDataSource.updateVacuna(model);
      return Success(updated);
    } catch (e) {
      if (e is Failure) {
        return Error(e);
      }
      return Error(ServerFailure('Error al actualizar vacuna: $e'));
    }
  }

  @override
  Future<Result<void>> deleteVacuna(
    String id,
    String bovinoId,
    String farmId,
  ) async {
    try {
      await remoteDataSource.deleteVacuna(id, bovinoId, farmId);
      return const Success(null);
    } catch (e) {
      if (e is Failure) {
        return Error(e);
      }
      return Error(ServerFailure('Error al eliminar vacuna: $e'));
    }
  }

  @override
  Future<Result<List<VacunaBovinoEntity>>> getVacunasConRefuerzoPendiente(
    String farmId,
  ) async {
    try {
      final models = await remoteDataSource.getVacunasConRefuerzoPendiente(farmId);
      return Success(models);
    } catch (e) {
      if (e is Failure) {
        return Error(e);
      }
      return Error(ServerFailure('Error al obtener vacunas con refuerzo pendiente: $e'));
    }
  }
}

