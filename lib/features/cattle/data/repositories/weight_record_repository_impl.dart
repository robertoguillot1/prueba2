import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/weight_record_entity.dart';
import '../../domain/repositories/weight_record_repository.dart';
import '../datasources/weight_record_remote_datasource.dart';
import '../models/weight_record_model.dart';

/// Implementación del repositorio de Registros de Peso
class WeightRecordRepositoryImpl implements WeightRecordRepository {
  final WeightRecordRemoteDataSource remoteDataSource;

  WeightRecordRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<WeightRecordEntity>>> getRecordsByBovine(
    String bovineId,
    String farmId,
  ) async {
    try {
      final result = await remoteDataSource.getRecordsByBovine(bovineId, farmId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
          ServerFailure('Error inesperado al obtener registros de peso: $e'));
    }
  }

  @override
  Future<Either<Failure, WeightRecordEntity>> getRecordById(
    String id,
    String bovineId,
    String farmId,
  ) async {
    try {
      final record = await remoteDataSource.getRecordById(id, bovineId, farmId);
      return Right(record);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
          ServerFailure('Error inesperado al obtener registro de peso: $e'));
    }
  }

  @override
  Future<Either<Failure, WeightRecordEntity>> addRecord(
      WeightRecordEntity record) async {
    try {
      final recordModel = WeightRecordModel.fromEntity(record);
      final createdRecord = await remoteDataSource.addRecord(recordModel);
      return Right(createdRecord);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
          ServerFailure('Error inesperado al crear registro de peso: $e'));
    }
  }

  @override
  Future<Either<Failure, WeightRecordEntity>> updateRecord(
      WeightRecordEntity record) async {
    try {
      final recordModel = WeightRecordModel.fromEntity(record);
      final updatedRecord = await remoteDataSource.updateRecord(recordModel);
      return Right(updatedRecord);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
          ServerFailure('Error inesperado al actualizar registro de peso: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRecord(
    String id,
    String bovineId,
    String farmId,
  ) async {
    try {
      await remoteDataSource.deleteRecord(id, bovineId, farmId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
          ServerFailure('Error inesperado al eliminar registro de peso: $e'));
    }
  }
}

