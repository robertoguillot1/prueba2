import 'package:flutter/foundation.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../domain/entities/ovinos/oveja.dart';
import '../../../../domain/repositories/ovinos/ovejas_repository.dart';
import '../../../datasources/remote/ovinos/ovinos_remote_datasource.dart';
import '../../../datasources/local/ovinos/ovinos_local_datasource.dart';
import '../../../models/ovinos/oveja_model.dart';
import '../../../sync/sync_manager.dart';

/// Repositorio híbrido que alterna entre API y base de datos local
class OvinosHybridRepository implements OvejasRepository {
  final ConnectivityService _connectivityService;
  final OvinosRemoteDataSource _remoteDataSource;
  final OvinosLocalDataSource _localDataSource;
  final SyncManager _syncManager;

  OvinosHybridRepository({
    required ConnectivityService connectivityService,
    required OvinosRemoteDataSource remoteDataSource,
    required OvinosLocalDataSource localDataSource,
    required SyncManager syncManager,
  })  : _connectivityService = connectivityService,
        _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _syncManager = syncManager;

  @override
  Future<Result<List<Oveja>>> getAllOvejas(String farmId) async {
    // En modo web, solo usar remoto (SQLite no está disponible)
    if (kIsWeb) {
      final result = await _remoteDataSource.fetchAll(farmId);
      if (result.isSuccess) {
        return Success((result as Success<List<OvejaModel>>).data.cast<Oveja>().toList());
      }
      return result.map((models) => models.cast<Oveja>().toList());
    }

    final hasConnection = await _connectivityService.hasConnection();
    
    if (hasConnection) {
      // Intentar obtener de la API
      final result = await _remoteDataSource.fetchAll(farmId);
      if (result.isSuccess) {
        // Guardar en local para uso offline
        final models = (result as Success<List<OvejaModel>>).data;
        try {
          for (final model in models) {
            await _localDataSource.save(farmId, model);
          }
        } catch (_) {
          // Ignorar errores de SQLite
        }
        return Success(models.cast<Oveja>().toList());
      }
    }
    
    // Si no hay conexión o falló, usar local
    try {
      final localResult = await _localDataSource.fetchAll(farmId);
      return localResult.map((models) => models.cast<Oveja>().toList());
    } catch (e) {
      if (e.toString().contains('SQLite')) {
        return const Success([]);
      }
      return Error(CacheFailure('Error al obtener ovejas: $e'));
    }
  }

  @override
  Future<Result<Oveja>> getOvejaById(String id, String farmId) async {
    // En modo web, solo usar remoto
    if (kIsWeb) {
      final result = await _remoteDataSource.fetchById(farmId, id);
      return result.map((model) => model as Oveja);
    }

    final hasConnection = await _connectivityService.hasConnection();
    
    if (hasConnection) {
      final result = await _remoteDataSource.fetchById(farmId, id);
      if (result.isSuccess) {
        final model = (result as Success<OvejaModel>).data;
        try {
          await _localDataSource.save(farmId, model);
        } catch (_) {
          // Ignorar errores de SQLite
        }
        return Success(model);
      }
    }
    
    try {
      final localResult = await _localDataSource.fetchById(farmId, id);
      return localResult.map((model) => model as Oveja);
    } catch (e) {
      if (e.toString().contains('SQLite')) {
        return Error(NotFoundFailure('Oveja no encontrada en caché local'));
      }
      return Error(CacheFailure('Error al obtener oveja: $e'));
    }
  }

  @override
  Future<Result<Oveja>> createOveja(Oveja oveja) async {
    final model = OvejaModel.fromEntity(oveja);

    // En modo web, solo usar remoto
    if (kIsWeb) {
      final result = await _remoteDataSource.create(oveja.farmId, model);
      return result.map((created) => created as Oveja);
    }

    final hasConnection = await _connectivityService.hasConnection();
    
    if (hasConnection) {
      // Intentar crear en la API
      final result = await _remoteDataSource.create(oveja.farmId, model);
      if (result.isSuccess) {
        final created = (result as Success<OvejaModel>).data;
        try {
          await _localDataSource.save(oveja.farmId, created);
        } catch (_) {
          // Ignorar errores de SQLite
        }
        return Success(created);
      }
    }
    
    // Guardar localmente y añadir a cola de sincronización
    try {
      await _localDataSource.save(oveja.farmId, model);
      await _syncManager.addToSyncQueue(
        tableName: 'ovinos',
        operation: 'CREATE',
        entityId: model.id,
        farmId: model.farmId,
        data: model.toJson(),
      );
    } catch (e) {
      return Error(CacheFailure('Error al guardar oveja localmente: $e'));
    }
    
    return Success(model);
  }

  @override
  Future<Result<Oveja>> updateOveja(Oveja oveja) async {
    final model = OvejaModel.fromEntity(oveja);

    // En modo web, solo usar remoto
    if (kIsWeb) {
      final result = await _remoteDataSource.update(oveja.farmId, model);
      return result.map((updated) => updated as Oveja);
    }

    final hasConnection = await _connectivityService.hasConnection();
    
    if (hasConnection) {
      final result = await _remoteDataSource.update(oveja.farmId, model);
      if (result.isSuccess) {
        final updated = (result as Success<OvejaModel>).data;
        try {
          await _localDataSource.save(oveja.farmId, updated);
        } catch (_) {
          // Ignorar errores de SQLite
        }
        return Success(updated);
      }
    }
    
    // Guardar localmente y añadir a cola de sincronización
    try {
      await _localDataSource.save(oveja.farmId, model);
      await _syncManager.addToSyncQueue(
        tableName: 'ovinos',
        operation: 'UPDATE',
        entityId: model.id,
        farmId: model.farmId,
        data: model.toJson(),
      );
    } catch (e) {
      return Error(CacheFailure('Error al guardar oveja localmente: $e'));
    }
    
    return Success(model);
  }

  @override
  Future<Result<void>> deleteOveja(String id, String farmId) async {
    // En modo web, solo usar remoto
    if (kIsWeb) {
      final result = await _remoteDataSource.delete(farmId, id);
      return result;
    }

    final hasConnection = await _connectivityService.hasConnection();
    
    if (hasConnection) {
      final result = await _remoteDataSource.delete(farmId, id);
      if (result.isSuccess) {
        try {
          await _localDataSource.delete(farmId, id);
        } catch (_) {
          // Ignorar errores de SQLite
        }
        return const Success(null);
      }
    }
    
    // Eliminar localmente y añadir a cola de sincronización
    try {
      await _localDataSource.delete(farmId, id);
      await _syncManager.addToSyncQueue(
        tableName: 'ovinos',
        operation: 'DELETE',
        entityId: id,
        farmId: farmId,
        data: {'id': id},
      );
    } catch (e) {
      return Error(CacheFailure('Error al eliminar oveja localmente: $e'));
    }
    
    return const Success(null);
  }

  @override
  Future<Result<List<Oveja>>> getOvejasByEstadoReproductivo(
    String farmId,
    dynamic estado,
  ) async {
    // Implementación simplificada: obtener todas y filtrar
    final result = await getAllOvejas(farmId);
    return result.map((ovejas) {
      return ovejas.where((o) {
        if (estado is String) {
          return o.estadoReproductivo?.name == estado;
        }
        return o.estadoReproductivo == estado;
      }).toList();
    });
  }

  @override
  Future<Result<List<Oveja>>> searchOvejas(String farmId, String query) async {
    // En modo web, solo usar remoto
    if (kIsWeb) {
      final result = await _remoteDataSource.search(farmId, query);
      return result.map((models) => models.cast<Oveja>().toList());
    }

    final hasConnection = await _connectivityService.hasConnection();
    
    if (hasConnection) {
      final result = await _remoteDataSource.search(farmId, query);
      if (result.isSuccess) {
        final models = (result as Success<List<OvejaModel>>).data;
        return Success(models.cast<Oveja>().toList());
      }
    }
    
    try {
      final localResult = await _localDataSource.search(farmId, query);
      return localResult.map((models) => models.cast<Oveja>().toList());
    } catch (e) {
      if (e.toString().contains('SQLite')) {
        return const Success([]);
      }
      return Error(CacheFailure('Error al buscar ovejas: $e'));
    }
  }
}

