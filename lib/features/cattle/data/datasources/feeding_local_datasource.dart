import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import '../../../../data/database/app_database.dart';
import '../models/feeding_schedule_model.dart';
import '../models/nutritional_alert_model.dart';

abstract class FeedingLocalDataSource {
  Future<List<FeedingScheduleModel>> getFeedingSchedules(String bovineId);
  Future<void> saveFeedingSchedule(FeedingScheduleModel schedule);
  Future<void> deleteFeedingSchedule(String scheduleId);
  Future<List<NutritionalAlertModel>> getNutritionalAlerts(String bovineId);
}

class FeedingLocalDataSourceImpl implements FeedingLocalDataSource {
  @override
  Future<List<FeedingScheduleModel>> getFeedingSchedules(String bovineId) async {
    if (kIsWeb) return [];
    try {
      final db = await AppDatabase.database;
      final result = await db.query(
        'feeding_schedules',
        where: 'bovineId = ?',
        whereArgs: [bovineId],
      );
      return result.map((json) => FeedingScheduleModel.fromJson(json)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveFeedingSchedule(FeedingScheduleModel schedule) async {
    if (kIsWeb) return;
    try {
      final db = await AppDatabase.database;
      await db.insert(
        'feeding_schedules',
        schedule.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (_) {
      // Ignorar errores de SQLite
    }
  }

  @override
  Future<void> deleteFeedingSchedule(String scheduleId) async {
    if (kIsWeb) return;
    try {
      final db = await AppDatabase.database;
      await db.delete(
        'feeding_schedules',
        where: 'id = ?',
        whereArgs: [scheduleId],
      );
    } catch (_) {
      // Ignorar errores de SQLite
    }
  }

  @override
  Future<List<NutritionalAlertModel>> getNutritionalAlerts(String bovineId) async {
    if (kIsWeb) return [];
    try {
      final db = await AppDatabase.database;
      final result = await db.query(
        'nutritional_alerts',
        where: 'bovineId = ?',
        whereArgs: [bovineId],
      );
      return result.map((json) => NutritionalAlertModel.fromJson(json)).toList();
    } catch (_) {
      return [];
    }
  }
}
