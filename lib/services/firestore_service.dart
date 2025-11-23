import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/farm.dart';
import '../models/module_item.dart';
import '../utils/logger.dart';

/// Servicio para manejar todas las operaciones de Firestore
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== FARMS MANAGEMENT ====================

  /// Obtiene todas las fincas de un usuario
  Future<List<Farm>> getFarms(String userId) async {
    try {
      final farmsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('farms')
          .orderBy('createdAt', descending: false)
          .get();

      return farmsSnapshot.docs
          .map((doc) => Farm.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e, stackTrace) {
      AppLogger.error('Error getting farms', e, stackTrace);
      return [];
    }
  }

  /// Obtiene una finca específica
  Future<Farm?> getFarm(String userId, String farmId) async {
    try {
      final farmDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('farms')
          .doc(farmId)
          .get();

      if (!farmDoc.exists) return null;

      return Farm.fromJson({...farmDoc.data()!, 'id': farmDoc.id});
    } catch (e, stackTrace) {
      AppLogger.error('Error getting farm', e, stackTrace);
      return null;
    }
  }

  /// Guarda o actualiza una finca
  Future<void> saveFarm(String userId, Farm farm) async {
    try {
      final farmData = farm.toJson();
      // Remover el ID del JSON ya que Firestore lo maneja como document ID
      farmData.remove('id');

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('farms')
          .doc(farm.id)
          .set(farmData, SetOptions(merge: true));
    } catch (e, stackTrace) {
      AppLogger.error('Error saving farm', e, stackTrace);
      rethrow;
    }
  }

  /// Elimina una finca
  Future<void> deleteFarm(String userId, String farmId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('farms')
          .doc(farmId)
          .delete();
    } catch (e, stackTrace) {
      AppLogger.error('Error deleting farm', e, stackTrace);
      rethrow;
    }
  }

  // ==================== CURRENT FARM MANAGEMENT ====================

  /// Obtiene el ID de la finca actual del usuario
  Future<String?> getCurrentFarmId(String userId) async {
    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) return null;

      return userDoc.data()?['currentFarmId'] as String?;
    } catch (e, stackTrace) {
      AppLogger.error('Error getting current farm ID', e, stackTrace);
      return null;
    }
  }

  /// Establece la finca actual del usuario
  Future<void> setCurrentFarmId(String userId, String farmId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .set({
        'currentFarmId': farmId,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e, stackTrace) {
      AppLogger.error('Error setting current farm ID', e, stackTrace);
      rethrow;
    }
  }

  // ==================== MODULES ORDER MANAGEMENT ====================

  /// Obtiene el orden de módulos del usuario
  Future<List<ModuleItem>> getModulesOrder(String userId) async {
    try {
      final modulesDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('modulesOrder')
          .get();

      if (!modulesDoc.exists) {
        return ModuleItem.getDefaultModules();
      }

      final data = modulesDoc.data();
      if (data == null || data['modules'] == null) {
        return ModuleItem.getDefaultModules();
      }

      final List<dynamic> modulesList = data['modules'] as List<dynamic>;
      return modulesList
          .map((moduleJson) => ModuleItem.fromJson(moduleJson))
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));
    } catch (e, stackTrace) {
      AppLogger.error('Error getting modules order', e, stackTrace);
      return ModuleItem.getDefaultModules();
    }
  }

  /// Guarda el orden de módulos del usuario
  Future<void> saveModulesOrder(String userId, List<ModuleItem> modules) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('modulesOrder')
          .set({
        'modules': modules.map((m) => m.toJson()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e, stackTrace) {
      AppLogger.error('Error saving modules order', e, stackTrace);
      rethrow;
    }
  }

  // ==================== LISTENERS ====================

  /// Escucha cambios en las fincas de un usuario
  Stream<List<Farm>> watchFarms(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('farms')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Farm.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  /// Escucha cambios en una finca específica
  Stream<Farm?> watchFarm(String userId, String farmId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('farms')
        .doc(farmId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      return Farm.fromJson({...snapshot.data()!, 'id': snapshot.id});
    });
  }

  /// Escucha cambios en el ID de la finca actual
  Stream<String?> watchCurrentFarmId(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) => snapshot.data()?['currentFarmId'] as String?);
  }
}

