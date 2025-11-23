import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/storage_keys.dart';
import '../../models/ovinos/registro_peso_oveja_model.dart';

/// Data source local para Registros de Peso de Oveja
abstract class RegistrosPesoOvejaDataSource {
  Future<List<RegistroPesoOvejaModel>> getAllRegistros(String farmId);
  Future<RegistroPesoOvejaModel> getRegistroById(String id, String farmId);
  Future<RegistroPesoOvejaModel> createRegistro(RegistroPesoOvejaModel registro);
  Future<RegistroPesoOvejaModel> updateRegistro(RegistroPesoOvejaModel registro);
  Future<void> deleteRegistro(String id, String farmId);
  Future<List<RegistroPesoOvejaModel>> getRegistrosByOveja(String ovejaId, String farmId);
  Future<List<RegistroPesoOvejaModel>> getRegistrosByFecha(String farmId, DateTime fechaInicio, DateTime fechaFin);
}

class RegistrosPesoOvejaDataSourceImpl implements RegistrosPesoOvejaDataSource {
  final SharedPreferences prefs;

  RegistrosPesoOvejaDataSourceImpl(this.prefs);

  @override
  Future<List<RegistroPesoOvejaModel>> getAllRegistros(String farmId) async {
    try {
      final key = StorageKeys.registrosPesoOvejaKey(farmId);
      final jsonString = prefs.getString(key);
      
      if (jsonString == null) return [];
      
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((json) => RegistroPesoOvejaModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheFailure('Error al obtener registros de peso: $e');
    }
  }

  @override
  Future<RegistroPesoOvejaModel> getRegistroById(String id, String farmId) async {
    try {
      final registros = await getAllRegistros(farmId);
      return registros.firstWhere(
        (r) => r.id == id,
        orElse: () => throw CacheFailure('Registro no encontrado'),
      );
    } catch (e) {
      if (e is CacheFailure) rethrow;
      throw CacheFailure('Error al obtener registro: $e');
    }
  }

  @override
  Future<RegistroPesoOvejaModel> createRegistro(RegistroPesoOvejaModel registro) async {
    try {
      if (!registro.isValid) {
        throw ValidationFailure('Datos de registro inválidos');
      }
      
      final registros = await getAllRegistros(registro.farmId);
      registros.add(registro);
      await _saveRegistros(registro.farmId, registros);
      
      return registro;
    } catch (e) {
      if (e is Failure) rethrow;
      throw CacheFailure('Error al crear registro: $e');
    }
  }

  @override
  Future<RegistroPesoOvejaModel> updateRegistro(RegistroPesoOvejaModel registro) async {
    try {
      if (!registro.isValid) {
        throw ValidationFailure('Datos de registro inválidos');
      }
      
      final registros = await getAllRegistros(registro.farmId);
      final index = registros.indexWhere((r) => r.id == registro.id);
      
      if (index == -1) {
        throw CacheFailure('Registro no encontrado para actualizar');
      }
      
      registros[index] = registro;
      await _saveRegistros(registro.farmId, registros);
      
      return registro;
    } catch (e) {
      if (e is Failure) rethrow;
      throw CacheFailure('Error al actualizar registro: $e');
    }
  }

  @override
  Future<void> deleteRegistro(String id, String farmId) async {
    try {
      final registros = await getAllRegistros(farmId);
      registros.removeWhere((r) => r.id == id);
      await _saveRegistros(farmId, registros);
    } catch (e) {
      throw CacheFailure('Error al eliminar registro: $e');
    }
  }

  @override
  Future<List<RegistroPesoOvejaModel>> getRegistrosByOveja(String ovejaId, String farmId) async {
    try {
      final registros = await getAllRegistros(farmId);
      return registros.where((r) => r.ovejaId == ovejaId).toList()
        ..sort((a, b) => a.fechaRegistro.compareTo(b.fechaRegistro));
    } catch (e) {
      throw CacheFailure('Error al obtener registros por oveja: $e');
    }
  }

  @override
  Future<List<RegistroPesoOvejaModel>> getRegistrosByFecha(String farmId, DateTime fechaInicio, DateTime fechaFin) async {
    try {
      final registros = await getAllRegistros(farmId);
      return registros.where((r) {
        return r.fechaRegistro.isAfter(fechaInicio.subtract(const Duration(days: 1))) &&
               r.fechaRegistro.isBefore(fechaFin.add(const Duration(days: 1)));
      }).toList()
        ..sort((a, b) => a.fechaRegistro.compareTo(b.fechaRegistro));
    } catch (e) {
      throw CacheFailure('Error al obtener registros por fecha: $e');
    }
  }

  Future<void> _saveRegistros(String farmId, List<RegistroPesoOvejaModel> registros) async {
    final key = StorageKeys.registrosPesoOvejaKey(farmId);
    final jsonList = registros.map((r) => r.toJson()).toList();
    await prefs.setString(key, json.encode(jsonList));
  }
}

