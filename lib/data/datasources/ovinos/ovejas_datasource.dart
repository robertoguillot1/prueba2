import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/storage_keys.dart';
import '../../models/ovinos/oveja_model.dart';

/// Data source local para Ovejas usando SharedPreferences
abstract class OvejasDataSource {
  Future<List<OvejaModel>> getAllOvejas(String farmId);
  Future<OvejaModel> getOvejaById(String id, String farmId);
  Future<OvejaModel> createOveja(OvejaModel oveja);
  Future<OvejaModel> updateOveja(OvejaModel oveja);
  Future<void> deleteOveja(String id, String farmId);
  Future<List<OvejaModel>> getOvejasByEstadoReproductivo(String farmId, String estado);
  Future<List<OvejaModel>> searchOvejas(String farmId, String query);
}

class OvejasDataSourceImpl implements OvejasDataSource {
  final SharedPreferences prefs;

  OvejasDataSourceImpl(this.prefs);

  @override
  Future<List<OvejaModel>> getAllOvejas(String farmId) async {
    try {
      final key = StorageKeys.ovejasKey(farmId);
      final jsonString = prefs.getString(key);
      
      if (jsonString == null) return [];
      
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((json) => OvejaModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheFailure('Error al obtener ovejas: $e');
    }
  }

  @override
  Future<OvejaModel> getOvejaById(String id, String farmId) async {
    try {
      final ovejas = await getAllOvejas(farmId);
      final oveja = ovejas.firstWhere(
        (o) => o.id == id,
        orElse: () => throw CacheFailure('Oveja no encontrada'),
      );
      return oveja;
    } catch (e) {
      if (e is CacheFailure) rethrow;
      throw CacheFailure('Error al obtener oveja: $e');
    }
  }

  @override
  Future<OvejaModel> createOveja(OvejaModel oveja) async {
    try {
      if (!oveja.isValid) {
        throw ValidationFailure('Datos de oveja inválidos');
      }
      
      final ovejas = await getAllOvejas(oveja.farmId);
      
      // Verificar que no exista otra oveja con el mismo ID
      if (ovejas.any((o) => o.id == oveja.id)) {
        throw ValidationFailure('Ya existe una oveja con este ID');
      }
      
      ovejas.add(oveja);
      await _saveOvejas(oveja.farmId, ovejas);
      
      return oveja;
    } catch (e) {
      if (e is Failure) rethrow;
      throw CacheFailure('Error al crear oveja: $e');
    }
  }

  @override
  Future<OvejaModel> updateOveja(OvejaModel oveja) async {
    try {
      if (!oveja.isValid) {
        throw ValidationFailure('Datos de oveja inválidos');
      }
      
      final ovejas = await getAllOvejas(oveja.farmId);
      final index = ovejas.indexWhere((o) => o.id == oveja.id);
      
      if (index == -1) {
        throw CacheFailure('Oveja no encontrada para actualizar');
      }
      
      ovejas[index] = oveja;
      await _saveOvejas(oveja.farmId, ovejas);
      
      return oveja;
    } catch (e) {
      if (e is Failure) rethrow;
      throw CacheFailure('Error al actualizar oveja: $e');
    }
  }

  @override
  Future<void> deleteOveja(String id, String farmId) async {
    try {
      final ovejas = await getAllOvejas(farmId);
      ovejas.removeWhere((o) => o.id == id);
      await _saveOvejas(farmId, ovejas);
    } catch (e) {
      throw CacheFailure('Error al eliminar oveja: $e');
    }
  }

  @override
  Future<List<OvejaModel>> getOvejasByEstadoReproductivo(String farmId, String estado) async {
    try {
      final ovejas = await getAllOvejas(farmId);
      return ovejas.where((o) {
        if (estado == 'gestante') {
          return o.estadoReproductivo?.name == 'gestante';
        } else if (estado == 'lactante') {
          return o.estadoReproductivo?.name == 'lactante';
        } else if (estado == 'vacia') {
          return o.estadoReproductivo?.name == 'vacia' || o.estadoReproductivo == null;
        }
        return true;
      }).toList();
    } catch (e) {
      throw CacheFailure('Error al filtrar ovejas por estado: $e');
    }
  }

  @override
  Future<List<OvejaModel>> searchOvejas(String farmId, String query) async {
    try {
      final ovejas = await getAllOvejas(farmId);
      final lowerQuery = query.toLowerCase();
      
      return ovejas.where((o) {
        return (o.name?.toLowerCase().contains(lowerQuery) ?? false) ||
               (o.identification?.toLowerCase().contains(lowerQuery) ?? false) ||
               o.id.toLowerCase().contains(lowerQuery);
      }).toList();
    } catch (e) {
      throw CacheFailure('Error al buscar ovejas: $e');
    }
  }

  Future<void> _saveOvejas(String farmId, List<OvejaModel> ovejas) async {
    final key = StorageKeys.ovejasKey(farmId);
    final jsonList = ovejas.map((o) => o.toJson()).toList();
    await prefs.setString(key, json.encode(jsonList));
  }
}

