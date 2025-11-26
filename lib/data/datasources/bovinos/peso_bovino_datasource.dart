import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/storage_keys.dart';
import '../../models/bovinos/peso_bovino_model.dart';

/// Data source local para Peso de Bovino
abstract class PesoBovinoDataSource {
  Future<List<PesoBovinoModel>> getAllPesos(String farmId);
  Future<PesoBovinoModel> getPesoById(String id, String farmId);
  Future<PesoBovinoModel> createPeso(PesoBovinoModel peso);
  Future<PesoBovinoModel> updatePeso(PesoBovinoModel peso);
  Future<void> deletePeso(String id, String farmId);
  Future<List<PesoBovinoModel>> getPesosByBovino(String bovinoId, String farmId);
}

class PesoBovinoDataSourceImpl implements PesoBovinoDataSource {
  final SharedPreferences prefs;

  PesoBovinoDataSourceImpl(this.prefs);

  @override
  Future<List<PesoBovinoModel>> getAllPesos(String farmId) async {
    try {
      final key = StorageKeys.pesoBovinoKey(farmId);
      final jsonString = prefs.getString(key);
      
      if (jsonString == null) return [];
      
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((json) => PesoBovinoModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheFailure('Error al obtener registros de peso: $e');
    }
  }

  @override
  Future<PesoBovinoModel> getPesoById(String id, String farmId) async {
    try {
      final pesos = await getAllPesos(farmId);
      return pesos.firstWhere(
        (p) => p.id == id,
        orElse: () => throw CacheFailure('Registro de peso no encontrado'),
      );
    } catch (e) {
      if (e is CacheFailure) rethrow;
      throw CacheFailure('Error al obtener peso: $e');
    }
  }

  @override
  Future<PesoBovinoModel> createPeso(PesoBovinoModel peso) async {
    try {
      if (!peso.isValid) {
        throw ValidationFailure('Datos de peso inválidos');
      }
      
      final pesos = await getAllPesos(peso.farmId);
      pesos.add(peso);
      await _savePesos(peso.farmId, pesos);
      
      return peso;
    } catch (e) {
      if (e is Failure) rethrow;
      throw CacheFailure('Error al crear registro de peso: $e');
    }
  }

  @override
  Future<PesoBovinoModel> updatePeso(PesoBovinoModel peso) async {
    try {
      if (!peso.isValid) {
        throw ValidationFailure('Datos de peso inválidos');
      }
      
      final pesos = await getAllPesos(peso.farmId);
      final index = pesos.indexWhere((p) => p.id == peso.id);
      
      if (index == -1) {
        throw CacheFailure('Registro de peso no encontrado');
      }
      
      pesos[index] = peso;
      await _savePesos(peso.farmId, pesos);
      
      return peso;
    } catch (e) {
      if (e is Failure) rethrow;
      throw CacheFailure('Error al actualizar peso: $e');
    }
  }

  @override
  Future<void> deletePeso(String id, String farmId) async {
    try {
      final pesos = await getAllPesos(farmId);
      pesos.removeWhere((p) => p.id == id);
      await _savePesos(farmId, pesos);
    } catch (e) {
      throw CacheFailure('Error al eliminar peso: $e');
    }
  }

  @override
  Future<List<PesoBovinoModel>> getPesosByBovino(String bovinoId, String farmId) async {
    try {
      final pesos = await getAllPesos(farmId);
      return pesos
          .where((p) => p.bovinoId == bovinoId)
          .toList()
        ..sort((a, b) => b.recordDate.compareTo(a.recordDate));
    } catch (e) {
      throw CacheFailure('Error al obtener pesos del bovino: $e');
    }
  }

  Future<void> _savePesos(String farmId, List<PesoBovinoModel> pesos) async {
    try {
      final key = StorageKeys.pesoBovinoKey(farmId);
      final jsonString = json.encode(pesos.map((p) => p.toJson()).toList());
      await prefs.setString(key, jsonString);
    } catch (e) {
      throw CacheFailure('Error al guardar pesos: $e');
    }
  }
}


