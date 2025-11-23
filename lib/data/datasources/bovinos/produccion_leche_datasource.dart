import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/storage_keys.dart';
import '../../models/bovinos/produccion_leche_model.dart';

/// Data source local para Producción de Leche
abstract class ProduccionLecheDataSource {
  Future<List<ProduccionLecheModel>> getAllProducciones(String farmId);
  Future<ProduccionLecheModel> getProduccionById(String id, String farmId);
  Future<ProduccionLecheModel> createProduccion(ProduccionLecheModel produccion);
  Future<ProduccionLecheModel> updateProduccion(ProduccionLecheModel produccion);
  Future<void> deleteProduccion(String id, String farmId);
  Future<List<ProduccionLecheModel>> getProduccionesByBovino(String bovinoId, String farmId);
  Future<List<ProduccionLecheModel>> getProduccionesByFecha(String farmId, DateTime fechaInicio, DateTime fechaFin);
}

class ProduccionLecheDataSourceImpl implements ProduccionLecheDataSource {
  final SharedPreferences prefs;

  ProduccionLecheDataSourceImpl(this.prefs);

  @override
  Future<List<ProduccionLecheModel>> getAllProducciones(String farmId) async {
    try {
      final key = StorageKeys.produccionLecheKey(farmId);
      final jsonString = prefs.getString(key);
      
      if (jsonString == null) return [];
      
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((json) => ProduccionLecheModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheFailure('Error al obtener producciones de leche: $e');
    }
  }

  @override
  Future<ProduccionLecheModel> getProduccionById(String id, String farmId) async {
    try {
      final producciones = await getAllProducciones(farmId);
      return producciones.firstWhere(
        (p) => p.id == id,
        orElse: () => throw CacheFailure('Producción no encontrada'),
      );
    } catch (e) {
      if (e is CacheFailure) rethrow;
      throw CacheFailure('Error al obtener producción: $e');
    }
  }

  @override
  Future<ProduccionLecheModel> createProduccion(ProduccionLecheModel produccion) async {
    try {
      if (!produccion.isValid) {
        throw ValidationFailure('Datos de producción inválidos');
      }
      
      final producciones = await getAllProducciones(produccion.farmId);
      producciones.add(produccion);
      await _saveProducciones(produccion.farmId, producciones);
      
      return produccion;
    } catch (e) {
      if (e is Failure) rethrow;
      throw CacheFailure('Error al crear producción: $e');
    }
  }

  @override
  Future<ProduccionLecheModel> updateProduccion(ProduccionLecheModel produccion) async {
    try {
      if (!produccion.isValid) {
        throw ValidationFailure('Datos de producción inválidos');
      }
      
      final producciones = await getAllProducciones(produccion.farmId);
      final index = producciones.indexWhere((p) => p.id == produccion.id);
      
      if (index == -1) {
        throw CacheFailure('Producción no encontrada para actualizar');
      }
      
      producciones[index] = produccion;
      await _saveProducciones(produccion.farmId, producciones);
      
      return produccion;
    } catch (e) {
      if (e is Failure) rethrow;
      throw CacheFailure('Error al actualizar producción: $e');
    }
  }

  @override
  Future<void> deleteProduccion(String id, String farmId) async {
    try {
      final producciones = await getAllProducciones(farmId);
      producciones.removeWhere((p) => p.id == id);
      await _saveProducciones(farmId, producciones);
    } catch (e) {
      throw CacheFailure('Error al eliminar producción: $e');
    }
  }

  @override
  Future<List<ProduccionLecheModel>> getProduccionesByBovino(String bovinoId, String farmId) async {
    try {
      final producciones = await getAllProducciones(farmId);
      return producciones.where((p) => p.bovinoId == bovinoId).toList()
        ..sort((a, b) => b.recordDate.compareTo(a.recordDate));
    } catch (e) {
      throw CacheFailure('Error al obtener producciones por bovino: $e');
    }
  }

  @override
  Future<List<ProduccionLecheModel>> getProduccionesByFecha(String farmId, DateTime fechaInicio, DateTime fechaFin) async {
    try {
      final producciones = await getAllProducciones(farmId);
      return producciones.where((p) {
        return p.recordDate.isAfter(fechaInicio.subtract(const Duration(days: 1))) &&
               p.recordDate.isBefore(fechaFin.add(const Duration(days: 1)));
      }).toList()
        ..sort((a, b) => b.recordDate.compareTo(a.recordDate));
    } catch (e) {
      throw CacheFailure('Error al obtener producciones por fecha: $e');
    }
  }

  Future<void> _saveProducciones(String farmId, List<ProduccionLecheModel> producciones) async {
    final key = StorageKeys.produccionLecheKey(farmId);
    final jsonList = producciones.map((p) => p.toJson()).toList();
    await prefs.setString(key, json.encode(jsonList));
  }
}


