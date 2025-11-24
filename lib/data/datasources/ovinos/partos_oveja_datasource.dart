import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/storage_keys.dart';
import '../../models/ovinos/parto_oveja_model.dart';

/// Data source local para Partos de Oveja
abstract class PartosOvejaDataSource {
  Future<List<PartoOvejaModel>> getAllPartos(String farmId);
  Future<PartoOvejaModel> getPartoById(String id, String farmId);
  Future<PartoOvejaModel> createParto(PartoOvejaModel parto);
  Future<PartoOvejaModel> updateParto(PartoOvejaModel parto);
  Future<void> deleteParto(String id, String farmId);
  Future<List<PartoOvejaModel>> getPartosByOveja(String ovejaId, String farmId);
  Future<List<PartoOvejaModel>> getPartosByFecha(String farmId, DateTime fechaInicio, DateTime fechaFin);
}

class PartosOvejaDataSourceImpl implements PartosOvejaDataSource {
  final SharedPreferences prefs;

  PartosOvejaDataSourceImpl(this.prefs);

  @override
  Future<List<PartoOvejaModel>> getAllPartos(String farmId) async {
    try {
      final key = StorageKeys.partosOvejaKey(farmId);
      final jsonString = prefs.getString(key);
      
      if (jsonString == null) return [];
      
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((json) => PartoOvejaModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheFailure('Error al obtener partos: $e');
    }
  }

  @override
  Future<PartoOvejaModel> getPartoById(String id, String farmId) async {
    try {
      final partos = await getAllPartos(farmId);
      return partos.firstWhere(
        (p) => p.id == id,
        orElse: () => throw CacheFailure('Parto no encontrado'),
      );
    } catch (e) {
      if (e is CacheFailure) rethrow;
      throw CacheFailure('Error al obtener parto: $e');
    }
  }

  @override
  Future<PartoOvejaModel> createParto(PartoOvejaModel parto) async {
    try {
      if (!parto.isValid) {
        throw ValidationFailure('Datos de parto inválidos');
      }
      
      final partos = await getAllPartos(parto.farmId);
      partos.add(parto);
      await _savePartos(parto.farmId, partos);
      
      return parto;
    } catch (e) {
      if (e is Failure) rethrow;
      throw CacheFailure('Error al crear parto: $e');
    }
  }

  @override
  Future<PartoOvejaModel> updateParto(PartoOvejaModel parto) async {
    try {
      if (!parto.isValid) {
        throw ValidationFailure('Datos de parto inválidos');
      }
      
      final partos = await getAllPartos(parto.farmId);
      final index = partos.indexWhere((p) => p.id == parto.id);
      
      if (index == -1) {
        throw CacheFailure('Parto no encontrado para actualizar');
      }
      
      partos[index] = parto;
      await _savePartos(parto.farmId, partos);
      
      return parto;
    } catch (e) {
      if (e is Failure) rethrow;
      throw CacheFailure('Error al actualizar parto: $e');
    }
  }

  @override
  Future<void> deleteParto(String id, String farmId) async {
    try {
      final partos = await getAllPartos(farmId);
      partos.removeWhere((p) => p.id == id);
      await _savePartos(farmId, partos);
    } catch (e) {
      throw CacheFailure('Error al eliminar parto: $e');
    }
  }

  @override
  Future<List<PartoOvejaModel>> getPartosByOveja(String ovejaId, String farmId) async {
    try {
      final partos = await getAllPartos(farmId);
      return partos.where((p) => p.ovejaId == ovejaId).toList()
        ..sort((a, b) => b.fechaParto.compareTo(a.fechaParto));
    } catch (e) {
      throw CacheFailure('Error al obtener partos por oveja: $e');
    }
  }

  @override
  Future<List<PartoOvejaModel>> getPartosByFecha(String farmId, DateTime fechaInicio, DateTime fechaFin) async {
    try {
      final partos = await getAllPartos(farmId);
      return partos.where((p) {
        return p.fechaParto.isAfter(fechaInicio.subtract(const Duration(days: 1))) &&
               p.fechaParto.isBefore(fechaFin.add(const Duration(days: 1)));
      }).toList()
        ..sort((a, b) => b.fechaParto.compareTo(a.fechaParto));
    } catch (e) {
      throw CacheFailure('Error al obtener partos por fecha: $e');
    }
  }

  Future<void> _savePartos(String farmId, List<PartoOvejaModel> partos) async {
    final key = StorageKeys.partosOvejaKey(farmId);
    final jsonList = partos.map((p) => p.toJson()).toList();
    await prefs.setString(key, json.encode(jsonList));
  }
}



