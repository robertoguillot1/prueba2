import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/storage_keys.dart';
import '../../models/ovinos/enfermedad_oveja_model.dart';

/// Data source local para Enfermedades de Oveja
abstract class EnfermedadesOvejaDataSource {
  Future<List<EnfermedadOvejaModel>> getAllEnfermedades(String farmId);
  Future<EnfermedadOvejaModel> getEnfermedadById(String id, String farmId);
  Future<EnfermedadOvejaModel> createEnfermedad(EnfermedadOvejaModel enfermedad);
  Future<EnfermedadOvejaModel> updateEnfermedad(EnfermedadOvejaModel enfermedad);
  Future<void> deleteEnfermedad(String id, String farmId);
  Future<List<EnfermedadOvejaModel>> getEnfermedadesByOveja(String ovejaId, String farmId);
  Future<List<EnfermedadOvejaModel>> getEnfermedadesActivas(String farmId);
}

class EnfermedadesOvejaDataSourceImpl implements EnfermedadesOvejaDataSource {
  final SharedPreferences prefs;

  EnfermedadesOvejaDataSourceImpl(this.prefs);

  @override
  Future<List<EnfermedadOvejaModel>> getAllEnfermedades(String farmId) async {
    try {
      final key = StorageKeys.enfermedadesOvejaKey(farmId);
      final jsonString = prefs.getString(key);
      
      if (jsonString == null) return [];
      
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((json) => EnfermedadOvejaModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheFailure('Error al obtener enfermedades: $e');
    }
  }

  @override
  Future<EnfermedadOvejaModel> getEnfermedadById(String id, String farmId) async {
    try {
      final enfermedades = await getAllEnfermedades(farmId);
      return enfermedades.firstWhere(
        (e) => e.id == id,
        orElse: () => throw CacheFailure('Enfermedad no encontrada'),
      );
    } catch (e) {
      if (e is CacheFailure) rethrow;
      throw CacheFailure('Error al obtener enfermedad: $e');
    }
  }

  @override
  Future<EnfermedadOvejaModel> createEnfermedad(EnfermedadOvejaModel enfermedad) async {
    try {
      if (!enfermedad.isValid) {
        throw ValidationFailure('Datos de enfermedad inválidos');
      }
      
      final enfermedades = await getAllEnfermedades(enfermedad.farmId);
      enfermedades.add(enfermedad);
      await _saveEnfermedades(enfermedad.farmId, enfermedades);
      
      return enfermedad;
    } catch (e) {
      if (e is Failure) rethrow;
      throw CacheFailure('Error al crear enfermedad: $e');
    }
  }

  @override
  Future<EnfermedadOvejaModel> updateEnfermedad(EnfermedadOvejaModel enfermedad) async {
    try {
      if (!enfermedad.isValid) {
        throw ValidationFailure('Datos de enfermedad inválidos');
      }
      
      final enfermedades = await getAllEnfermedades(enfermedad.farmId);
      final index = enfermedades.indexWhere((e) => e.id == enfermedad.id);
      
      if (index == -1) {
        throw CacheFailure('Enfermedad no encontrada para actualizar');
      }
      
      enfermedades[index] = enfermedad;
      await _saveEnfermedades(enfermedad.farmId, enfermedades);
      
      return enfermedad;
    } catch (e) {
      if (e is Failure) rethrow;
      throw CacheFailure('Error al actualizar enfermedad: $e');
    }
  }

  @override
  Future<void> deleteEnfermedad(String id, String farmId) async {
    try {
      final enfermedades = await getAllEnfermedades(farmId);
      enfermedades.removeWhere((e) => e.id == id);
      await _saveEnfermedades(farmId, enfermedades);
    } catch (e) {
      throw CacheFailure('Error al eliminar enfermedad: $e');
    }
  }

  @override
  Future<List<EnfermedadOvejaModel>> getEnfermedadesByOveja(String ovejaId, String farmId) async {
    try {
      final enfermedades = await getAllEnfermedades(farmId);
      return enfermedades.where((e) => e.ovejaId == ovejaId).toList()
        ..sort((a, b) => b.fechaDiagnostico.compareTo(a.fechaDiagnostico));
    } catch (e) {
      throw CacheFailure('Error al obtener enfermedades por oveja: $e');
    }
  }

  @override
  Future<List<EnfermedadOvejaModel>> getEnfermedadesActivas(String farmId) async {
    try {
      final enfermedades = await getAllEnfermedades(farmId);
      return enfermedades.where((e) => e.isActiva).toList()
        ..sort((a, b) => b.fechaDiagnostico.compareTo(a.fechaDiagnostico));
    } catch (e) {
      throw CacheFailure('Error al obtener enfermedades activas: $e');
    }
  }

  Future<void> _saveEnfermedades(String farmId, List<EnfermedadOvejaModel> enfermedades) async {
    final key = StorageKeys.enfermedadesOvejaKey(farmId);
    final jsonList = enfermedades.map((e) => e.toJson()).toList();
    await prefs.setString(key, json.encode(jsonList));
  }
}

