import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/milk_production_entity.dart';
import '../../domain/repositories/milk_production_repository.dart';
import '../datasources/milk_production_remote_datasource.dart';
import '../models/milk_production_model.dart';

/// Implementación del repositorio de Producción de Leche
class MilkProductionRepositoryImpl implements MilkProductionRepository {
  final MilkProductionRemoteDataSource remoteDataSource;

  MilkProductionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<MilkProductionEntity>>> getProductionsByBovine(
    String bovineId,
    String farmId,
  ) async {
    try {
      final result =
          await remoteDataSource.getProductionsByBovine(bovineId, farmId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
          ServerFailure('Error inesperado al obtener producción de leche: $e'));
    }
  }

  @override
  Future<Either<Failure, List<MilkProductionEntity>>>
      getProductionsByDateRange(
    String farmId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final result = await remoteDataSource.getProductionsByDateRange(
        farmId,
        startDate,
        endDate,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(
          'Error inesperado al obtener producción por rango de fechas: $e'));
    }
  }

  @override
  Future<Either<Failure, MilkProductionEntity>> getProductionById(
    String id,
    String bovineId,
    String farmId,
  ) async {
    try {
      final production =
          await remoteDataSource.getProductionById(id, bovineId, farmId);
      return Right(production);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(
          'Error inesperado al obtener registro de producción: $e'));
    }
  }

  @override
  Future<Either<Failure, MilkProductionEntity>> addProduction(
      MilkProductionEntity production) async {
    try {
      final productionModel = MilkProductionModel.fromEntity(production);
      final createdProduction =
          await remoteDataSource.addProduction(productionModel);
      return Right(createdProduction);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
          ServerFailure('Error inesperado al crear registro de producción: $e'));
    }
  }

  @override
  Future<Either<Failure, MilkProductionEntity>> updateProduction(
      MilkProductionEntity production) async {
    try {
      final productionModel = MilkProductionModel.fromEntity(production);
      final updatedProduction =
          await remoteDataSource.updateProduction(productionModel);
      return Right(updatedProduction);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(
          'Error inesperado al actualizar registro de producción: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduction(
    String id,
    String bovineId,
    String farmId,
  ) async {
    try {
      await remoteDataSource.deleteProduction(id, bovineId, farmId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(
          'Error inesperado al eliminar registro de producción: $e'));
    }
  }
}



