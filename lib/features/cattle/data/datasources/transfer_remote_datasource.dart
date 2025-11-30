import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transfer_model.dart';
import '../../domain/entities/transfer_entity.dart';

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
      // Si no hay toFarmId, solo crear el registro (transferencia interna o sin destino)
      if (transfer.toFarmId == null || transfer.toFarmId!.isEmpty) {
        final docRef = _getTransfersCollection(transfer.farmId, transfer.bovineId).doc();
        final transferWithId = transfer.copyWith(
          id: docRef.id,
          createdAt: DateTime.now(),
        );
        await docRef.set(transferWithId.toJson());
        return transferWithId;
      }

      // Transferencia entre fincas: usar WriteBatch para mover TODO
      final fromFarmId = transfer.farmId;
      final toFarmId = transfer.toFarmId!;
      final bovineId = transfer.bovineId;

      // ============================================
      // PASO 1: Validar que el bovino existe
      // ============================================
      final bovineRef = firestore
          .collection('farms')
          .doc(fromFarmId)
          .collection('cattle')
          .doc(bovineId);
      
      final bovineDoc = await bovineRef.get();
      if (!bovineDoc.exists) {
        throw ServerException('Bovino no encontrado en la finca origen');
      }

      final bovineData = bovineDoc.data()!;

      // ============================================
      // PASO 2: Determinar el tipo de transferencia
      // ============================================
      final isSale = transfer.reason == TransferReason.venta;
      final isDeath = false; // Podríamos agregar un campo 'isDeath' en el futuro
      
      // Si es venta o muerte, marcar como inactivo en lugar de mover
      if (isSale) {
        return await _handleSaleOrDeathTransfer(
          transfer,
          bovineRef,
          bovineData,
          'vendido',
        );
      }

      // ============================================
      // PASO 3: Transferencia normal (mover a otra finca)
      // ============================================
      return await _handleNormalTransfer(
        transfer,
        fromFarmId,
        toFarmId,
        bovineId,
        bovineRef,
        bovineData,
      );
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('Error al agregar transferencia: $e');
    }
  }

  /// Maneja transferencias de venta o muerte (marcar como inactivo)
  Future<TransferModel> _handleSaleOrDeathTransfer(
    TransferModel transfer,
    DocumentReference bovineRef,
    Map<String, dynamic> bovineData,
    String status,
  ) async {
    final batch = firestore.batch();

    // 1. Crear registro de transferencia
    final transferRef = _getTransfersCollection(transfer.farmId, transfer.bovineId).doc();
    final transferWithId = transfer.copyWith(
      id: transferRef.id,
      createdAt: DateTime.now(),
    );
    batch.set(transferRef, transferWithId.toJson());

    // 2. Actualizar estado del bovino (marcar como vendido/muerto)
    batch.update(bovineRef, {
      'status': status,
      'updatedAt': Timestamp.now(),
    });

    await batch.commit();
    return transferWithId;
  }

  /// Maneja transferencias normales (mover a otra finca)
  Future<TransferModel> _handleNormalTransfer(
    TransferModel transfer,
    String fromFarmId,
    String toFarmId,
    String bovineId,
    DocumentReference bovineRef,
    Map<String, dynamic> bovineData,
  ) async {
    // Obtener todas las subcolecciones ANTES de crear el batch
    // para calcular el total de operaciones
    final subcollections = [
      'milk_production',
      'weight_records',
      'reproductive_events',
      'vaccines',
      'transfers',
    ];

    // Contar documentos en cada subcolección
    int totalOperations = 2; // Bovino: set + delete
    final subcollectionCounts = <String, int>{};

    for (final subcollectionName in subcollections) {
      final fromCollection = firestore
          .collection('farms')
          .doc(fromFarmId)
          .collection('cattle')
          .doc(bovineId)
          .collection(subcollectionName);
      
      final snapshot = await fromCollection.get();
      final count = snapshot.docs.length;
      subcollectionCounts[subcollectionName] = count;
      // Cada documento = 2 operaciones (set + delete)
      totalOperations += count * 2;
    }

    // Si hay más de 500 operaciones, usar múltiples batches
    if (totalOperations > 500) {
      return await _handleLargeTransfer(
        transfer,
        fromFarmId,
        toFarmId,
        bovineId,
        bovineRef,
        bovineData,
        subcollectionCounts,
      );
    }

    // Caso normal: todo cabe en un batch
    final batch = firestore.batch();

    // 1. Crear el bovino en la finca destino
    final newBovineRef = firestore
        .collection('farms')
        .doc(toFarmId)
        .collection('cattle')
        .doc(bovineId);
    
    final updatedBovineData = Map<String, dynamic>.from(bovineData);
    updatedBovineData['farmId'] = toFarmId;
    updatedBovineData['updatedAt'] = Timestamp.now();
    
    batch.set(newBovineRef, updatedBovineData);

    // 2. Mover todas las subcolecciones
    for (final subcollectionName in subcollections) {
      await _addSubcollectionToBatch(
        batch,
        fromFarmId,
        toFarmId,
        bovineId,
        subcollectionName,
      );
    }

    // 3. Crear el registro de transferencia en origen
    final transferRef = _getTransfersCollection(fromFarmId, bovineId).doc();
    final transferWithId = transfer.copyWith(
      id: transferRef.id,
      createdAt: DateTime.now(),
    );
    batch.set(transferRef, transferWithId.toJson());

    // 4. Crear el registro de transferencia en destino (historial)
    final destTransferRef = firestore
        .collection('farms')
        .doc(toFarmId)
        .collection('cattle')
        .doc(bovineId)
        .collection('transfers')
        .doc(transferRef.id);
    batch.set(destTransferRef, transferWithId.toJson());

    // 5. Eliminar el bovino de la finca origen
    batch.delete(bovineRef);

    await batch.commit();
    return transferWithId;
  }

  /// Maneja transferencias grandes (>500 operaciones) usando múltiples batches
  Future<TransferModel> _handleLargeTransfer(
    TransferModel transfer,
    String fromFarmId,
    String toFarmId,
    String bovineId,
    DocumentReference bovineRef,
    Map<String, dynamic> bovineData,
    Map<String, int> subcollectionCounts,
  ) async {
    // Batch 1: Mover el bovino y crear transferencias
    final batch1 = firestore.batch();

    // Crear bovino en destino
    final newBovineRef = firestore
        .collection('farms')
        .doc(toFarmId)
        .collection('cattle')
        .doc(bovineId);
    
    final updatedBovineData = Map<String, dynamic>.from(bovineData);
    updatedBovineData['farmId'] = toFarmId;
    updatedBovineData['updatedAt'] = Timestamp.now();
    
    batch1.set(newBovineRef, updatedBovineData);

    // Crear registro de transferencia
    final transferRef = _getTransfersCollection(fromFarmId, bovineId).doc();
    final transferWithId = transfer.copyWith(
      id: transferRef.id,
      createdAt: DateTime.now(),
    );
    batch1.set(transferRef, transferWithId.toJson());

    final destTransferRef = firestore
        .collection('farms')
        .doc(toFarmId)
        .collection('cattle')
        .doc(bovineId)
        .collection('transfers')
        .doc(transferRef.id);
    batch1.set(destTransferRef, transferWithId.toJson());

    await batch1.commit();

    // Batch 2-N: Mover subcolecciones en lotes
    final subcollections = [
      'milk_production',
      'weight_records',
      'reproductive_events',
      'vaccines',
      'transfers',
    ];

    for (final subcollectionName in subcollections) {
      await _moveSubcollectionInBatches(
        fromFarmId,
        toFarmId,
        bovineId,
        subcollectionName,
      );
    }

    // Último batch: Eliminar bovino de origen
    final finalBatch = firestore.batch();
    finalBatch.delete(bovineRef);
    await finalBatch.commit();

    return transferWithId;
  }

  /// Agrega una subcolección completa a un batch (máximo 250 documentos por batch)
  Future<void> _addSubcollectionToBatch(
    WriteBatch batch,
    String fromFarmId,
    String toFarmId,
    String bovineId,
    String subcollectionName,
  ) async {
    final fromCollection = firestore
        .collection('farms')
        .doc(fromFarmId)
        .collection('cattle')
        .doc(bovineId)
        .collection(subcollectionName);
    
    final snapshot = await fromCollection.get();
    
    if (snapshot.docs.isEmpty) {
      return;
    }
    
    final toCollection = firestore
        .collection('farms')
        .doc(toFarmId)
        .collection('cattle')
        .doc(bovineId)
        .collection(subcollectionName);
    
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final updatedData = Map<String, dynamic>.from(data);
      if (updatedData.containsKey('farmId')) {
        updatedData['farmId'] = toFarmId;
      }
      
      batch.set(toCollection.doc(doc.id), updatedData);
      batch.delete(doc.reference);
    }
  }

  /// Mueve una subcolección en múltiples batches si es necesario
  Future<void> _moveSubcollectionInBatches(
    String fromFarmId,
    String toFarmId,
    String bovineId,
    String subcollectionName,
  ) async {
    final fromCollection = firestore
        .collection('farms')
        .doc(fromFarmId)
        .collection('cattle')
        .doc(bovineId)
        .collection(subcollectionName);
    
    final snapshot = await fromCollection.get();
    
    if (snapshot.docs.isEmpty) {
      return;
    }
    
    final toCollection = firestore
        .collection('farms')
        .doc(toFarmId)
        .collection('cattle')
        .doc(bovineId)
        .collection(subcollectionName);
    
    // Procesar en lotes de 250 documentos (500 operaciones: set + delete)
    for (int i = 0; i < snapshot.docs.length; i += 250) {
      final batch = firestore.batch();
      final batchDocs = snapshot.docs.skip(i).take(250);
      
      for (final doc in batchDocs) {
        final data = doc.data();
        final updatedData = Map<String, dynamic>.from(data);
        if (updatedData.containsKey('farmId')) {
          updatedData['farmId'] = toFarmId;
        }
        
        batch.set(toCollection.doc(doc.id), updatedData);
        batch.delete(doc.reference);
      }
      
      await batch.commit();
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

