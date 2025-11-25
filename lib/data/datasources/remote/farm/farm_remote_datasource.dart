import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/farm/farm_model.dart';

/// Data source remoto para Fincas usando Firestore
abstract class FarmRemoteDataSource {
  /// Obtiene un stream de todas las fincas de un usuario
  Stream<List<FarmModel>> getFarmsStream(String userId);

  /// Obtiene una finca por su ID
  Future<FarmModel?> getFarmById(String userId, String farmId);

  /// Crea una nueva finca
  Future<FarmModel> createFarm(FarmModel farm);

  /// Actualiza una finca existente
  Future<FarmModel> updateFarm(FarmModel farm);

  /// Elimina una finca
  Future<void> deleteFarm(String userId, String farmId);

  /// Establece la finca actual del usuario
  Future<void> setCurrentFarmId(String userId, String farmId);

  /// Obtiene el ID de la finca actual del usuario
  Future<String?> getCurrentFarmId(String userId);
}

class FarmFirebaseDataSource implements FarmRemoteDataSource {
  final FirebaseFirestore _firestore;

  FarmFirebaseDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<FarmModel>> getFarmsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('farms')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FarmModel.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
    });
  }

  @override
  Future<FarmModel?> getFarmById(String userId, String farmId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('farms')
          .doc(farmId)
          .get();

      if (!doc.exists) return null;

      return FarmModel.fromJson({
        ...doc.data()!,
        'id': doc.id,
      });
    } catch (e) {
      throw Exception('Error al obtener la finca: $e');
    }
  }

  @override
  Future<FarmModel> createFarm(FarmModel farm) async {
    try {
      final docRef = _firestore
          .collection('users')
          .doc(farm.ownerId)
          .collection('farms')
          .doc();

      // Asignar el ID generado
      final farmWithId = farm.copyWith(id: docRef.id);

      await docRef.set(farmWithId.toJson());

      // Obtener el documento creado para retornarlo
      final createdDoc = await docRef.get();
      return FarmModel.fromJson({
        ...createdDoc.data()!,
        'id': createdDoc.id,
      });
    } catch (e) {
      throw Exception('Error al crear la finca: $e');
    }
  }

  @override
  Future<FarmModel> updateFarm(FarmModel farm) async {
    try {
      final farmData = farm.toJson();
      farmData['updatedAt'] = Timestamp.now();

      await _firestore
          .collection('users')
          .doc(farm.ownerId)
          .collection('farms')
          .doc(farm.id)
          .update(farmData);

      // Obtener el documento actualizado
      final updatedDoc = await _firestore
          .collection('users')
          .doc(farm.ownerId)
          .collection('farms')
          .doc(farm.id)
          .get();

      return FarmModel.fromJson({
        ...updatedDoc.data()!,
        'id': updatedDoc.id,
      });
    } catch (e) {
      throw Exception('Error al actualizar la finca: $e');
    }
  }

  @override
  Future<void> deleteFarm(String userId, String farmId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('farms')
          .doc(farmId)
          .delete();
    } catch (e) {
      throw Exception('Error al eliminar la finca: $e');
    }
  }

  @override
  Future<void> setCurrentFarmId(String userId, String farmId) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'currentFarmId': farmId,
        'updatedAt': Timestamp.now(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Error al establecer la finca actual: $e');
    }
  }

  @override
  Future<String?> getCurrentFarmId(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;
      return doc.data()?['currentFarmId'] as String?;
    } catch (e) {
      throw Exception('Error al obtener la finca actual: $e');
    }
  }
}

