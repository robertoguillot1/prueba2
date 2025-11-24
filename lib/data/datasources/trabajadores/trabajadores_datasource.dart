import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/storage_keys.dart';
import '../../models/trabajadores/trabajador_model.dart';

/// Data source local para Trabajadores
abstract class TrabajadoresDataSource {
  Future<List<TrabajadorModel>> getAllTrabajadores(String farmId);
  Future<TrabajadorModel> getTrabajadorById(String id, String farmId);
  Future<TrabajadorModel> createTrabajador(TrabajadorModel trabajador);
  Future<TrabajadorModel> updateTrabajador(TrabajadorModel trabajador);
  Future<void> deleteTrabajador(String id, String farmId);
  Future<List<TrabajadorModel>> getTrabajadoresActivos(String farmId);
  Future<List<TrabajadorModel>> searchTrabajadores(String farmId, String query);
}

class TrabajadoresDataSourceImpl implements TrabajadoresDataSource {
  final SharedPreferences prefs;

  TrabajadoresDataSourceImpl(this.prefs);

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
}



