import 'package:flutter/foundation.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../data/sync/sync_manager.dart';
import '../../../../domain/entities/trabajadores/trabajador.dart';
import '../../../../domain/repositories/trabajadores/trabajadores_repository.dart';
import '../../../../data/repositories_impl/trabajadores/trabajadores_repository_impl.dart';
import '../../../../data/datasources/trabajadores/trabajadores_datasource.dart';
import '../../../../data/models/trabajadores/trabajador_model.dart';
import '../../domain/entities/pago.dart';
import '../../domain/entities/prestamo.dart';
import '../datasources/trabajadores_remote_datasource.dart' show TrabajadoresRemoteDataSource, ServerException;
import '../datasources/local/trabajadores_local_datasource.dart';
import '../models/pago_model.dart';
import '../models/prestamo_model.dart';

/// Repositorio híbrido que alterna entre Firestore y base de datos local
/// Para trabajadores, pagos y préstamos usa el sistema híbrido
class TrabajadoresHybridRepositoryImpl implements TrabajadoresRepository {
  final ConnectivityService _connectivityService;
  final TrabajadoresRemoteDataSource _remoteDataSource;
  final TrabajadoresLocalDataSource _localDataSource;
  final SyncManager _syncManager;
  final TrabajadoresRepositoryImpl _legacyRepository;

  TrabajadoresHybridRepositoryImpl({
    required ConnectivityService connectivityService,
    required TrabajadoresRemoteDataSource remoteDataSource,
    required TrabajadoresLocalDataSource localDataSource,
    required SyncManager syncManager,
    required TrabajadoresDataSource legacyDataSource,
  })  : _connectivityService = connectivityService,
        _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _syncManager = syncManager,
        _legacyRepository = TrabajadoresRepositoryImpl(legacyDataSource);

  // ========== MÉTODOS DE TRABAJADORES (usando Firestore) ==========
  @override
  Future<Result<List<Trabajador>>> getAllTrabajadores(String farmId) async {
    // En modo web, solo usar remoto
    if (kIsWeb) {
      try {
        final workers = await _remoteDataSource.getWorkers(farmId);
        return Success(workers);
      } on ServerException catch (e) {
        return Error(ServerFailure(e.message));
      } catch (e) {
        return Error(ServerFailure('Error al obtener trabajadores: $e'));
      }
    }

    final hasConnection = await _connectivityService.hasConnection();

    if (hasConnection) {
      // Intentar obtener de Firestore
      try {
        final workers = await _remoteDataSource.getWorkers(farmId);
        // Guardar en local para uso offline (si es posible)
        try {
          for (final worker in workers) {
            await _legacyRepository.createTrabajador(worker);
          }
        } catch (_) {
          // Ignorar errores de guardado local
        }
        return Success(workers);
      } on ServerException {
        // Si falla, intentar local
        return await _legacyRepository.getAllTrabajadores(farmId);
      } catch (_) {
        // Si falla, intentar local
        return await _legacyRepository.getAllTrabajadores(farmId);
      }
    }

    // Si no hay conexión, usar local
    return await _legacyRepository.getAllTrabajadores(farmId);
  }

  @override
  Future<Result<Trabajador>> getTrabajadorById(String id, String farmId) async {
    // En modo web, solo usar remoto
    if (kIsWeb) {
      try {
        final worker = await _remoteDataSource.getWorker(farmId, id);
        return Success(worker);
      } on ServerException catch (e) {
        return Error(ServerFailure(e.message));
      } catch (e) {
        return Error(ServerFailure('Error al obtener trabajador: $e'));
      }
    }

    final hasConnection = await _connectivityService.hasConnection();

    if (hasConnection) {
      try {
        final worker = await _remoteDataSource.getWorker(farmId, id);
        // Guardar en local para uso offline
        try {
          await _legacyRepository.createTrabajador(worker);
        } catch (_) {
          // Ignorar errores de guardado local
        }
        return Success(worker);
      } on ServerException {
        // Si falla, intentar local
        return await _legacyRepository.getTrabajadorById(id, farmId);
      } catch (_) {
        // Si falla, intentar local
        return await _legacyRepository.getTrabajadorById(id, farmId);
      }
    }

    // Si no hay conexión, usar local
    return await _legacyRepository.getTrabajadorById(id, farmId);
  }

  @override
  Future<Result<Trabajador>> createTrabajador(Trabajador trabajador) async {
    final workerModel = TrabajadorModel.fromEntity(trabajador);

    // En modo web, solo usar remoto
    if (kIsWeb) {
      try {
        final created = await _remoteDataSource.addWorker(workerModel);
        return Success(created);
      } on ServerException catch (e) {
        return Error(ServerFailure(e.message));
      } catch (e) {
        return Error(ServerFailure('Error al crear trabajador: $e'));
      }
    }

    final hasConnection = await _connectivityService.hasConnection();

    if (hasConnection) {
      // Intentar crear en Firestore
      try {
        final created = await _remoteDataSource.addWorker(workerModel);
        // Guardar en local para uso offline
        try {
          await _legacyRepository.createTrabajador(created);
        } catch (_) {
          // Ignorar errores de guardado local
        }
        return Success(created);
      } on ServerException {
        // Si falla, guardar localmente y añadir a cola de sincronización
        try {
          await _legacyRepository.createTrabajador(workerModel);
          await _syncManager.addToSyncQueue(
            tableName: 'trabajadores',
            operation: 'CREATE',
            entityId: workerModel.id,
            farmId: workerModel.farmId,
            data: workerModel.toJson(),
          );
        } catch (e) {
          return Error(CacheFailure('Error al guardar trabajador localmente: $e'));
        }
        return Success(workerModel);
      } catch (_) {
        // Si falla, guardar localmente y añadir a cola de sincronización
        try {
          await _legacyRepository.createTrabajador(workerModel);
          await _syncManager.addToSyncQueue(
            tableName: 'trabajadores',
            operation: 'CREATE',
            entityId: workerModel.id,
            farmId: workerModel.farmId,
            data: workerModel.toJson(),
          );
        } catch (e) {
          return Error(CacheFailure('Error al guardar trabajador localmente: $e'));
        }
        return Success(workerModel);
      }
    }

    // Guardar localmente y añadir a cola de sincronización
    try {
      await _legacyRepository.createTrabajador(workerModel);
      await _syncManager.addToSyncQueue(
        tableName: 'trabajadores',
        operation: 'CREATE',
        entityId: workerModel.id,
        farmId: workerModel.farmId,
        data: workerModel.toJson(),
      );
    } catch (e) {
      return Error(CacheFailure('Error al guardar trabajador localmente: $e'));
    }

    return Success(workerModel);
  }

  @override
  Future<Result<Trabajador>> updateTrabajador(Trabajador trabajador) async {
    final workerModel = TrabajadorModel.fromEntity(trabajador);

    // En modo web, solo usar remoto
    if (kIsWeb) {
      try {
        final updated = await _remoteDataSource.updateWorker(workerModel);
        return Success(updated);
      } on ServerException catch (e) {
        return Error(ServerFailure(e.message));
      } catch (e) {
        return Error(ServerFailure('Error al actualizar trabajador: $e'));
      }
    }

    final hasConnection = await _connectivityService.hasConnection();

    if (hasConnection) {
      try {
        final updated = await _remoteDataSource.updateWorker(workerModel);
        // Guardar en local para uso offline
        try {
          await _legacyRepository.updateTrabajador(updated);
        } catch (_) {
          // Ignorar errores de guardado local
        }
        return Success(updated);
      } on ServerException {
        // Si falla, guardar localmente y añadir a cola de sincronización
        try {
          await _legacyRepository.updateTrabajador(workerModel);
          await _syncManager.addToSyncQueue(
            tableName: 'trabajadores',
            operation: 'UPDATE',
            entityId: workerModel.id,
            farmId: workerModel.farmId,
            data: workerModel.toJson(),
          );
        } catch (e) {
          return Error(CacheFailure('Error al actualizar trabajador localmente: $e'));
        }
        return Success(workerModel);
      } catch (_) {
        // Si falla, guardar localmente y añadir a cola de sincronización
        try {
          await _legacyRepository.updateTrabajador(workerModel);
          await _syncManager.addToSyncQueue(
            tableName: 'trabajadores',
            operation: 'UPDATE',
            entityId: workerModel.id,
            farmId: workerModel.farmId,
            data: workerModel.toJson(),
          );
        } catch (e) {
          return Error(CacheFailure('Error al actualizar trabajador localmente: $e'));
        }
        return Success(workerModel);
      }
    }

    // Guardar localmente y añadir a cola de sincronización
    try {
      await _legacyRepository.updateTrabajador(workerModel);
      await _syncManager.addToSyncQueue(
        tableName: 'trabajadores',
        operation: 'UPDATE',
        entityId: workerModel.id,
        farmId: workerModel.farmId,
        data: workerModel.toJson(),
      );
    } catch (e) {
      return Error(CacheFailure('Error al actualizar trabajador localmente: $e'));
    }

    return Success(workerModel);
  }

  @override
  Future<Result<void>> deleteTrabajador(String id, String farmId) async {
    // En modo web, solo usar remoto
    if (kIsWeb) {
      try {
        await _remoteDataSource.deleteWorker(farmId, id);
        return const Success(null);
      } on ServerException catch (e) {
        return Error(ServerFailure(e.message));
      } catch (e) {
        return Error(ServerFailure('Error al eliminar trabajador: $e'));
      }
    }

    final hasConnection = await _connectivityService.hasConnection();

    if (hasConnection) {
      try {
        await _remoteDataSource.deleteWorker(farmId, id);
        // Eliminar de local también
        try {
          await _legacyRepository.deleteTrabajador(id, farmId);
        } catch (_) {
          // Ignorar errores de eliminación local
        }
        return const Success(null);
      } on ServerException {
        // Si falla, eliminar localmente y añadir a cola de sincronización
        try {
          await _legacyRepository.deleteTrabajador(id, farmId);
          await _syncManager.addToSyncQueue(
            tableName: 'trabajadores',
            operation: 'DELETE',
            entityId: id,
            farmId: farmId,
            data: {'id': id, 'farmId': farmId},
          );
        } catch (e) {
          return Error(CacheFailure('Error al eliminar trabajador localmente: $e'));
        }
        return const Success(null);
      } catch (_) {
        // Si falla, eliminar localmente y añadir a cola de sincronización
        try {
          await _legacyRepository.deleteTrabajador(id, farmId);
          await _syncManager.addToSyncQueue(
            tableName: 'trabajadores',
            operation: 'DELETE',
            entityId: id,
            farmId: farmId,
            data: {'id': id, 'farmId': farmId},
          );
        } catch (e) {
          return Error(CacheFailure('Error al eliminar trabajador localmente: $e'));
        }
        return const Success(null);
      }
    }

    // Eliminar localmente y añadir a cola de sincronización
    try {
      await _legacyRepository.deleteTrabajador(id, farmId);
      await _syncManager.addToSyncQueue(
        tableName: 'trabajadores',
        operation: 'DELETE',
        entityId: id,
        farmId: farmId,
        data: {'id': id, 'farmId': farmId},
      );
    } catch (e) {
      return Error(CacheFailure('Error al eliminar trabajador localmente: $e'));
    }

    return const Success(null);
  }

  @override
  Future<Result<List<Trabajador>>> getTrabajadoresActivos(String farmId) async {
    final result = await getAllTrabajadores(farmId);
    if (result is Success<List<Trabajador>>) {
      final activos = result.data.where((t) => t.isActive).toList();
      return Success(activos);
    }
    return result;
  }

  @override
  Future<Result<List<Trabajador>>> searchTrabajadores(String farmId, String query) async {
    // En modo web, solo usar remoto
    if (kIsWeb) {
      try {
        final workers = await _remoteDataSource.searchWorkers(farmId, query);
        return Success(workers);
      } on ServerException catch (e) {
        return Error(ServerFailure(e.message));
      } catch (e) {
        return Error(ServerFailure('Error al buscar trabajadores: $e'));
      }
    }

    final hasConnection = await _connectivityService.hasConnection();

    if (hasConnection) {
      try {
        final workers = await _remoteDataSource.searchWorkers(farmId, query);
        return Success(workers);
      } on ServerException {
        // Si falla, usar búsqueda local
        return await _legacyRepository.searchTrabajadores(farmId, query);
      } catch (_) {
        // Si falla, usar búsqueda local
        return await _legacyRepository.searchTrabajadores(farmId, query);
      }
    }

    // Si no hay conexión, usar búsqueda local
    return await _legacyRepository.searchTrabajadores(farmId, query);
  }

  @override
  Future<Result<List<Pago>>> getPagosByTrabajador(String workerId) async {
    // En modo web, solo usar remoto (SQLite no está disponible)
    if (kIsWeb) {
      try {
        // Necesitamos farmId, pero el contrato solo tiene workerId
        // En web, intentar obtener de local primero (puede fallar, pero lo manejamos)
        String? farmId;
        try {
          final localResult = await _localDataSource.getPagosByWorker(workerId);
          if (localResult is Success<List<PagoModel>> && localResult.data.isNotEmpty) {
            farmId = localResult.data.first.farmId;
          }
        } catch (_) {
          // Ignorar error de local en web
        }

        // Si no tenemos farmId de local, intentar obtenerlo del trabajador desde Firestore
        // Esto requiere buscar en todas las fincas, lo cual no es ideal pero funciona
        if (farmId == null) {
          // Por ahora, retornar lista vacía si no podemos obtener farmId
          // En el futuro, se podría mejorar obteniendo farmId del contexto de la app
          return const Success([]);
        }

        final pagos = await _remoteDataSource.getPagosByWorker(farmId, workerId);
        return Success(pagos);
      } on ServerException catch (e) {
        return Error(ServerFailure(e.message));
      } catch (e) {
        // Si hay error, retornar lista vacía en lugar de error para mejor UX
        return const Success([]);
      }
    }

    // En móvil/desktop, usar lógica híbrida
    final hasConnection = await _connectivityService.hasConnection();

    if (hasConnection) {
      // Intentar obtener de Firestore
      try {
        // Necesitamos farmId, pero el contrato solo tiene workerId
        // Por ahora, intentar obtener de local primero para obtener farmId
        final localResult = await _localDataSource.getPagosByWorker(workerId);
        String? farmId;
        if (localResult is Success<List<PagoModel>> && localResult.data.isNotEmpty) {
          farmId = localResult.data.first.farmId;
        }

        if (farmId != null) {
          final pagos = await _remoteDataSource.getPagosByWorker(farmId, workerId);
          // Guardar en local para uso offline
          for (final pago in pagos) {
            await _localDataSource.savePago(pago);
          }
          return Success(pagos);
        }
      } on ServerException {
        // Si falla, intentar local
        return await _getPagosFromLocal(workerId);
      } catch (_) {
        // Si falla, intentar local
        return await _getPagosFromLocal(workerId);
      }
    }

    // Si no hay conexión, usar local
    return await _getPagosFromLocal(workerId);
  }

  Future<Result<List<Pago>>> _getPagosFromLocal(String workerId) async {
    try {
      final result = await _localDataSource.getPagosByWorker(workerId);
      if (result is Success<List<PagoModel>>) {
        return Success(result.data.cast<Pago>().toList());
      } else if (result is Error<List<PagoModel>>) {
        return Error(CacheFailure(result.failure.message));
      } else {
        return Error(CacheFailure('Error desconocido al obtener pagos'));
      }
    } catch (e) {
      // Si es error de SQLite en web, retornar lista vacía
      if (kIsWeb && e.toString().contains('SQLite')) {
        return const Success([]);
      }
      return Error(CacheFailure('Error al obtener pagos: $e'));
    }
  }

  @override
  Future<Result<Pago>> createPago(Pago pago) async {
    final model = pago is PagoModel ? pago : PagoModel.fromEntity(pago);

    // En modo web, solo usar remoto
    if (kIsWeb) {
      try {
        final created = await _remoteDataSource.addPago(model);
        return Success(created);
      } on ServerException catch (e) {
        return Error(ServerFailure(e.message));
      } catch (e) {
        return Error(ServerFailure('Error al crear pago: $e'));
      }
    }

    final hasConnection = await _connectivityService.hasConnection();

    if (hasConnection) {
      try {
        final created = await _remoteDataSource.addPago(model);
        // Guardar en local también
        await _localDataSource.savePago(created);
        return Success(created);
      } on ServerException catch (e) {
        // Guardar en local para sincronizar después
        final localResult = await _localDataSource.savePago(model);
        if (localResult is Success<PagoModel>) {
          // Agregar a cola de sincronización
          await _syncManager.addToSyncQueue(
            tableName: 'pagos',
            farmId: model.farmId,
            entityId: model.id,
            operation: 'CREATE',
            data: model.toJson(),
          );
          return Success(localResult.data);
        } else {
          return Error(ServerFailure(e.message));
        }
      } catch (e) {
        // Guardar en local para sincronizar después
        final localResult = await _localDataSource.savePago(model);
        if (localResult is Success<PagoModel>) {
          await _syncManager.addToSyncQueue(
            tableName: 'pagos',
            farmId: model.farmId,
            entityId: model.id,
            operation: 'CREATE',
            data: model.toJson(),
          );
          return Success(localResult.data);
        } else {
          return Error(ServerFailure('Error al crear pago: $e'));
        }
      }
    }

    // Sin conexión: guardar en local y agregar a cola de sincronización
    try {
      final localResult = await _localDataSource.savePago(model);
      if (localResult is Success<PagoModel>) {
        await _syncManager.addToSyncQueue(
          tableName: 'pagos',
          farmId: model.farmId,
          entityId: model.id,
          operation: 'CREATE',
          data: model.toJson(),
        );
        return Success(localResult.data);
      } else if (localResult is Error<PagoModel>) {
        return Error(CacheFailure(localResult.failure.message));
      } else {
        return Error(CacheFailure('Error desconocido al crear pago'));
      }
    } catch (e) {
      return Error(CacheFailure('Error al guardar pago localmente: $e'));
    }
  }

  @override
  Future<Result<Pago>> updatePago(Pago pago) async {
    final model = pago is PagoModel ? pago : PagoModel.fromEntity(pago);

    // En modo web, solo usar remoto
    if (kIsWeb) {
      try {
        final updated = await _remoteDataSource.updatePago(model);
        return Success(updated);
      } on ServerException catch (e) {
        return Error(ServerFailure(e.message));
      } catch (e) {
        return Error(ServerFailure('Error al actualizar pago: $e'));
      }
    }

    final hasConnection = await _connectivityService.hasConnection();

    if (hasConnection) {
      try {
        final updated = await _remoteDataSource.updatePago(model);
        try {
          await _localDataSource.updatePago(updated);
        } catch (_) {
          // Ignorar errores de SQLite
        }
        return Success(updated);
      } on ServerException catch (e) {
        // Actualizar en local para sincronizar después
        try {
          final localResult = await _localDataSource.updatePago(model);
          if (localResult is Success<PagoModel>) {
            await _syncManager.addToSyncQueue(
              tableName: 'pagos',
              farmId: model.farmId,
              entityId: model.id,
              operation: 'UPDATE',
              data: model.toJson(),
            );
            return Success(localResult.data);
          } else {
            return Error(ServerFailure(e.message));
          }
        } catch (_) {
          return Error(ServerFailure(e.message));
        }
      } catch (e) {
        try {
          final localResult = await _localDataSource.updatePago(model);
          if (localResult is Success<PagoModel>) {
            await _syncManager.addToSyncQueue(
              tableName: 'pagos',
              farmId: model.farmId,
              entityId: model.id,
              operation: 'UPDATE',
              data: model.toJson(),
            );
            return Success(localResult.data);
          } else {
            return Error(ServerFailure('Error al actualizar pago: $e'));
          }
        } catch (_) {
          return Error(ServerFailure('Error al actualizar pago: $e'));
        }
      }
    }

    // Sin conexión: actualizar en local y agregar a cola de sincronización
    try {
      final localResult = await _localDataSource.updatePago(model);
      if (localResult is Success<PagoModel>) {
        await _syncManager.addToSyncQueue(
          tableName: 'pagos',
          farmId: model.farmId,
          entityId: model.id,
          operation: 'UPDATE',
          data: model.toJson(),
        );
        return Success(localResult.data);
      } else if (localResult is Error<PagoModel>) {
        return Error(CacheFailure(localResult.failure.message));
      } else {
        return Error(CacheFailure('Error desconocido al actualizar pago'));
      }
    } catch (e) {
      return Error(CacheFailure('Error al actualizar pago localmente: $e'));
    }
  }

  @override
  Future<Result<void>> deletePago(String workerId, String pagoId) async {
    // Necesitamos farmId, intentar obtener de local primero
    String? farmId;
    try {
      final localResult = await _localDataSource.getPagosByWorker(workerId);
      if (localResult is Success<List<PagoModel>>) {
        final pago = localResult.data.firstWhere((p) => p.id == pagoId, orElse: () => localResult.data.first);
        farmId = pago.farmId;
      }
    } catch (_) {
      // Ignorar errores
    }

    if (farmId == null) {
      return Error(CacheFailure('No se pudo obtener farmId para eliminar el pago'));
    }

    // En modo web, solo usar remoto
    if (kIsWeb) {
      try {
        await _remoteDataSource.deletePago(farmId, workerId, pagoId);
        return const Success(null);
      } on ServerException catch (e) {
        return Error(ServerFailure(e.message));
      } catch (e) {
        return Error(ServerFailure('Error al eliminar pago: $e'));
      }
    }

    final hasConnection = await _connectivityService.hasConnection();

    if (hasConnection) {
      try {
        await _remoteDataSource.deletePago(farmId, workerId, pagoId);
        try {
          await _localDataSource.deletePago(workerId, pagoId);
        } catch (_) {
          // Ignorar errores de SQLite
        }
        return const Success(null);
      } on ServerException catch (e) {
        // Eliminar en local y agregar a cola de sincronización
        try {
          await _localDataSource.deletePago(workerId, pagoId);
          await _syncManager.addToSyncQueue(
            tableName: 'pagos',
            farmId: farmId,
            entityId: pagoId,
            operation: 'DELETE',
            data: {'id': pagoId},
          );
        } catch (_) {
          // Ignorar errores
        }
        return const Success(null);
      } catch (e) {
        try {
          await _localDataSource.deletePago(workerId, pagoId);
          await _syncManager.addToSyncQueue(
            tableName: 'pagos',
            farmId: farmId,
            entityId: pagoId,
            operation: 'DELETE',
            data: {'id': pagoId},
          );
        } catch (_) {
          // Ignorar errores
        }
        return const Success(null);
      }
    }

    // Sin conexión: eliminar en local y agregar a cola de sincronización
    try {
      await _localDataSource.deletePago(workerId, pagoId);
      await _syncManager.addToSyncQueue(
        tableName: 'pagos',
        farmId: farmId,
        entityId: pagoId,
        operation: 'DELETE',
        data: {'id': pagoId},
      );
      return const Success(null);
    } catch (e) {
      return Error(CacheFailure('Error al eliminar pago localmente: $e'));
    }
  }

  @override
  Future<Result<List<Prestamo>>> getPrestamosByTrabajador(String workerId) async {
    // En modo web, solo usar remoto (SQLite no está disponible)
    if (kIsWeb) {
      try {
        // Necesitamos farmId, intentar obtener de local primero
        String? farmId;
        try {
          final localResult = await _localDataSource.getPrestamosByWorker(workerId);
          if (localResult is Success<List<PrestamoModel>> && localResult.data.isNotEmpty) {
            farmId = localResult.data.first.farmId;
          }
        } catch (_) {
          // Ignorar error de local en web
        }

        // Si no tenemos farmId de local, retornar lista vacía
        if (farmId == null) {
          return const Success([]);
        }

        final prestamos = await _remoteDataSource.getPrestamosByWorker(farmId, workerId);
        return Success(prestamos);
      } on ServerException catch (e) {
        return Error(ServerFailure(e.message));
      } catch (e) {
        return Error(ServerFailure('Error al obtener préstamos: $e'));
      }
    }

    final hasConnection = await _connectivityService.hasConnection();

    if (hasConnection) {
      try {
        // Necesitamos farmId, intentar obtener de local primero
        final localResult = await _localDataSource.getPrestamosByWorker(workerId);
        String? farmId;
        if (localResult is Success<List<PrestamoModel>> && localResult.data.isNotEmpty) {
          farmId = localResult.data.first.farmId;
        }

        if (farmId != null) {
          final prestamos = await _remoteDataSource.getPrestamosByWorker(farmId, workerId);
          // Guardar en local para uso offline
          for (final prestamo in prestamos) {
            await _localDataSource.savePrestamo(prestamo);
          }
          return Success(prestamos);
        }
      } on ServerException {
        // Si falla, intentar local
        return await _getPrestamosFromLocal(workerId);
      } catch (_) {
        // Si falla, intentar local
        return await _getPrestamosFromLocal(workerId);
      }
    }

    // Si no hay conexión, usar local
    return await _getPrestamosFromLocal(workerId);
  }

  Future<Result<List<Prestamo>>> _getPrestamosFromLocal(String workerId) async {
    try {
      final result = await _localDataSource.getPrestamosByWorker(workerId);
      if (result is Success<List<PrestamoModel>>) {
        return Success(result.data.cast<Prestamo>().toList());
      } else if (result is Error<List<PrestamoModel>>) {
        return Error(CacheFailure(result.failure.message));
      } else {
        return Error(CacheFailure('Error desconocido al obtener préstamos'));
      }
    } catch (e) {
      // Si es error de SQLite en web, retornar lista vacía
      if (kIsWeb && e.toString().contains('SQLite')) {
        return const Success([]);
      }
      return Error(CacheFailure('Error al obtener préstamos: $e'));
    }
  }

  @override
  Future<Result<Prestamo>> createPrestamo(Prestamo prestamo) async {
    final model = prestamo is PrestamoModel ? prestamo : PrestamoModel.fromEntity(prestamo);

    // En modo web, solo usar remoto
    if (kIsWeb) {
      try {
        final created = await _remoteDataSource.addPrestamo(model);
        return Success(created);
      } on ServerException catch (e) {
        return Error(ServerFailure(e.message));
      } catch (e) {
        return Error(ServerFailure('Error al crear préstamo: $e'));
      }
    }

    final hasConnection = await _connectivityService.hasConnection();

    if (hasConnection) {
      try {
        final created = await _remoteDataSource.addPrestamo(model);
        // Guardar en local también
        await _localDataSource.savePrestamo(created);
        return Success(created);
      } on ServerException catch (e) {
        // Guardar en local para sincronizar después
        final localResult = await _localDataSource.savePrestamo(model);
        if (localResult is Success<PrestamoModel>) {
          await _syncManager.addToSyncQueue(
            tableName: 'prestamos',
            farmId: model.farmId,
            entityId: model.id,
            operation: 'CREATE',
            data: model.toJson(),
          );
          return Success(localResult.data);
        } else {
          return Error(ServerFailure(e.message));
        }
      } catch (e) {
        final localResult = await _localDataSource.savePrestamo(model);
        if (localResult is Success<PrestamoModel>) {
          await _syncManager.addToSyncQueue(
            tableName: 'prestamos',
            farmId: model.farmId,
            entityId: model.id,
            operation: 'CREATE',
            data: model.toJson(),
          );
          return Success(localResult.data);
        } else {
          return Error(ServerFailure('Error al crear préstamo: $e'));
        }
      }
    }

    // Sin conexión: guardar en local y agregar a cola de sincronización
    final localResult = await _localDataSource.savePrestamo(model);
    if (localResult is Success<PrestamoModel>) {
      await _syncManager.addToSyncQueue(
        tableName: 'prestamos',
        farmId: model.farmId,
        entityId: model.id,
        operation: 'CREATE',
        data: model.toJson(),
      );
      return Success(localResult.data);
    } else if (localResult is Error<PrestamoModel>) {
      return Error(CacheFailure(localResult.failure.message));
    } else {
      return Error(CacheFailure('Error desconocido al crear préstamo'));
    }
  }

  @override
  Future<Result<Prestamo>> updatePrestamo(Prestamo prestamo) async {
    final model = prestamo is PrestamoModel ? prestamo : PrestamoModel.fromEntity(prestamo);

    // En modo web, solo usar remoto
    if (kIsWeb) {
      try {
        final updated = await _remoteDataSource.updatePrestamo(model);
        return Success(updated);
      } on ServerException catch (e) {
        return Error(ServerFailure(e.message));
      } catch (e) {
        return Error(ServerFailure('Error al actualizar préstamo: $e'));
      }
    }

    final hasConnection = await _connectivityService.hasConnection();

    if (hasConnection) {
      try {
        final updated = await _remoteDataSource.updatePrestamo(model);
        // Actualizar en local también
        await _localDataSource.updatePrestamo(updated);
        return Success(updated);
      } on ServerException catch (e) {
        // Actualizar en local para sincronizar después
        final localResult = await _localDataSource.updatePrestamo(model);
        if (localResult is Success<PrestamoModel>) {
          await _syncManager.addToSyncQueue(
            tableName: 'prestamos',
            farmId: model.farmId,
            entityId: model.id,
            operation: 'UPDATE',
            data: model.toJson(),
          );
          return Success(localResult.data);
        } else {
          return Error(ServerFailure(e.message));
        }
      } catch (e) {
        final localResult = await _localDataSource.updatePrestamo(model);
        if (localResult is Success<PrestamoModel>) {
          await _syncManager.addToSyncQueue(
            tableName: 'prestamos',
            farmId: model.farmId,
            entityId: model.id,
            operation: 'UPDATE',
            data: model.toJson(),
          );
          return Success(localResult.data);
        } else {
          return Error(ServerFailure('Error al actualizar préstamo: $e'));
        }
      }
    }

    // Sin conexión: actualizar en local y agregar a cola de sincronización
    final localResult = await _localDataSource.updatePrestamo(model);
    if (localResult is Success<PrestamoModel>) {
      await _syncManager.addToSyncQueue(
            tableName: 'prestamos',
        farmId: model.farmId,
        entityId: model.id,
            operation: 'UPDATE',
        data: model.toJson(),
      );
      return Success(localResult.data);
    } else if (localResult is Error<PrestamoModel>) {
      return Error(CacheFailure(localResult.failure.message));
    } else {
      return Error(CacheFailure('Error desconocido al actualizar préstamo'));
    }
  }

  @override
  Future<Result<void>> deletePrestamo(String workerId, String prestamoId) async {
    // Necesitamos farmId, intentar obtener de local primero
    String? farmId;
    try {
      final localResult = await _localDataSource.getPrestamosByWorker(workerId);
      if (localResult is Success<List<PrestamoModel>>) {
        final prestamo = localResult.data.firstWhere((p) => p.id == prestamoId, orElse: () => localResult.data.first);
        farmId = prestamo.farmId;
      }
    } catch (_) {
      // Ignorar errores
    }

    if (farmId == null) {
      return Error(CacheFailure('No se pudo obtener farmId para eliminar el préstamo'));
    }

    // En modo web, solo usar remoto
    if (kIsWeb) {
      try {
        await _remoteDataSource.deletePrestamo(farmId, workerId, prestamoId);
        return const Success(null);
      } on ServerException catch (e) {
        return Error(ServerFailure(e.message));
      } catch (e) {
        return Error(ServerFailure('Error al eliminar préstamo: $e'));
      }
    }

    final hasConnection = await _connectivityService.hasConnection();

    if (hasConnection) {
      try {
        await _remoteDataSource.deletePrestamo(farmId, workerId, prestamoId);
        try {
          await _localDataSource.deletePrestamo(workerId, prestamoId);
        } catch (_) {
          // Ignorar errores de SQLite
        }
        return const Success(null);
      } on ServerException catch (e) {
        // Eliminar en local y agregar a cola de sincronización
        try {
          await _localDataSource.deletePrestamo(workerId, prestamoId);
          await _syncManager.addToSyncQueue(
            tableName: 'prestamos',
            farmId: farmId,
            entityId: prestamoId,
            operation: 'DELETE',
            data: {'id': prestamoId},
          );
        } catch (_) {
          // Ignorar errores
        }
        return const Success(null);
      } catch (e) {
        try {
          await _localDataSource.deletePrestamo(workerId, prestamoId);
          await _syncManager.addToSyncQueue(
            tableName: 'prestamos',
            farmId: farmId,
            entityId: prestamoId,
            operation: 'DELETE',
            data: {'id': prestamoId},
          );
        } catch (_) {
          // Ignorar errores
        }
        return const Success(null);
      }
    }

    // Sin conexión: eliminar en local y agregar a cola de sincronización
    try {
      await _localDataSource.deletePrestamo(workerId, prestamoId);
      await _syncManager.addToSyncQueue(
        tableName: 'prestamos',
        farmId: farmId,
        entityId: prestamoId,
        operation: 'DELETE',
        data: {'id': prestamoId},
      );
      return const Success(null);
    } catch (e) {
      return Error(CacheFailure('Error al eliminar préstamo localmente: $e'));
    }
  }
}

