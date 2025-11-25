import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/bovine_entity.dart';
import '../../domain/repositories/cattle_repository.dart';
import '../datasources/cattle_remote_datasource.dart';
import '../models/bovine_model.dart';

/// Implementación del repositorio de Bovinos
class CattleRepositoryImpl implements CattleRepository {
  final CattleRemoteDataSource remoteDataSource;

  CattleRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<BovineEntity>>> getCattleList(String farmId) async {
    try {
      // Convertir el stream a una lista usando first
      final stream = remoteDataSource.getCattleList(farmId);
      final snapshot = await stream.first;
      return Right(snapshot);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado al obtener la lista de bovinos: $e'));
    }
  }

  /// Obtiene un stream de bovinos (método adicional para actualizaciones en tiempo real)
  Stream<List<BovineEntity>> getCattleListStream(String farmId) {
    try {
      return remoteDataSource.getCattleList(farmId);
    } catch (e) {
      throw ServerFailure('Error al obtener el stream de bovinos: $e');
    }
  }

  @override
  Future<Either<Failure, BovineEntity>> getBovine(String id) async {
    // El contrato del dominio solo proporciona id, pero necesitamos farmId
    // Por ahora retornamos un error informativo
    // En una implementación real, podrías buscar el bovino en todas las fincas
    // o tener un índice que mapee id -> farmId
    return Left(ServerFailure(
      'getBovine requiere farmId. Use getBovineById(farmId, id) o actualice el contrato del repositorio',
    ));
  }

  /// Método auxiliar para obtener un bovino con farmId
  Future<Either<Failure, BovineEntity>> getBovineById(String farmId, String id) async {
    try {
      final bovine = await remoteDataSource.getBovine(farmId, id);
      return Right(bovine);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado al obtener el bovino: $e'));
    }
  }

  @override
  Future<Either<Failure, BovineEntity>> addBovine(BovineEntity bovine) async {
    try {
      final bovineModel = BovineModel.fromEntity(bovine);
      final createdBovine = await remoteDataSource.addBovine(bovineModel);
      return Right(createdBovine);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado al agregar el bovino: $e'));
    }
  }

  @override
  Future<Either<Failure, BovineEntity>> updateBovine(BovineEntity bovine) async {
    try {
      final bovineModel = BovineModel.fromEntity(bovine);
      final updatedBovine = await remoteDataSource.updateBovine(bovineModel);
      return Right(updatedBovine);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado al actualizar el bovino: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBovine(String id) async {
    // El contrato del dominio solo proporciona id, pero necesitamos farmId
    // Por ahora retornamos un error informativo
    // En una implementación real, podrías buscar el bovino en todas las fincas
    // o tener un índice que mapee id -> farmId
    return Left(ServerFailure(
      'deleteBovine requiere farmId. Use deleteBovineById(farmId, id) o actualice el contrato del repositorio',
    ));
  }

  /// Método auxiliar para eliminar un bovino con farmId
  Future<Either<Failure, void>> deleteBovineById(String farmId, String id) async {
    try {
      await remoteDataSource.deleteBovine(farmId, id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado al eliminar el bovino: $e'));
    }
  }
}

