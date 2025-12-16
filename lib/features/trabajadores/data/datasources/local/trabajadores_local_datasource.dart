import 'package:sqflite/sqflite.dart';
import '../../../../../../core/utils/result.dart';
import '../../../../../../core/errors/failures.dart';
import '../../../../../../data/database/app_database.dart';
import '../../models/pago_model.dart';
import '../../models/prestamo_model.dart';

/// Data source local para Trabajadores (Pagos y Préstamos) usando SQLite
abstract class TrabajadoresLocalDataSource {
  Future<Result<List<PagoModel>>> getPagosByWorker(String workerId);
  Future<Result<PagoModel>> savePago(PagoModel pago);
  Future<Result<PagoModel>> updatePago(PagoModel pago);
  Future<Result<void>> deletePago(String workerId, String pagoId);

  Future<Result<List<PrestamoModel>>> getPrestamosByWorker(String workerId);
  Future<Result<PrestamoModel>> savePrestamo(PrestamoModel prestamo);
  Future<Result<PrestamoModel>> updatePrestamo(PrestamoModel prestamo);
  Future<Result<void>> deletePrestamo(String workerId, String prestamoId);
}

class TrabajadoresLocalDataSourceImpl implements TrabajadoresLocalDataSource {
  @override
  Future<Result<List<PagoModel>>> getPagosByWorker(String workerId) async {
    try {
      final db = await AppDatabase.database;
      final maps = await db.query(
        'pagos',
        where: 'workerId = ?',
        whereArgs: [workerId],
        orderBy: 'date DESC',
      );
      final pagos = maps.map((map) => _mapToPagoModel(map)).toList();
      return Success(pagos);
    } catch (e) {
      return Error(CacheFailure('Error al obtener pagos: $e'));
    }
  }

  @override
  Future<Result<PagoModel>> savePago(PagoModel pago) async {
    try {
      final db = await AppDatabase.database;
      final json = _pagoModelToMap(pago);
      json['synced'] = 0; // Marcar como no sincronizado
      await db.insert(
        'pagos',
        json,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return Success(pago);
    } catch (e) {
      return Error(CacheFailure('Error al guardar pago: $e'));
    }
  }

  @override
  Future<Result<PagoModel>> updatePago(PagoModel pago) async {
    try {
      final db = await AppDatabase.database;
      final json = _pagoModelToMap(pago);
      json['synced'] = 0; // Marcar como no sincronizado
      await db.update(
        'pagos',
        json,
        where: 'id = ?',
        whereArgs: [pago.id],
      );
      return Success(pago);
    } catch (e) {
      return Error(CacheFailure('Error al actualizar pago: $e'));
    }
  }

  @override
  Future<Result<void>> deletePago(String workerId, String pagoId) async {
    try {
      final db = await AppDatabase.database;
      await db.delete(
        'pagos',
        where: 'workerId = ? AND id = ?',
        whereArgs: [workerId, pagoId],
      );
      return const Success(null);
    } catch (e) {
      return Error(CacheFailure('Error al eliminar pago: $e'));
    }
  }

  @override
  Future<Result<List<PrestamoModel>>> getPrestamosByWorker(String workerId) async {
    try {
      final db = await AppDatabase.database;
      final maps = await db.query(
        'prestamos',
        where: 'workerId = ?',
        whereArgs: [workerId],
        orderBy: 'date DESC',
      );
      final prestamos = maps.map((map) => _mapToPrestamoModel(map)).toList();
      return Success(prestamos);
    } catch (e) {
      return Error(CacheFailure('Error al obtener préstamos: $e'));
    }
  }

  @override
  Future<Result<PrestamoModel>> savePrestamo(PrestamoModel prestamo) async {
    try {
      final db = await AppDatabase.database;
      final json = _prestamoModelToMap(prestamo);
      json['synced'] = 0; // Marcar como no sincronizado
      await db.insert(
        'prestamos',
        json,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return Success(prestamo);
    } catch (e) {
      return Error(CacheFailure('Error al guardar préstamo: $e'));
    }
  }

  @override
  Future<Result<PrestamoModel>> updatePrestamo(PrestamoModel prestamo) async {
    try {
      final db = await AppDatabase.database;
      final json = _prestamoModelToMap(prestamo);
      json['synced'] = 0; // Marcar como no sincronizado
      await db.update(
        'prestamos',
        json,
        where: 'id = ?',
        whereArgs: [prestamo.id],
      );
      return Success(prestamo);
    } catch (e) {
      return Error(CacheFailure('Error al actualizar préstamo: $e'));
    }
  }

  @override
  Future<Result<void>> deletePrestamo(String workerId, String prestamoId) async {
    try {
      final db = await AppDatabase.database;
      await db.delete(
        'prestamos',
        where: 'workerId = ? AND id = ?',
        whereArgs: [workerId, prestamoId],
      );
      return const Success(null);
    } catch (e) {
      return Error(CacheFailure('Error al eliminar préstamo: $e'));
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

