import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../data/sync/sync_manager.dart';
import '../../domain/entities/bovine_entity.dart';
import '../../domain/repositories/cattle_repository.dart';
import '../datasources/cattle_remote_datasource.dart';
import '../datasources/local/cattle_local_datasource.dart';
import '../models/bovine_model.dart';

/// Repositorio híbrido que alterna entre Firestore y base de datos local
class CattleHybridRepositoryImpl implements CattleRepository {
  final ConnectivityService _connectivityService;
  final CattleRemoteDataSource _remoteDataSource;
  final CattleLocalDataSource _localDataSource;
  final SyncManager _syncManager;

  CattleHybridRepositoryImpl({
    required ConnectivityService connectivityService,
    required CattleRemoteDataSource remoteDataSource,
    required CattleLocalDataSource localDataSource,
    required SyncManager syncManager,
  })  : _connectivityService = connectivityService,
        _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _syncManager = syncManager;

  @override
  Future<Either<Failure, List<BovineEntity>>> getCattleList(String farmId) async {
    // En modo web, solo usar remoto (SQLite no está disponible)
    if (kIsWeb) {
      try {
        final bovines = await _remoteDataSource.getCattleList(farmId);
        return Right(bovines);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure('Error al obtener bovinos: $e'));
      }
    }

    final hasConnection = await _connectivityService.hasConnection();

    if (hasConnection) {
      // Intentar obtener de Firestore
      try {
        final bovines = await _remoteDataSource.getCattleList(farmId);
        // Guardar en local para uso offline
        try {
          for (final bovine in bovines) {
            await _localDataSource.save(farmId, bovine);
          }
        } catch (_) {
          // Ignorar errores de SQLite en web (aunque ya verificamos kIsWeb arriba)
        }
        return Right(bovines);
      } on ServerException {
        // Si falla, intentar local
        return await _getCattleListFromLocal(farmId);
      } catch (_) {
        // Si falla, intentar local
        return await _getCattleListFromLocal(farmId);
      }
    }

    // Si no hay conexión, usar local
    return await _getCattleListFromLocal(farmId);
  }

  Future<Either<Failure, List<BovineEntity>>> _getCattleListFromLocal(String farmId) async {
    try {
      final result = await _localDataSource.fetchAll(farmId);
      if (result is Success<List<BovineModel>>) {
        return Right(result.data.cast<BovineEntity>().toList());
      } else if (result is Error<List<BovineModel>>) {
        return Left(CacheFailure(result.failure.message));
      } else {
        return Left(CacheFailure('Error desconocido al obtener bovinos'));
      }
    } catch (e) {
      // Si es error de SQLite en web, retornar lista vacía
      if (kIsWeb && e.toString().contains('SQLite')) {
        return const Right([]);
      }
      return Left(CacheFailure('Error al obtener bovinos: $e'));
    }
  }

  @override
  Stream<List<BovineEntity>> getCattleListStream(String farmId) {
    // Para streams, siempre usar Firestore
    return _remoteDataSource.getCattleListStream(farmId).asyncMap((bovines) async {
      // Guardar en local cada vez que se actualiza (solo si no es web)
      if (!kIsWeb) {
        try {
          for (final bovine in bovines) {
            await _localDataSource.save(farmId, bovine);
          }
        } catch (_) {
          // Ignorar errores de SQLite
        }
      }
      return bovines;
    }).handleError((error) {
      // Si hay error en el stream, intentar obtener de local (solo si no es web)
      if (kIsWeb) {
        return <BovineEntity>[];
      }
      return _localDataSource.fetchAll(farmId).then((result) {
        if (result is Success<List<BovineModel>>) {
          return result.data.cast<BovineEntity>().toList();
        } else {
          return <BovineEntity>[];
        }
      }).catchError((_) => <BovineEntity>[]);
    });
  }

  @override
  Future<Either<Failure, BovineEntity>> getBovine(String id) async {
    // Este método requiere farmId, pero el contrato solo tiene id
    // Retornar error informativo
    return Left(ServerFailure(
      'getBovine requiere farmId. Use getBovineById(farmId, id)',
    ));
  }

  /// Método auxiliar para obtener un bovino con farmId
  Future<Either<Failure, BovineEntity>> getBovineById(String farmId, String id) async {
    // En modo web, solo usar remoto
    if (kIsWeb) {
      try {
        final bovine = await _remoteDataSource.getBovine(farmId, id);
        return Right(bovine);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure('Error al obtener bovino: $e'));
      }
    }

    final hasConnection = await _connectivityService.hasConnection();

    if (hasConnection) {
      try {
        final bovine = await _remoteDataSource.getBovine(farmId, id);
        try {
          await _localDataSource.save(farmId, bovine);
        } catch (_) {
          // Ignorar errores de SQLite
        }
        return Right(bovine);
      } on ServerException {
        // Si falla, intentar local
        return await _getBovineFromLocal(farmId, id);
      } catch (_) {
        // Si falla, intentar local
        return await _getBovineFromLocal(farmId, id);
      }
    }

    // Si no hay conexión, usar local
    return await _getBovineFromLocal(farmId, id);
  }

  Future<Either<Failure, BovineEntity>> _getBovineFromLocal(String farmId, String id) async {
    try {
      final result = await _localDataSource.fetchById(farmId, id);
      if (result is Success<BovineModel>) {
        return Right(result.data);
      } else if (result is Error<BovineModel>) {
        return Left(CacheFailure(result.failure.message));
      } else {
        return Left(CacheFailure('Error desconocido al obtener bovino'));
      }
    } catch (e) {
      // Si es error de SQLite en web, retornar error
      if (kIsWeb && e.toString().contains('SQLite')) {
        return Left(CacheFailure('Bovino no encontrado en caché local'));
      }
      return Left(CacheFailure('Error al obtener bovino: $e'));
    }
  }

  @override
  Future<Either<Failure, BovineEntity>> addBovine(BovineEntity bovine) async {
    final bovineModel = BovineModel.fromEntity(bovine);

    // En modo web, solo usar remoto
    if (kIsWeb) {
      try {
        final created = await _remoteDataSource.addBovine(bovineModel);
        return Right(created);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure('Error al crear bovino: $e'));
      }
    }

    final hasConnection = await _connectivityService.hasConnection();

    if (hasConnection) {
      // Intentar crear en Firestore
      try {
        final created = await _remoteDataSource.addBovine(bovineModel);
        try {
          await _localDataSource.save(bovine.farmId, created);
        } catch (_) {
          // Ignorar errores de SQLite
        }
        return Right(created);
      } on ServerException {
        // Si falla, guardar localmente y añadir a cola de sincronización
        try {
          await _localDataSource.save(bovine.farmId, bovineModel);
          await _syncManager.addToSyncQueue(
            tableName: 'cattle',
            operation: 'CREATE',
            entityId: bovineModel.id,
            farmId: bovineModel.farmId,
            data: _bovineModelToMap(bovineModel),
          );
        } catch (_) {
          // Ignorar errores de SQLite
        }
        return Right(bovineModel);
      } catch (_) {
        // Si falla, guardar localmente y añadir a cola de sincronización
        try {
          await _localDataSource.save(bovine.farmId, bovineModel);
          await _syncManager.addToSyncQueue(
            tableName: 'cattle',
            operation: 'CREATE',
            entityId: bovineModel.id,
            farmId: bovineModel.farmId,
            data: _bovineModelToMap(bovineModel),
          );
        } catch (_) {
          // Ignorar errores de SQLite
        }
        return Right(bovineModel);
      }
    }

    // Guardar localmente y añadir a cola de sincronización
    try {
      await _localDataSource.save(bovine.farmId, bovineModel);
      await _syncManager.addToSyncQueue(
        tableName: 'cattle',
        operation: 'CREATE',
        entityId: bovineModel.id,
        farmId: bovineModel.farmId,
        data: bovineModel.toJson(),
      );
    } catch (e) {
      return Left(CacheFailure('Error al guardar bovino localmente: $e'));
    }

    return Right(bovineModel);
  }

  @override
  Future<Either<Failure, BovineEntity>> updateBovine(BovineEntity bovine) async {
    final bovineModel = BovineModel.fromEntity(bovine);

    // En modo web, solo usar remoto
    if (kIsWeb) {
      try {
        final updated = await _remoteDataSource.updateBovine(bovineModel);
        return Right(updated);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure('Error al actualizar bovino: $e'));
      }
    }

    final hasConnection = await _connectivityService.hasConnection();

    if (hasConnection) {
      // Intentar actualizar en Firestore
      try {
        final updated = await _remoteDataSource.updateBovine(bovineModel);
        try {
          await _localDataSource.save(bovine.farmId, updated);
        } catch (_) {
          // Ignorar errores de SQLite
        }
        return Right(updated);
      } on ServerException {
        // Si falla, guardar localmente y añadir a cola de sincronización
        try {
          await _localDataSource.save(bovine.farmId, bovineModel);
          await _syncManager.addToSyncQueue(
            tableName: 'cattle',
            operation: 'UPDATE',
            entityId: bovineModel.id,
            farmId: bovineModel.farmId,
            data: bovineModel.toJson(),
          );
        } catch (_) {
          // Ignorar errores de SQLite
        }
        return Right(bovineModel);
      } catch (e) {
        // Si falla, guardar localmente y añadir a cola de sincronización
        try {
          await _localDataSource.save(bovine.farmId, bovineModel);
          await _syncManager.addToSyncQueue(
            tableName: 'cattle',
            operation: 'UPDATE',
            entityId: bovineModel.id,
            farmId: bovineModel.farmId,
            data: bovineModel.toJson(),
          );
        } catch (_) {
          // Ignorar errores de SQLite
        }
        return Right(bovineModel);
      }
    }

    // Guardar localmente y añadir a cola de sincronización
    try {
      await _localDataSource.save(bovine.farmId, bovineModel);
      await _syncManager.addToSyncQueue(
        tableName: 'cattle',
        operation: 'UPDATE',
        entityId: bovineModel.id,
        farmId: bovineModel.farmId,
        data: bovineModel.toJson(),
      );
    } catch (e) {
      return Left(CacheFailure('Error al guardar bovino localmente: $e'));
    }

    return Right(bovineModel);
  }

  @override
  Future<Either<Failure, void>> deleteBovine(String id) async {
    // Este método requiere farmId, pero el contrato solo tiene id
    // Retornar error informativo
    return Left(ServerFailure(
      'deleteBovine requiere farmId. Use deleteBovineById(farmId, id)',
    ));
  }

  /// Método auxiliar para eliminar un bovino con farmId
  Future<Either<Failure, void>> deleteBovineById(String farmId, String id) async {
    // En modo web, solo usar remoto
    if (kIsWeb) {
      try {
        await _remoteDataSource.deleteBovine(farmId, id);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure('Error al eliminar bovino: $e'));
      }
    }

    final hasConnection = await _connectivityService.hasConnection();

    if (hasConnection) {
      try {
        await _remoteDataSource.deleteBovine(farmId, id);
        try {
          await _localDataSource.delete(farmId, id);
        } catch (_) {
          // Ignorar errores de SQLite
        }
        return const Right(null);
      } on ServerException {
        // Si falla, eliminar localmente y añadir a cola de sincronización
        try {
          await _localDataSource.delete(farmId, id);
          await _syncManager.addToSyncQueue(
            tableName: 'cattle',
            operation: 'DELETE',
            entityId: id,
            farmId: farmId,
            data: {'id': id},
          );
        } catch (_) {
          // Ignorar errores de SQLite
        }
        return const Right(null);
      } catch (_) {
        // Si falla, eliminar localmente y añadir a cola de sincronización
        try {
          await _localDataSource.delete(farmId, id);
          await _syncManager.addToSyncQueue(
            tableName: 'cattle',
            operation: 'DELETE',
            entityId: id,
            farmId: farmId,
            data: {'id': id},
          );
        } catch (_) {
          // Ignorar errores de SQLite
        }
        return const Right(null);
      }
    }

    // Eliminar localmente y añadir a cola de sincronización
    try {
      await _localDataSource.delete(farmId, id);
      await _syncManager.addToSyncQueue(
        tableName: 'cattle',
        operation: 'DELETE',
        entityId: id,
        farmId: farmId,
        data: {'id': id},
      );
    } catch (e) {
      return Left(CacheFailure('Error al eliminar bovino localmente: $e'));
    }

    return const Right(null);
  }

  /// Convierte BovineModel a Map para la cola de sincronización (sin Timestamps)
  Map<String, dynamic> _bovineModelToMap(BovineModel bovine) {
    return {
      'id': bovine.id,
      'farmId': bovine.farmId,
      'identifier': bovine.identifier,
      if (bovine.name != null) 'name': bovine.name,
      'breed': bovine.breed,
      'gender': _genderToString(bovine.gender),
      'birthDate': bovine.birthDate.toIso8601String(),
      'weight': bovine.weight,
      'purpose': _purposeToString(bovine.purpose),
      'status': _statusToString(bovine.status),
      'createdAt': bovine.createdAt.toIso8601String(),
      if (bovine.updatedAt != null) 'updatedAt': bovine.updatedAt!.toIso8601String(),
      if (bovine.motherId != null) 'motherId': bovine.motherId,
      if (bovine.fatherId != null) 'fatherId': bovine.fatherId,
      'previousCalvings': bovine.previousCalvings,
      'healthStatus': _healthStatusToString(bovine.healthStatus),
      'productionStage': _productionStageToString(bovine.productionStage),
      if (bovine.breedingStatus != null) 'breedingStatus': _breedingStatusToString(bovine.breedingStatus!),
      if (bovine.lastHeatDate != null) 'lastHeatDate': bovine.lastHeatDate!.toIso8601String(),
      if (bovine.inseminationDate != null) 'inseminationDate': bovine.inseminationDate!.toIso8601String(),
      if (bovine.expectedCalvingDate != null) 'expectedCalvingDate': bovine.expectedCalvingDate!.toIso8601String(),
      if (bovine.notes != null) 'notes': bovine.notes,
    };
  }

  // Helpers para convertir enums a String
  String _genderToString(BovineGender gender) {
    switch (gender) {
      case BovineGender.male:
        return 'male';
      case BovineGender.female:
        return 'female';
    }
  }

  String _purposeToString(BovinePurpose purpose) {
    switch (purpose) {
      case BovinePurpose.meat:
        return 'meat';
      case BovinePurpose.milk:
        return 'milk';
      case BovinePurpose.dual:
        return 'dual';
    }
  }

  String _statusToString(BovineStatus status) {
    switch (status) {
      case BovineStatus.active:
        return 'active';
      case BovineStatus.sold:
        return 'sold';
      case BovineStatus.dead:
        return 'dead';
    }
  }

  String _healthStatusToString(HealthStatus healthStatus) {
    switch (healthStatus) {
      case HealthStatus.healthy:
        return 'healthy';
      case HealthStatus.sick:
        return 'sick';
      case HealthStatus.underTreatment:
        return 'undertreatment';
      case HealthStatus.recovering:
        return 'recovering';
    }
  }

  String _productionStageToString(ProductionStage productionStage) {
    switch (productionStage) {
      case ProductionStage.raising:
        return 'raising';
      case ProductionStage.productive:
        return 'productive';
      case ProductionStage.dry:
        return 'dry';
    }
  }

  String _breedingStatusToString(BreedingStatus breedingStatus) {
    switch (breedingStatus) {
      case BreedingStatus.notSpecified:
        return 'notSpecified';
      case BreedingStatus.pregnant:
        return 'pregnant';
      case BreedingStatus.inseminated:
        return 'inseminated';
      case BreedingStatus.empty:
        return 'empty';
      case BreedingStatus.served:
        return 'served';
    }
  }
}

