import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/storage_keys.dart';
import '../../../domain/entities/bovinos/evento_reproductivo.dart';
import '../../models/bovinos/evento_reproductivo_model.dart';

/// DataSource abstracto para Eventos Reproductivos
abstract class EventosReproductivosDataSource {
  /// Obtiene todos los eventos de un animal
  Future<List<EventoReproductivoModel>> getEventosByAnimal(
    String animalId,
    String farmId,
  );

  /// Obtiene todos los eventos de una finca
  Future<List<EventoReproductivoModel>> getAllEventos(String farmId);

  /// Obtiene un evento por su ID
  Future<EventoReproductivoModel> getEventoById(String id, String farmId);

  /// Crea un nuevo evento
  Future<EventoReproductivoModel> createEvento(EventoReproductivoModel evento);

  /// Actualiza un evento existente
  Future<EventoReproductivoModel> updateEvento(EventoReproductivoModel evento);

  /// Elimina un evento
  Future<void> deleteEvento(String id, String farmId);
}

class EventosReproductivosDataSourceImpl implements EventosReproductivosDataSource {
  final SharedPreferences prefs;

  EventosReproductivosDataSourceImpl(this.prefs);

  @override
  Future<List<EventoReproductivoModel>> getEventosByAnimal(
    String animalId,
    String farmId,
  ) async {
    try {
      final allEventos = await getAllEventos(farmId);
      return allEventos.where((e) => e.idAnimal == animalId).toList()
        ..sort((a, b) => b.fecha.compareTo(a.fecha));
    } catch (e) {
      throw CacheFailure('Error al obtener eventos del animal: $e');
    }
  }

  @override
  Future<List<EventoReproductivoModel>> getAllEventos(String farmId) async {
    try {
      final key = 'eventos_reproductivos_$farmId';
      final jsonString = prefs.getString(key);
      
      if (jsonString == null) return [];
      
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((json) => EventoReproductivoModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheFailure('Error al obtener eventos: $e');
    }
  }

  @override
  Future<EventoReproductivoModel> getEventoById(String id, String farmId) async {
    try {
      final eventos = await getAllEventos(farmId);
      return eventos.firstWhere(
        (e) => e.id == id,
        orElse: () => throw CacheFailure('Evento no encontrado'),
      );
    } catch (e) {
      if (e is CacheFailure) rethrow;
      throw CacheFailure('Error al obtener evento: $e');
    }
  }

  @override
  Future<EventoReproductivoModel> createEvento(EventoReproductivoModel evento) async {
    try {
      if (!evento.isValid) {
        throw ValidationFailure('Datos de evento inválidos');
      }
      
      final eventos = await getAllEventos(evento.farmId);
      
      if (eventos.any((e) => e.id == evento.id)) {
        throw ValidationFailure('Ya existe un evento con este ID');
      }
      
      eventos.add(evento);
      await _saveEventos(evento.farmId, eventos);
      
      return evento;
    } catch (e) {
      if (e is Failure) rethrow;
      throw CacheFailure('Error al crear evento: $e');
    }
  }

  @override
  Future<EventoReproductivoModel> updateEvento(EventoReproductivoModel evento) async {
    try {
      if (!evento.isValid) {
        throw ValidationFailure('Datos de evento inválidos');
      }
      
      final eventos = await getAllEventos(evento.farmId);
      final index = eventos.indexWhere((e) => e.id == evento.id);
      
      if (index == -1) {
        throw CacheFailure('Evento no encontrado para actualizar');
      }
      
      eventos[index] = evento;
      await _saveEventos(evento.farmId, eventos);
      
      return evento;
    } catch (e) {
      if (e is Failure) rethrow;
      throw CacheFailure('Error al actualizar evento: $e');
    }
  }

  @override
  Future<void> deleteEvento(String id, String farmId) async {
    try {
      final eventos = await getAllEventos(farmId);
      eventos.removeWhere((e) => e.id == id);
      await _saveEventos(farmId, eventos);
    } catch (e) {
      throw CacheFailure('Error al eliminar evento: $e');
    }
  }

  Future<void> _saveEventos(String farmId, List<EventoReproductivoModel> eventos) async {
    final key = 'eventos_reproductivos_$farmId';
    final jsonList = eventos.map((e) => e.toJson()).toList();
    await prefs.setString(key, json.encode(jsonList));
  }
}

