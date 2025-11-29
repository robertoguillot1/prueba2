import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transfer_model.dart';

/// Excepción para errores del servidor
class ServerException implements Exception {
  final String message;
  const ServerException(this.message);

  @override
  String toString() => message;
}

/// Contrato abstracto para el datasource remoto de Transferencias
abstract class TransferRemoteDataSource {
  /// Obtiene todas las transferencias de un bovino
  Future<List<TransferModel>> getTransfersByBovine(
    String bovineId,
    String farmId,
  );

  /// Obtiene todas las transferencias de una finca
  Future<List<TransferModel>> getTransfersByFarm(String farmId);

  /// Obtiene una transferencia por su ID
  Future<TransferModel> getTransferById(
    String id,
    String bovineId,
    String farmId,
  );

  /// Agrega una nueva transferencia
  Future<TransferModel> addTransfer(TransferModel transfer);

  /// Actualiza una transferencia existente
  Future<TransferModel> updateTransfer(TransferModel transfer);

  /// Elimina una transferencia por su ID
  Future<void> deleteTransfer(String id, String bovineId, String farmId);
}

/// Implementación del datasource usando Firestore
class TransferRemoteDataSourceImpl implements TransferRemoteDataSource {
  final FirebaseFirestore firestore;

  TransferRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  /// Referencia a la colección de transferencias de un bovino
  CollectionReference _getTransfersCollection(String farmId, String bovineId) {
    return firestore
        .collection('farms')
        .doc(farmId)
        .collection('cattle')
        .doc(bovineId)
        .collection('transfers');
  }

  @override
  Future<List<TransferModel>> getTransfersByBovine(
    String bovineId,
    String farmId,
  ) async {
    try {
      final snapshot = await _getTransfersCollection(farmId, bovineId)
          .orderBy('transferDate', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return TransferModel.fromJson({
          ...doc.data() as Map<String, dynamic>,
          'id': doc.id,
        });
      }).toList();
    } catch (e) {
      throw ServerException('Error al obtener transferencias: $e');
    }
  }

  @override
  Future<List<TransferModel>> getTransfersByFarm(String farmId) async {
    try {
      // Obtener todos los bovinos de la finca
      final cattleSnapshot = await firestore
          .collection('farms')
          .doc(farmId)
          .collection('cattle')
          .get();

      final allTransfers = <TransferModel>[];

      // Para cada bovino, obtener sus transferencias
      for (final cattleDoc in cattleSnapshot.docs) {
        final transfersSnapshot = await _getTransfersCollection(farmId, cattleDoc.id)
            .orderBy('transferDate', descending: true)
            .get();

        final transfers = transfersSnapshot.docs.map((doc) {
          return TransferModel.fromJson({
            ...doc.data() as Map<String, dynamic>,
            'id': doc.id,
          });
        }).toList();

        allTransfers.addAll(transfers);
      }

      // Ordenar todas las transferencias por fecha
      allTransfers.sort((a, b) => b.transferDate.compareTo(a.transferDate));

      return allTransfers;
    } catch (e) {
      throw ServerException('Error al obtener transferencias de la finca: $e');
    }
  }

  @override
  Future<TransferModel> getTransferById(
    String id,
    String bovineId,
    String farmId,
  ) async {
    try {
      final doc = await _getTransfersCollection(farmId, bovineId).doc(id).get();

      if (!doc.exists) {
        throw ServerException('Transferencia no encontrada con ID: $id');
      }

      return TransferModel.fromJson({
        ...doc.data()! as Map<String, dynamic>,
        'id': doc.id,
      });
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('Error al obtener transferencia: $e');
    }
  }

  @override
  Future<TransferModel> addTransfer(TransferModel transfer) async {
    try {
      final docRef = _getTransfersCollection(transfer.farmId, transfer.bovineId)
          .doc();

      final transferWithId = transfer.copyWith(
        id: docRef.id,
        createdAt: DateTime.now(),
      );

      await docRef.set(transferWithId.toJson());

      return transferWithId;
    } catch (e) {
      throw ServerException('Error al agregar transferencia: $e');
    }
  }

  @override
  Future<TransferModel> updateTransfer(TransferModel transfer) async {
    try {
      final docRef = _getTransfersCollection(transfer.farmId, transfer.bovineId)
          .doc(transfer.id);

      final doc = await docRef.get();
      if (!doc.exists) {
        throw ServerException('Transferencia no encontrada con ID: ${transfer.id}');
      }

      final transferToUpdate = transfer.copyWith(
        updatedAt: DateTime.now(),
      );

      await docRef.update(transferToUpdate.toJson());

      return transferToUpdate;
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('Error al actualizar transferencia: $e');
    }
  }

  @override
  Future<void> deleteTransfer(String id, String bovineId, String farmId) async {
    try {
      final docRef = _getTransfersCollection(farmId, bovineId).doc(id);

      final doc = await docRef.get();
      if (!doc.exists) {
        throw ServerException('Transferencia no encontrada con ID: $id');
      }

      await docRef.delete();
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('Error al eliminar transferencia: $e');
    }
  }
}

