import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../models/ovinos/oveja_model.dart';
import '../../../database/app_database.dart';

/// Data source local para Ovinos usando SQLite
abstract class OvinosLocalDataSource {
  Future<Result<List<OvejaModel>>> fetchAll(String farmId);
  Future<Result<OvejaModel>> fetchById(String farmId, String id);
  Future<Result<OvejaModel>> save(String farmId, OvejaModel oveja);
  Future<Result<void>> delete(String farmId, String id);
  Future<Result<List<OvejaModel>>> search(String farmId, String query);
}

class OvinosLocalDataSourceImpl implements OvinosLocalDataSource {
  @override
  Future<Result<List<OvejaModel>>> fetchAll(String farmId) async {
    try {
      final db = await AppDatabase.database;
      final maps = await db.query(
        'ovinos',
        where: 'farmId = ?',
        whereArgs: [farmId],
      );
      final ovejas = maps.map((map) => OvejaModel.fromJson(_mapToJson(map))).toList();
      return Success(ovejas);
    } catch (e) {
      return Error(CacheFailure('Error al obtener ovejas: $e'));
    }
  }

  @override
  Future<Result<OvejaModel>> fetchById(String farmId, String id) async {
    try {
      final db = await AppDatabase.database;
      final maps = await db.query(
        'ovinos',
        where: 'farmId = ? AND id = ?',
        whereArgs: [farmId, id],
        limit: 1,
      );
      if (maps.isEmpty) {
        return Error(NotFoundFailure('Oveja no encontrada'));
      }
      return Success(OvejaModel.fromJson(_mapToJson(maps.first)));
    } catch (e) {
      return Error(CacheFailure('Error al obtener oveja: $e'));
    }
  }

  @override
  Future<Result<OvejaModel>> save(String farmId, OvejaModel oveja) async {
    try {
      final db = await AppDatabase.database;
      final json = oveja.toJson();
      json['synced'] = 0; // Marcar como no sincronizado
      await db.insert(
        'ovinos',
        _jsonToMap(json),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return Success(oveja);
    } catch (e) {
      return Error(CacheFailure('Error al guardar oveja: $e'));
    }
  }

  @override
  Future<Result<void>> delete(String farmId, String id) async {
    try {
      final db = await AppDatabase.database;
      await db.delete(
        'ovinos',
        where: 'farmId = ? AND id = ?',
        whereArgs: [farmId, id],
      );
      return const Success(null);
    } catch (e) {
      return Error(CacheFailure('Error al eliminar oveja: $e'));
    }
  }

  @override
  Future<Result<List<OvejaModel>>> search(String farmId, String query) async {
    try {
      final db = await AppDatabase.database;
      final maps = await db.query(
        'ovinos',
        where: 'farmId = ? AND (name LIKE ? OR identification LIKE ? OR id LIKE ?)',
        whereArgs: [farmId, '%$query%', '%$query%', '%$query%'],
      );
      final ovejas = maps.map((map) => OvejaModel.fromJson(_mapToJson(map))).toList();
      return Success(ovejas);
    } catch (e) {
      return Error(CacheFailure('Error al buscar ovejas: $e'));
    }
  }

  Map<String, dynamic> _mapToJson(Map<String, dynamic> map) {
    final json = Map<String, dynamic>.from(map);
    json.remove('synced'); // Remover campo interno
    return json;
  }

  Map<String, dynamic> _jsonToMap(Map<String, dynamic> json) {
    return Map<String, dynamic>.from(json);
  }
}


