import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/storage_keys.dart';
import '../../../data/database/app_database.dart';
import '../../models/trabajadores/trabajador_model.dart';
import '../../../../features/trabajadores/data/models/pago_model.dart';
import '../../../../features/trabajadores/data/models/prestamo_model.dart';

/// Data source local para Trabajadores
abstract class TrabajadoresDataSource {
  Future<List<TrabajadorModel>> getAllTrabajadores(String farmId);
  Future<TrabajadorModel> getTrabajadorById(String id, String farmId);
  Future<TrabajadorModel> createTrabajador(TrabajadorModel trabajador);
  Future<TrabajadorModel> updateTrabajador(TrabajadorModel trabajador);
  Future<void> deleteTrabajador(String id, String farmId);
  Future<List<TrabajadorModel>> getTrabajadoresActivos(String farmId);
  Future<List<TrabajadorModel>> searchTrabajadores(String farmId, String query);

  // === PAGOS ===
  Future<List<PagoModel>> getPagosByTrabajador(String workerId);
  Future<PagoModel> createPago(PagoModel pago);

  // === PRESTAMOS ===
  Future<List<PrestamoModel>> getPrestamosByTrabajador(String workerId);
  Future<PrestamoModel> createPrestamo(PrestamoModel prestamo);
  Future<PrestamoModel> updatePrestamo(PrestamoModel prestamo);
}

class TrabajadoresDataSourceImpl implements TrabajadoresDataSource {
  final SharedPreferences prefs;

  TrabajadoresDataSourceImpl(this.prefs);

  // === IMPLEMENTATION TRABAJADORES (SharedPreferences) ===
  @override
  Future<List<TrabajadorModel>> getAllTrabajadores(String farmId) async {
    try {
      final key = StorageKeys.trabajadoresKey(farmId);
      final jsonString = prefs.getString(key);
      
      if (jsonString == null) return [];
      
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((json) => TrabajadorModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheFailure('Error al obtener trabajadores: $e');
    }
  }

  @override
  Future<TrabajadorModel> getTrabajadorById(String id, String farmId) async {
    try {
      final trabajadores = await getAllTrabajadores(farmId);
      return trabajadores.firstWhere(
        (t) => t.id == id,
        orElse: () => throw CacheFailure('Trabajador no encontrado'),
      );
    } catch (e) {
      if (e is CacheFailure) rethrow;
      throw CacheFailure('Error al obtener trabajador: $e');
    }
  }

  @override
  Future<TrabajadorModel> createTrabajador(TrabajadorModel trabajador) async {
    try {
      if (!trabajador.isValid) {
        throw ValidationFailure('Datos de trabajador inválidos');
      }
      
      final trabajadores = await getAllTrabajadores(trabajador.farmId);
      
      if (trabajadores.any((t) => t.id == trabajador.id)) {
        throw ValidationFailure('Ya existe un trabajador con este ID');
      }
      
      trabajadores.add(trabajador);
      await _saveTrabajadores(trabajador.farmId, trabajadores);
      
      return trabajador;
    } catch (e) {
      if (e is Failure) rethrow;
      throw CacheFailure('Error al crear trabajador: $e');
    }
  }

  @override
  Future<TrabajadorModel> updateTrabajador(TrabajadorModel trabajador) async {
    try {
      if (!trabajador.isValid) {
        throw ValidationFailure('Datos de trabajador inválidos');
      }
      
      final trabajadores = await getAllTrabajadores(trabajador.farmId);
      final index = trabajadores.indexWhere((t) => t.id == trabajador.id);
      
      if (index == -1) {
        throw CacheFailure('Trabajador no encontrado para actualizar');
      }
      
      trabajadores[index] = trabajador;
      await _saveTrabajadores(trabajador.farmId, trabajadores);
      
      return trabajador;
    } catch (e) {
      if (e is Failure) rethrow;
      throw CacheFailure('Error al actualizar trabajador: $e');
    }
  }

  @override
  Future<void> deleteTrabajador(String id, String farmId) async {
    try {
      final trabajadores = await getAllTrabajadores(farmId);
      trabajadores.removeWhere((t) => t.id == id);
      await _saveTrabajadores(farmId, trabajadores);
    } catch (e) {
      throw CacheFailure('Error al eliminar trabajador: $e');
    }
  }

  @override
  Future<List<TrabajadorModel>> getTrabajadoresActivos(String farmId) async {
    try {
      final trabajadores = await getAllTrabajadores(farmId);
      return trabajadores.where((t) => t.isActive).toList();
    } catch (e) {
      throw CacheFailure('Error al obtener trabajadores activos: $e');
    }
  }

  @override
  Future<List<TrabajadorModel>> searchTrabajadores(String farmId, String query) async {
    try {
      final trabajadores = await getAllTrabajadores(farmId);
      final lowerQuery = query.toLowerCase();
      
      return trabajadores.where((t) {
        return t.fullName.toLowerCase().contains(lowerQuery) ||
               t.identification.toLowerCase().contains(lowerQuery) ||
               t.position.toLowerCase().contains(lowerQuery);
      }).toList();
    } catch (e) {
      throw CacheFailure('Error al buscar trabajadores: $e');
    }
  }

  Future<void> _saveTrabajadores(String farmId, List<TrabajadorModel> trabajadores) async {
    final key = StorageKeys.trabajadoresKey(farmId);
    final jsonList = trabajadores.map((t) => t.toJson()).toList();
    await prefs.setString(key, json.encode(jsonList));
  }

  // === IMPLEMENTATION PAGOS (SQLite) ===
  @override
  Future<List<PagoModel>> getPagosByTrabajador(String workerId) async {
    try {
      final db = await AppDatabase.database;
      final result = await db.query(
        'pagos',
        where: 'workerId = ?',
        whereArgs: [workerId],
        orderBy: 'date DESC',
      );
      // Mapear manualmente porque los modelos ahora usan workerId/farmId
      return result.map((map) => _mapToPagoModel(map)).toList();
    } catch (e) {
      throw CacheFailure('Error al obtener pagos: $e');
    }
  }

  @override
  Future<PagoModel> createPago(PagoModel pago) async {
    try {
      final db = await AppDatabase.database;
      final json = _pagoModelToMap(pago);
      await db.insert(
        'pagos',
        json,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return pago;
    } catch (e) {
      throw CacheFailure('Error al crear pago: $e');
    }
  }

  // === IMPLEMENTATION PRESTAMOS (SQLite) ===
  @override
  Future<List<PrestamoModel>> getPrestamosByTrabajador(String workerId) async {
    try {
      final db = await AppDatabase.database;
      final result = await db.query(
        'prestamos',
        where: 'workerId = ?',
        whereArgs: [workerId],
        orderBy: 'date DESC',
      );
      // Mapear manualmente porque los modelos ahora usan workerId/farmId
      return result.map((map) => _mapToPrestamoModel(map)).toList();
    } catch (e) {
      throw CacheFailure('Error al obtener préstamos: $e');
    }
  }

  @override
  Future<PrestamoModel> createPrestamo(PrestamoModel prestamo) async {
    try {
      final db = await AppDatabase.database;
      final json = _prestamoModelToMap(prestamo);
      await db.insert(
        'prestamos',
        json,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return prestamo;
    } catch (e) {
      throw CacheFailure('Error al crear préstamo: $e');
    }
  }

  @override
  Future<PrestamoModel> updatePrestamo(PrestamoModel prestamo) async {
    try {
      final db = await AppDatabase.database;
      final json = _prestamoModelToMap(prestamo);
      await db.update(
        'prestamos',
        json,
        where: 'id = ?',
        whereArgs: [prestamo.id],
      );
      return prestamo;
    } catch (e) {
      throw CacheFailure('Error al actualizar préstamo: $e');
    }
  }

  /// Convierte un Map de SQLite a PagoModel
  PagoModel _mapToPagoModel(Map<String, dynamic> map) {
    return PagoModel(
      id: map['id'] as String,
      workerId: map['workerId'] as String,
      farmId: map['farmId'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      concept: map['concept'] as String,
      notes: map['notes'] as String?,
    );
  }

  /// Convierte PagoModel a Map para SQLite
  Map<String, dynamic> _pagoModelToMap(PagoModel pago) {
    return {
      'id': pago.id,
      'workerId': pago.workerId,
      'farmId': pago.farmId,
      'amount': pago.amount,
      'date': pago.date.toIso8601String(),
      'concept': pago.concept,
      'notes': pago.notes,
    };
  }

  /// Convierte un Map de SQLite a PrestamoModel
  PrestamoModel _mapToPrestamoModel(Map<String, dynamic> map) {
    return PrestamoModel(
      id: map['id'] as String,
      workerId: map['workerId'] as String,
      farmId: map['farmId'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      description: map['description'] as String,
      isPaid: (map['isPaid'] as int? ?? 0) == 1,
    );
  }

  /// Convierte PrestamoModel a Map para SQLite
  Map<String, dynamic> _prestamoModelToMap(PrestamoModel prestamo) {
    return {
      'id': prestamo.id,
      'workerId': prestamo.workerId,
      'farmId': prestamo.farmId,
      'amount': prestamo.amount,
      'date': prestamo.date.toIso8601String(),
      'description': prestamo.description,
      'isPaid': prestamo.isPaid ? 1 : 0,
    };
  }
}
