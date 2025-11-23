import '../../../../core/network/connectivity_service.dart';
import '../../../../core/utils/result.dart';
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
    final hasConnection = await _connectivityService.hasConnection();
    
    if (hasConnection) {
      // Intentar obtener de la API
      final result = await _remoteDataSource.fetchAll(farmId);
      if (result.isSuccess) {
        // Guardar en local para uso offline
        final models = (result as Success<List<OvejaModel>>).data;
        for (final model in models) {
          await _localDataSource.save(farmId, model);
        }
        return Success(models.cast<Oveja>().toList());
      }
    }
    
    // Si no hay conexión o falló, usar local
    final localResult = await _localDataSource.fetchAll(farmId);
    return localResult.map((models) => models.cast<Oveja>().toList());
  }

  @override
  Future<Result<Oveja>> getOvejaById(String id, String farmId) async {
    final hasConnection = await _connectivityService.hasConnection();
    
    if (hasConnection) {
      final result = await _remoteDataSource.fetchById(farmId, id);
      if (result.isSuccess) {
        final model = (result as Success<OvejaModel>).data;
        await _localDataSource.save(farmId, model);
        return Success(model);
      }
    }
    
    final localResult = await _localDataSource.fetchById(farmId, id);
    return localResult.map((model) => model as Oveja);
  }

  @override
  Future<Result<Oveja>> createOveja(Oveja oveja) async {
    final model = OvejaModel.fromEntity(oveja);
    final hasConnection = await _connectivityService.hasConnection();
    
    if (hasConnection) {
      // Intentar crear en la API
      final result = await _remoteDataSource.create(oveja.farmId, model);
      if (result.isSuccess) {
        final created = (result as Success<OvejaModel>).data;
        await _localDataSource.save(oveja.farmId, created);
        return Success(created);
      }
    }
    
    // Guardar localmente y añadir a cola de sincronización
    await _localDataSource.save(oveja.farmId, model);
    await _syncManager.addToSyncQueue(
      tableName: 'ovinos',
      operation: 'CREATE',
      entityId: model.id,
      farmId: model.farmId,
      data: model.toJson(),
    );
    
    return Success(model);
  }

  @override
  Future<Result<Oveja>> updateOveja(Oveja oveja) async {
    final model = OvejaModel.fromEntity(oveja);
    final hasConnection = await _connectivityService.hasConnection();
    
    if (hasConnection) {
      final result = await _remoteDataSource.update(oveja.farmId, model);
      if (result.isSuccess) {
        final updated = (result as Success<OvejaModel>).data;
        await _localDataSource.save(oveja.farmId, updated);
        return Success(updated);
      }
    }
    
    // Guardar localmente y añadir a cola de sincronización
    await _localDataSource.save(oveja.farmId, model);
    await _syncManager.addToSyncQueue(
      tableName: 'ovinos',
      operation: 'UPDATE',
      entityId: model.id,
      farmId: model.farmId,
      data: model.toJson(),
    );
    
    return Success(model);
  }

  @override
  Future<Result<void>> deleteOveja(String id, String farmId) async {
    final hasConnection = await _connectivityService.hasConnection();
    
    if (hasConnection) {
      final result = await _remoteDataSource.delete(farmId, id);
      if (result.isSuccess) {
        await _localDataSource.delete(farmId, id);
        return const Success(null);
      }
    }
    
    // Eliminar localmente y añadir a cola de sincronización
    await _localDataSource.delete(farmId, id);
    await _syncManager.addToSyncQueue(
      tableName: 'ovinos',
      operation: 'DELETE',
      entityId: id,
      farmId: farmId,
      data: {'id': id},
    );
    
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
    final hasConnection = await _connectivityService.hasConnection();
    
    if (hasConnection) {
      final result = await _remoteDataSource.search(farmId, query);
      if (result.isSuccess) {
        final models = (result as Success<List<OvejaModel>>).data;
        return Success(models.cast<Oveja>().toList());
      }
    }
    
    final localResult = await _localDataSource.search(farmId, query);
    return localResult.map((models) => models.cast<Oveja>().toList());
  }
}


