import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reproductive_event_model.dart';

/// Excepción para errores del servidor
class ServerException implements Exception {
  final String message;
  const ServerException(this.message);

  @override
  String toString() => message;
}

/// Contrato abstracto para el datasource remoto de Eventos Reproductivos
abstract class ReproductiveEventRemoteDataSource {
  /// Obtiene todos los eventos reproductivos de un bovino
  Future<List<ReproductiveEventModel>> getEventsByBovine(
    String bovineId,
    String farmId,
  );

  /// Obtiene un evento reproductivo por su ID
  Future<ReproductiveEventModel> getEventById(
    String id,
    String bovineId,
    String farmId,
  );

  /// Agrega un nuevo evento reproductivo
  Future<ReproductiveEventModel> addEvent(ReproductiveEventModel event);

  /// Actualiza un evento reproductivo existente
  Future<ReproductiveEventModel> updateEvent(ReproductiveEventModel event);

  /// Elimina un evento reproductivo por su ID
  Future<void> deleteEvent(String id, String bovineId, String farmId);
}

/// Implementación del datasource usando Firestore
class ReproductiveEventRemoteDataSourceImpl
    implements ReproductiveEventRemoteDataSource {
  final FirebaseFirestore firestore;

  ReproductiveEventRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  /// Referencia a la colección de eventos reproductivos de un bovino
  CollectionReference _getEventsCollection(String farmId, String bovineId) {
    return firestore
        .collection('farms')
        .doc(farmId)
        .collection('cattle')
        .doc(bovineId)
        .collection('reproductive_events');
  }

  @override
  Future<List<ReproductiveEventModel>> getEventsByBovine(
    String bovineId,
    String farmId,
  ) async {
    try {
      final snapshot = await _getEventsCollection(farmId, bovineId)
          .orderBy('eventDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ReproductiveEventModel.fromJson({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .toList();
    } catch (e) {
      throw ServerException('Error al obtener eventos reproductivos: $e');
    }
  }

  @override
  Future<ReproductiveEventModel> getEventById(
    String id,
    String bovineId,
    String farmId,
  ) async {
    try {
      final doc = await _getEventsCollection(farmId, bovineId).doc(id).get();

      if (!doc.exists) {
        throw ServerException('Evento reproductivo no encontrado');
      }

      return ReproductiveEventModel.fromJson({
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      });
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Error al obtener evento reproductivo: $e');
    }
  }

  @override
  Future<ReproductiveEventModel> addEvent(
      ReproductiveEventModel event) async {
    try {
      if (!event.isValid) {
        throw ServerException('Datos de evento reproductivo inválidos');
      }

      final docRef = _getEventsCollection(event.farmId, event.bovineId).doc();
      final newEvent = event.copyWith(id: docRef.id);

      await docRef.set(newEvent.toJson());

      return newEvent;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Error al crear evento reproductivo: $e');
    }
  }

  @override
  Future<ReproductiveEventModel> updateEvent(
      ReproductiveEventModel event) async {
    try {
      if (!event.isValid) {
        throw ServerException('Datos de evento reproductivo inválidos');
      }

      final updatedEvent = event.copyWith(updatedAt: DateTime.now());

      await _getEventsCollection(event.farmId, event.bovineId)
          .doc(event.id)
          .update(updatedEvent.toJson());

      return updatedEvent;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Error al actualizar evento reproductivo: $e');
    }
  }

  @override
  Future<void> deleteEvent(String id, String bovineId, String farmId) async {
    try {
      await _getEventsCollection(farmId, bovineId).doc(id).delete();
    } catch (e) {
      throw ServerException('Error al eliminar evento reproductivo: $e');
    }
  }
}



