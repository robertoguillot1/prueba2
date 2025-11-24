import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/storage_keys.dart';
import '../../models/porcinos/cerdo_model.dart';

/// Data source local para Cerdos
abstract class CerdosDataSource {
  Future<List<CerdoModel>> getAllCerdos(String farmId);
  Future<CerdoModel> getCerdoById(String id, String farmId);
  Future<CerdoModel> createCerdo(CerdoModel cerdo);
  Future<CerdoModel> updateCerdo(CerdoModel cerdo);
  Future<void> deleteCerdo(String id, String farmId);
  Future<List<CerdoModel>> getCerdosByStage(String farmId, String stage);
  Future<List<CerdoModel>> searchCerdos(String farmId, String query);
}

class CerdosDataSourceImpl implements CerdosDataSource {
  final SharedPreferences prefs;

  CerdosDataSourceImpl(this.prefs);

  @override
  Future<List<CerdoModel>> getAllCerdos(String farmId) async {
    try {
      final key = StorageKeys.cerdosKey(farmId);
      final jsonString = prefs.getString(key);
      
      if (jsonString == null) return [];
      
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((json) => CerdoModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheFailure('Error al obtener cerdos: $e');
    }
  }

  @override
  Future<CerdoModel> getCerdoById(String id, String farmId) async {
    try {
      final cerdos = await getAllCerdos(farmId);
      return cerdos.firstWhere(
        (c) => c.id == id,
        orElse: () => throw CacheFailure('Cerdo no encontrado'),
      );
    } catch (e) {
      if (e is CacheFailure) rethrow;
      throw CacheFailure('Error al obtener cerdo: $e');
    }
  }

  @override
  Future<CerdoModel> createCerdo(CerdoModel cerdo) async {
    try {
      if (!cerdo.isValid) {
        throw ValidationFailure('Datos de cerdo inválidos');
      }
      
      final cerdos = await getAllCerdos(cerdo.farmId);
      
      if (cerdos.any((c) => c.id == cerdo.id)) {
        throw ValidationFailure('Ya existe un cerdo con este ID');
      }
      
      cerdos.add(cerdo);
      await _saveCerdos(cerdo.farmId, cerdos);
      
      return cerdo;
    } catch (e) {
      if (e is Failure) rethrow;
      throw CacheFailure('Error al crear cerdo: $e');
    }
  }

  @override
  Future<CerdoModel> updateCerdo(CerdoModel cerdo) async {
    try {
      if (!cerdo.isValid) {
        throw ValidationFailure('Datos de cerdo inválidos');
      }
      
      final cerdos = await getAllCerdos(cerdo.farmId);
      final index = cerdos.indexWhere((c) => c.id == cerdo.id);
      
      if (index == -1) {
        throw CacheFailure('Cerdo no encontrado para actualizar');
      }
      
      cerdos[index] = cerdo;
      await _saveCerdos(cerdo.farmId, cerdos);
      
      return cerdo;
    } catch (e) {
      if (e is Failure) rethrow;
      throw CacheFailure('Error al actualizar cerdo: $e');
    }
  }

  @override
  Future<void> deleteCerdo(String id, String farmId) async {
    try {
      final cerdos = await getAllCerdos(farmId);
      cerdos.removeWhere((c) => c.id == id);
      await _saveCerdos(farmId, cerdos);
    } catch (e) {
      throw CacheFailure('Error al eliminar cerdo: $e');
    }
  }

  @override
  Future<List<CerdoModel>> getCerdosByStage(String farmId, String stage) async {
    try {
      final cerdos = await getAllCerdos(farmId);
      return cerdos.where((c) => c.feedingStage.name == stage).toList();
    } catch (e) {
      throw CacheFailure('Error al filtrar cerdos por etapa: $e');
    }
  }

  @override
  Future<List<CerdoModel>> searchCerdos(String farmId, String query) async {
    try {
      final cerdos = await getAllCerdos(farmId);
      final lowerQuery = query.toLowerCase();
      
      return cerdos.where((c) {
        return (c.identification?.toLowerCase().contains(lowerQuery) ?? false) ||
               c.id.toLowerCase().contains(lowerQuery);
      }).toList();
    } catch (e) {
      throw CacheFailure('Error al buscar cerdos: $e');
    }
  }

  Future<void> _saveCerdos(String farmId, List<CerdoModel> cerdos) async {
    final key = StorageKeys.cerdosKey(farmId);
    final jsonList = cerdos.map((c) => c.toJson()).toList();
    await prefs.setString(key, json.encode(jsonList));
  }
}



