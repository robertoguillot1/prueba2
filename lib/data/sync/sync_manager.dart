import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import '../../core/network/connectivity_service.dart';
import '../../core/utils/result.dart';
import '../../core/errors/failures.dart';
import '../database/app_database.dart';
import '../datasources/remote/api_client.dart';

/// Gestor de sincronización entre base de datos local y API
class SyncManager {
  final ConnectivityService _connectivityService;
  final ApiClient _apiClient;
  SyncManager({
    required ConnectivityService connectivityService,
    required ApiClient apiClient,
  })  : _connectivityService = connectivityService,
        _apiClient = apiClient;

  /// Sincroniza todas las operaciones pendientes
  Future<Result<void>> syncAll(String farmId) async {
    // En modo web, no hay cola de sincronización (SQLite no disponible)
    if (kIsWeb) {
      return const Success(null);
    }

    if (!await _connectivityService.hasConnection()) {
      return const Error(NetworkFailure('Sin conexión a internet'));
    }

    try {
      final pendingOps = await _getPendingOperations(farmId);
      
      for (final op in pendingOps) {
        final result = await _syncOperation(op, farmId);
        if (result.isError) {
          await _incrementRetryCount(op['id'] as int);
          continue;
        }
        await _removeFromSyncQueue(op['id'] as int);
        await _markAsSynced(op['tableName'] as String, op['entityId'] as String);
      }

      return const Success(null);
    } catch (e) {
      return Error(UnknownFailure('Error al sincronizar: $e'));
    }
  }

  /// Obtiene las operaciones pendientes de sincronización
  Future<List<Map<String, dynamic>>> _getPendingOperations(String farmId) async {
    if (kIsWeb) {
      return []; // En web no hay cola de sincronización
    }
    try {
      final db = await AppDatabase.database;
      return await db.query(
        'sync_queue',
        where: 'farmId = ?',
        whereArgs: [farmId],
        orderBy: 'createdAt ASC',
      );
    } catch (e) {
      return []; // Si hay error, retornar lista vacía
    }
  }

  /// Sincroniza una operación individual
  Future<Result<void>> _syncOperation(Map<String, dynamic> op, String farmId) async {
    final tableName = op['tableName'] as String;
    final operation = op['operation'] as String;
    final entityId = op['entityId'] as String;
    final data = jsonDecode(op['data'] as String) as Map<String, dynamic>;

    final endpoint = _getEndpoint(tableName, farmId, entityId);

    switch (operation) {
      case 'CREATE':
        final result = await _apiClient.post(endpoint, data);
        return result.map((_) => null);
      case 'UPDATE':
        final result = await _apiClient.put(endpoint, data);
        return result.map((_) => null);
      case 'DELETE':
        final result = await _apiClient.delete(endpoint);
        return result;
      default:
        return Error(UnknownFailure('Operación desconocida: $operation'));
    }
  }

  /// Obtiene el endpoint según la tabla
  String _getEndpoint(String tableName, String farmId, String entityId) {
    switch (tableName) {
      case 'ovinos':
        return entityId.isEmpty 
            ? '/farms/$farmId/ovinos'
            : '/farms/$farmId/ovinos/$entityId';
      case 'bovinos':
        return entityId.isEmpty
            ? '/farms/$farmId/bovinos'
            : '/farms/$farmId/bovinos/$entityId';
      case 'porcinos':
        return entityId.isEmpty
            ? '/farms/$farmId/porcinos'
            : '/farms/$farmId/porcinos/$entityId';
      case 'avicultura':
        return entityId.isEmpty
            ? '/farms/$farmId/avicultura'
            : '/farms/$farmId/avicultura/$entityId';
      case 'trabajadores':
        return entityId.isEmpty
            ? '/farms/$farmId/trabajadores'
            : '/farms/$farmId/trabajadores/$entityId';
      case 'cattle':
        return entityId.isEmpty
            ? '/farms/$farmId/cattle'
            : '/farms/$farmId/cattle/$entityId';
      default:
        throw Exception('Tabla desconocida: $tableName');
    }
  }

  /// Añade una operación a la cola de sincronización
  Future<void> addToSyncQueue({
    required String tableName,
    required String operation,
    required String entityId,
    required String farmId,
    required Map<String, dynamic> data,
  }) async {
    // En modo web, no hay cola de sincronización (SQLite no disponible)
    if (kIsWeb) {
      return;
    }
    try {
      final db = await AppDatabase.database;
      await db.insert('sync_queue', {
        'tableName': tableName,
        'operation': operation,
        'entityId': entityId,
        'farmId': farmId,
        'data': jsonEncode(data),
        'createdAt': DateTime.now().toIso8601String(),
        'retryCount': 0,
      });
    } catch (e) {
      // Ignorar errores de SQLite en web
    }
  }

  /// Incrementa el contador de reintentos
  Future<void> _incrementRetryCount(int id) async {
    if (kIsWeb) return;
    try {
      final db = await AppDatabase.database;
      final current = await db.query(
        'sync_queue',
        columns: ['retryCount'],
        where: 'id = ?',
        whereArgs: [id],
      );
      if (current.isNotEmpty) {
        final currentCount = current.first['retryCount'] as int;
        await db.update(
          'sync_queue',
          {'retryCount': currentCount + 1},
          where: 'id = ?',
          whereArgs: [id],
        );
      }
    } catch (_) {
      // Ignorar errores de SQLite
    }
  }

  /// Elimina una operación de la cola
  Future<void> _removeFromSyncQueue(int id) async {
    if (kIsWeb) return;
    try {
      final db = await AppDatabase.database;
      await db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
    } catch (_) {
      // Ignorar errores de SQLite
    }
  }

  /// Marca una entidad como sincronizada
  Future<void> _markAsSynced(String tableName, String entityId) async {
    if (kIsWeb) return;
    try {
      final db = await AppDatabase.database;
      await db.update(
        tableName,
        {'synced': 1},
        where: 'id = ?',
        whereArgs: [entityId],
      );
    } catch (_) {
      // Ignorar errores de SQLite
    }
  }

  /// Limpia operaciones antiguas (más de 30 días)
  Future<void> cleanOldOperations() async {
    if (kIsWeb) return;
    try {
      final db = await AppDatabase.database;
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      await db.delete(
        'sync_queue',
        where: 'createdAt < ?',
        whereArgs: [thirtyDaysAgo.toIso8601String()],
      );
    } catch (_) {
      // Ignorar errores de SQLite
    }
  }
}

