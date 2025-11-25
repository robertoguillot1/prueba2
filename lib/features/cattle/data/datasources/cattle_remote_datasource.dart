import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bovine_model.dart';

/// Excepción para errores del servidor
class ServerException implements Exception {
  final String message;
  const ServerException(this.message);

  @override
  String toString() => message;
}

/// Contrato abstracto para el datasource remoto de Bovinos
abstract class CattleRemoteDataSource {
  /// Obtiene la lista de bovinos de una finca (consulta única)
  Future<List<BovineModel>> getCattleList(String farmId);

  /// Obtiene un stream de bovinos para actualizaciones en tiempo real
  Stream<List<BovineModel>> getCattleListStream(String farmId);

  /// Obtiene un bovino por su ID
  Future<BovineModel> getBovine(String farmId, String id);

  /// Agrega un nuevo bovino
  Future<BovineModel> addBovine(BovineModel bovine);

  /// Actualiza un bovino existente
  Future<BovineModel> updateBovine(BovineModel bovine);

  /// Elimina un bovino por su ID
  Future<void> deleteBovine(String farmId, String id);
}

/// Implementación del datasource remoto usando Firebase Firestore
class CattleRemoteDataSourceImpl implements CattleRemoteDataSource {
  final FirebaseFirestore firestore;

  CattleRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<BovineModel>> getCattleList(String farmId) async {
    try {
      // Consulta única - retorna Future
      final snapshot = await firestore
          .collection('farms')
          .doc(farmId)
          .collection('cattle')
          .orderBy('createdAt', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => BovineModel.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      throw ServerException('Error al obtener la lista de bovinos: $e');
    }
  }

  @override
  Stream<List<BovineModel>> getCattleListStream(String farmId) {
    try {
      // Stream para actualizaciones en tiempo real
      return firestore
          .collection('farms')
          .doc(farmId)
          .collection('cattle')
          .orderBy('createdAt', descending: false)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => BovineModel.fromJson({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList();
      });
    } catch (e) {
      throw ServerException('Error al obtener el stream de bovinos: $e');
    }
  }

  @override
  Future<BovineModel> getBovine(String farmId, String id) async {
    try {
      final doc = await firestore
          .collection('farms')
          .doc(farmId)
          .collection('cattle')
          .doc(id)
          .get();

      if (!doc.exists) {
        throw ServerException('Bovino no encontrado con ID: $id');
      }

      return BovineModel.fromJson({
        ...doc.data()!,
        'id': doc.id,
      });
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('Error al obtener el bovino: $e');
    }
  }

  @override
  Future<BovineModel> addBovine(BovineModel bovine) async {
    try {
      final docRef = firestore
          .collection('farms')
          .doc(bovine.farmId)
          .collection('cattle')
          .doc();

      // Asignar el ID generado
      final bovineWithId = bovine.copyWith(
        id: docRef.id,
        createdAt: DateTime.now(),
      );

      await docRef.set(bovineWithId.toJson());

      // Retornar el bovino creado
      return bovineWithId;
    } catch (e) {
      throw ServerException('Error al agregar el bovino: $e');
    }
  }

  @override
  Future<BovineModel> updateBovine(BovineModel bovine) async {
    try {
      final docRef = firestore
          .collection('farms')
          .doc(bovine.farmId)
          .collection('cattle')
          .doc(bovine.id);

      // Verificar que el documento existe
      final doc = await docRef.get();
      if (!doc.exists) {
        throw ServerException('Bovino no encontrado con ID: ${bovine.id}');
      }

      // Actualizar con fecha de actualización
      final bovineToUpdate = bovine.copyWith(
        updatedAt: DateTime.now(),
      );

      await docRef.update(bovineToUpdate.toJson());

      // Retornar el bovino actualizado
      return bovineToUpdate;
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('Error al actualizar el bovino: $e');
    }
  }

  @override
  Future<void> deleteBovine(String farmId, String id) async {
    try {
      final docRef = firestore
          .collection('farms')
          .doc(farmId)
          .collection('cattle')
          .doc(id);

      // Verificar que el documento existe
      final doc = await docRef.get();
      if (!doc.exists) {
        throw ServerException('Bovino no encontrado con ID: $id');
      }

      await docRef.delete();
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('Error al eliminar el bovino: $e');
    }
  }
}
