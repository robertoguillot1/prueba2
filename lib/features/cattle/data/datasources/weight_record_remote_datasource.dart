import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/weight_record_model.dart';

/// Excepción para errores del servidor
class ServerException implements Exception {
  final String message;
  const ServerException(this.message);

  @override
  String toString() => message;
}

/// Contrato abstracto para el datasource remoto de Registros de Peso
abstract class WeightRecordRemoteDataSource {
  /// Obtiene todos los registros de peso de un bovino
  Future<List<WeightRecordModel>> getRecordsByBovine(
    String bovineId,
    String farmId,
  );

  /// Obtiene un registro de peso por su ID
  Future<WeightRecordModel> getRecordById(
    String id,
    String bovineId,
    String farmId,
  );

  /// Agrega un nuevo registro de peso
  Future<WeightRecordModel> addRecord(WeightRecordModel record);

  /// Actualiza un registro de peso existente
  Future<WeightRecordModel> updateRecord(WeightRecordModel record);

  /// Elimina un registro de peso por su ID
  Future<void> deleteRecord(String id, String bovineId, String farmId);
}

/// Implementación del datasource usando Firestore
class WeightRecordRemoteDataSourceImpl
    implements WeightRecordRemoteDataSource {
  final FirebaseFirestore firestore;

  WeightRecordRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  /// Referencia a la colección de registros de peso de un bovino
  CollectionReference _getRecordsCollection(String farmId, String bovineId) {
    return firestore
        .collection('farms')
        .doc(farmId)
        .collection('cattle')
        .doc(bovineId)
        .collection('weight_records');
  }

  @override
  Future<List<WeightRecordModel>> getRecordsByBovine(
    String bovineId,
    String farmId,
  ) async {
    try {
      final snapshot = await _getRecordsCollection(farmId, bovineId)
          .orderBy('recordDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => WeightRecordModel.fromJson({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .toList();
    } catch (e) {
      throw ServerException('Error al obtener registros de peso: $e');
    }
  }

  @override
  Future<WeightRecordModel> getRecordById(
    String id,
    String bovineId,
    String farmId,
  ) async {
    try {
      final doc = await _getRecordsCollection(farmId, bovineId).doc(id).get();

      if (!doc.exists) {
        throw ServerException('Registro de peso no encontrado');
      }

      return WeightRecordModel.fromJson({
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      });
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Error al obtener registro de peso: $e');
    }
  }

  @override
  Future<WeightRecordModel> addRecord(WeightRecordModel record) async {
    try {
      if (!record.isValid) {
        throw ServerException('Datos de registro de peso inválidos');
      }

      final docRef = _getRecordsCollection(record.farmId, record.bovineId).doc();
      final newRecord = record.copyWith(id: docRef.id);

      await docRef.set(newRecord.toJson());

      return newRecord;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Error al crear registro de peso: $e');
    }
  }

  @override
  Future<WeightRecordModel> updateRecord(WeightRecordModel record) async {
    try {
      if (!record.isValid) {
        throw ServerException('Datos de registro de peso inválidos');
      }

      final updatedRecord = record.copyWith(updatedAt: DateTime.now());

      await _getRecordsCollection(record.farmId, record.bovineId)
          .doc(record.id)
          .update(updatedRecord.toJson());

      return updatedRecord;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Error al actualizar registro de peso: $e');
    }
  }

  @override
  Future<void> deleteRecord(String id, String bovineId, String farmId) async {
    try {
      await _getRecordsCollection(farmId, bovineId).doc(id).delete();
    } catch (e) {
      throw ServerException('Error al eliminar registro de peso: $e');
    }
  }
}

