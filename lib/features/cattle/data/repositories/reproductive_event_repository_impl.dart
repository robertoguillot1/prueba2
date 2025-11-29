import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/reproductive_event_entity.dart';
import '../../domain/repositories/reproductive_event_repository.dart';
import '../datasources/reproductive_event_remote_datasource.dart';
import '../models/reproductive_event_model.dart';

/// Implementación del repositorio de Eventos Reproductivos
class ReproductiveEventRepositoryImpl
    implements ReproductiveEventRepository {
  final ReproductiveEventRemoteDataSource remoteDataSource;

  ReproductiveEventRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ReproductiveEventEntity>>>
      getEventsByBovine(String bovineId, String farmId) async {
    try {
      final result = await remoteDataSource.getEventsByBovine(bovineId, farmId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(
          'Error inesperado al obtener eventos reproductivos: $e'));
    }
  }

  @override
  Future<Either<Failure, ReproductiveEventEntity>> getEventById(
    String id,
    String bovineId,
    String farmId,
  ) async {
    try {
      final event = await remoteDataSource.getEventById(id, bovineId, farmId);
      return Right(event);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
          ServerFailure('Error inesperado al obtener evento reproductivo: $e'));
    }
  }

  @override
  Future<Either<Failure, ReproductiveEventEntity>> addEvent(
      ReproductiveEventEntity event) async {
    try {
      final eventModel = ReproductiveEventModel.fromEntity(event);
      final createdEvent = await remoteDataSource.addEvent(eventModel);
      return Right(createdEvent);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
          ServerFailure('Error inesperado al crear evento reproductivo: $e'));
    }
  }

  @override
  Future<Either<Failure, ReproductiveEventEntity>> updateEvent(
      ReproductiveEventEntity event) async {
    try {
      final eventModel = ReproductiveEventModel.fromEntity(event);
      final updatedEvent = await remoteDataSource.updateEvent(eventModel);
      return Right(updatedEvent);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(
          'Error inesperado al actualizar evento reproductivo: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteEvent(
    String id,
    String bovineId,
    String farmId,
  ) async {
    try {
      await remoteDataSource.deleteEvent(id, bovineId, farmId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
          ServerFailure('Error inesperado al eliminar evento reproductivo: $e'));
    }
  }
}

