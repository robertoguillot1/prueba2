import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/storage_keys.dart';
import '../../models/avicultura/gallina_model.dart';

/// Data source local para Gallinas
abstract class GallinasDataSource {
  Future<List<GallinaModel>> getAllGallinas(String farmId);
  Future<GallinaModel> getGallinaById(String id, String farmId);
  Future<GallinaModel> createGallina(GallinaModel gallina);
  Future<GallinaModel> updateGallina(GallinaModel gallina);
  Future<void> deleteGallina(String id, String farmId);
  Future<List<GallinaModel>> getGallinasByLote(String loteId, String farmId);
  Future<List<GallinaModel>> searchGallinas(String farmId, String query);
}

class GallinasDataSourceImpl implements GallinasDataSource {
  final SharedPreferences prefs;

  GallinasDataSourceImpl(this.prefs);

  @override
  Future<List<GallinaModel>> getAllGallinas(String farmId) async {
    try {
      final key = StorageKeys.gallinasKey(farmId);
      final jsonString = prefs.getString(key);
      
      if (jsonString == null) return [];
      
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((json) => GallinaModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheFailure('Error al obtener gallinas: $e');
    }
  }

  @override
  Future<GallinaModel> getGallinaById(String id, String farmId) async {
    try {
      final gallinas = await getAllGallinas(farmId);
      return gallinas.firstWhere(
        (g) => g.id == id,
        orElse: () => throw CacheFailure('Gallina no encontrada'),
      );
    } catch (e) {
      if (e is CacheFailure) rethrow;
      throw CacheFailure('Error al obtener gallina: $e');
    }
  }

  @override
  Future<GallinaModel> createGallina(GallinaModel gallina) async {
    try {
      if (!gallina.isValid) {
        throw ValidationFailure('Datos de gallina inválidos');
      }
      
      final gallinas = await getAllGallinas(gallina.farmId);
      
      if (gallinas.any((g) => g.id == gallina.id)) {
        throw ValidationFailure('Ya existe una gallina con este ID');
      }
      
      gallinas.add(gallina);
      await _saveGallinas(gallina.farmId, gallinas);
      
      return gallina;
    } catch (e) {
      if (e is Failure) rethrow;
      throw CacheFailure('Error al crear gallina: $e');
    }
  }

  @override
  Future<GallinaModel> updateGallina(GallinaModel gallina) async {
    try {
      if (!gallina.isValid) {
        throw ValidationFailure('Datos de gallina inválidos');
      }
      
      final gallinas = await getAllGallinas(gallina.farmId);
      final index = gallinas.indexWhere((g) => g.id == gallina.id);
      
      if (index == -1) {
        throw CacheFailure('Gallina no encontrada para actualizar');
      }
      
      gallinas[index] = gallina;
      await _saveGallinas(gallina.farmId, gallinas);
      
      return gallina;
    } catch (e) {
      if (e is Failure) rethrow;
      throw CacheFailure('Error al actualizar gallina: $e');
    }
  }

  @override
  Future<void> deleteGallina(String id, String farmId) async {
    try {
      final gallinas = await getAllGallinas(farmId);
      gallinas.removeWhere((g) => g.id == id);
      await _saveGallinas(farmId, gallinas);
    } catch (e) {
      throw CacheFailure('Error al eliminar gallina: $e');
    }
  }

  @override
  Future<List<GallinaModel>> getGallinasByLote(String loteId, String farmId) async {
    try {
      final gallinas = await getAllGallinas(farmId);
      return gallinas.where((g) => g.loteId == loteId).toList();
    } catch (e) {
      throw CacheFailure('Error al obtener gallinas por lote: $e');
    }
  }

  @override
  Future<List<GallinaModel>> searchGallinas(String farmId, String query) async {
    try {
      final gallinas = await getAllGallinas(farmId);
      final lowerQuery = query.toLowerCase();
      
      return gallinas.where((g) {
        return (g.name?.toLowerCase().contains(lowerQuery) ?? false) ||
               (g.identification?.toLowerCase().contains(lowerQuery) ?? false) ||
               g.id.toLowerCase().contains(lowerQuery);
      }).toList();
    } catch (e) {
      throw CacheFailure('Error al buscar gallinas: $e');
    }
  }

  Future<void> _saveGallinas(String farmId, List<GallinaModel> gallinas) async {
    final key = StorageKeys.gallinasKey(farmId);
    final jsonList = gallinas.map((g) => g.toJson()).toList();
    await prefs.setString(key, json.encode(jsonList));
  }
}

