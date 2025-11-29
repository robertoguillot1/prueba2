import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/transfer_entity.dart';
import '../../domain/repositories/transfer_repository.dart';
import '../datasources/transfer_remote_datasource.dart';
import '../models/transfer_model.dart';

class TransferRepositoryImpl implements TransferRepository {
  final TransferRemoteDataSource remoteDataSource;

  TransferRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<TransferEntity>>> getTransfersByBovine(
    String bovineId,
    String farmId,
  ) async {
    try {
      final result = await remoteDataSource.getTransfersByBovine(bovineId, farmId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado al obtener transferencias: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TransferEntity>>> getTransfersByFarm(String farmId) async {
    try {
      final result = await remoteDataSource.getTransfersByFarm(farmId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado al obtener transferencias de la finca: $e'));
    }
  }

  @override
  Future<Either<Failure, TransferEntity>> getTransferById(
    String id,
    String bovineId,
    String farmId,
  ) async {
    try {
      final result = await remoteDataSource.getTransferById(id, bovineId, farmId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado al obtener transferencia: $e'));
    }
  }

  @override
  Future<Either<Failure, TransferEntity>> addTransfer(TransferEntity transfer) async {
    try {
      final model = TransferModel.fromEntity(transfer);
      final result = await remoteDataSource.addTransfer(model);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado al agregar transferencia: $e'));
    }
  }

  @override
  Future<Either<Failure, TransferEntity>> updateTransfer(TransferEntity transfer) async {
    try {
      final model = TransferModel.fromEntity(transfer);
      final result = await remoteDataSource.updateTransfer(model);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado al actualizar transferencia: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransfer(
    String id,
    String bovineId,
    String farmId,
  ) async {
    try {
      await remoteDataSource.deleteTransfer(id, bovineId, farmId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado al eliminar transferencia: $e'));
    }
  }
}

