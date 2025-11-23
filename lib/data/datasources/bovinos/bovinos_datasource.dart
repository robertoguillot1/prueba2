import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/storage_keys.dart';
import '../../models/bovinos/bovino_model.dart';

/// Data source local para Bovinos
abstract class BovinosDataSource {
  Future<List<BovinoModel>> getAllBovinos(String farmId);
  Future<BovinoModel> getBovinoById(String id, String farmId);
  Future<BovinoModel> createBovino(BovinoModel bovino);
  Future<BovinoModel> updateBovino(BovinoModel bovino);
  Future<void> deleteBovino(String id, String farmId);
  Future<List<BovinoModel>> getBovinosByCategory(String farmId, String category);
  Future<List<BovinoModel>> searchBovinos(String farmId, String query);
}

class BovinosDataSourceImpl implements BovinosDataSource {
  final SharedPreferences prefs;

  BovinosDataSourceImpl(this.prefs);

  @override
  Future<List<BovinoModel>> getAllBovinos(String farmId) async {
    try {
      final key = StorageKeys.bovinosKey(farmId);
      final jsonString = prefs.getString(key);
      
      if (jsonString == null) return [];
      
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((json) => BovinoModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheFailure('Error al obtener bovinos: $e');
    }
  }

  @override
  Future<BovinoModel> getBovinoById(String id, String farmId) async {
    try {
      final bovinos = await getAllBovinos(farmId);
      return bovinos.firstWhere(
        (b) => b.id == id,
        orElse: () => throw CacheFailure('Bovino no encontrado'),
      );
    } catch (e) {
      if (e is CacheFailure) rethrow;
      throw CacheFailure('Error al obtener bovino: $e');
    }
  }

  @override
  Future<BovinoModel> createBovino(BovinoModel bovino) async {
    try {
      if (!bovino.isValid) {
        throw ValidationFailure('Datos de bovino inválidos');
      }
      
      final bovinos = await getAllBovinos(bovino.farmId);
      
      if (bovinos.any((b) => b.id == bovino.id)) {
        throw ValidationFailure('Ya existe un bovino con este ID');
      }
      
      bovinos.add(bovino);
      await _saveBovinos(bovino.farmId, bovinos);
      
      return bovino;
    } catch (e) {
      if (e is Failure) rethrow;
      throw CacheFailure('Error al crear bovino: $e');
    }
  }

  @override
  Future<BovinoModel> updateBovino(BovinoModel bovino) async {
    try {
      if (!bovino.isValid) {
        throw ValidationFailure('Datos de bovino inválidos');
      }
      
      final bovinos = await getAllBovinos(bovino.farmId);
      final index = bovinos.indexWhere((b) => b.id == bovino.id);
      
      if (index == -1) {
        throw CacheFailure('Bovino no encontrado para actualizar');
      }
      
      bovinos[index] = bovino;
      await _saveBovinos(bovino.farmId, bovinos);
      
      return bovino;
    } catch (e) {
      if (e is Failure) rethrow;
      throw CacheFailure('Error al actualizar bovino: $e');
    }
  }

  @override
  Future<void> deleteBovino(String id, String farmId) async {
    try {
      final bovinos = await getAllBovinos(farmId);
      bovinos.removeWhere((b) => b.id == id);
      await _saveBovinos(farmId, bovinos);
    } catch (e) {
      throw CacheFailure('Error al eliminar bovino: $e');
    }
  }

  @override
  Future<List<BovinoModel>> getBovinosByCategory(String farmId, String category) async {
    try {
      final bovinos = await getAllBovinos(farmId);
      return bovinos.where((b) => b.category.name == category).toList();
    } catch (e) {
      throw CacheFailure('Error al filtrar bovinos por categoría: $e');
    }
  }

  @override
  Future<List<BovinoModel>> searchBovinos(String farmId, String query) async {
    try {
      final bovinos = await getAllBovinos(farmId);
      final lowerQuery = query.toLowerCase();
      
      return bovinos.where((b) {
        return (b.name?.toLowerCase().contains(lowerQuery) ?? false) ||
               (b.identification?.toLowerCase().contains(lowerQuery) ?? false) ||
               b.id.toLowerCase().contains(lowerQuery);
      }).toList();
    } catch (e) {
      throw CacheFailure('Error al buscar bovinos: $e');
    }
  }

  Future<void> _saveBovinos(String farmId, List<BovinoModel> bovinos) async {
    final key = StorageKeys.bovinosKey(farmId);
    final jsonList = bovinos.map((b) => b.toJson()).toList();
    await prefs.setString(key, json.encode(jsonList));
  }
}


