import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pago_model.dart';
import '../models/prestamo_model.dart';
import '../../../../data/models/trabajadores/trabajador_model.dart';

/// Excepción para errores del servidor
class ServerException implements Exception {
  final String message;
  const ServerException(this.message);

  @override
  String toString() => message;
}

/// Contrato abstracto para el datasource remoto de Trabajadores
abstract class TrabajadoresRemoteDataSource {
  // === TRABAJADORES ===
  /// Obtiene todos los trabajadores de una finca
  Future<List<TrabajadorModel>> getWorkers(String farmId);
  
  /// Obtiene un trabajador por su ID
  Future<TrabajadorModel> getWorker(String farmId, String workerId);
  
  /// Agrega un nuevo trabajador
  Future<TrabajadorModel> addWorker(TrabajadorModel worker);
  
  /// Actualiza un trabajador existente
  Future<TrabajadorModel> updateWorker(TrabajadorModel worker);
  
  /// Elimina un trabajador
  Future<void> deleteWorker(String farmId, String workerId);
  
  /// Busca trabajadores por nombre, identificación o cargo
  Future<List<TrabajadorModel>> searchWorkers(String farmId, String query);
  /// Obtiene la lista de pagos de un trabajador
  Future<List<PagoModel>> getPagosByWorker(String farmId, String workerId);

  /// Obtiene un stream de pagos para actualizaciones en tiempo real
  Stream<List<PagoModel>> getPagosByWorkerStream(String farmId, String workerId);

  /// Agrega un nuevo pago
  Future<PagoModel> addPago(PagoModel pago);

  /// Actualiza un pago existente
  Future<PagoModel> updatePago(PagoModel pago);

  /// Elimina un pago
  Future<void> deletePago(String farmId, String workerId, String pagoId);

  /// Obtiene la lista de préstamos de un trabajador
  Future<List<PrestamoModel>> getPrestamosByWorker(String farmId, String workerId);

  /// Obtiene un stream de préstamos para actualizaciones en tiempo real
  Stream<List<PrestamoModel>> getPrestamosByWorkerStream(String farmId, String workerId);

  /// Agrega un nuevo préstamo
  Future<PrestamoModel> addPrestamo(PrestamoModel prestamo);

  /// Actualiza un préstamo existente
  Future<PrestamoModel> updatePrestamo(PrestamoModel prestamo);

  /// Elimina un préstamo
  Future<void> deletePrestamo(String farmId, String workerId, String prestamoId);
}

/// Implementación del datasource remoto usando Firebase Firestore
class TrabajadoresRemoteDataSourceImpl implements TrabajadoresRemoteDataSource {
  final FirebaseFirestore firestore;

  TrabajadoresRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  // === IMPLEMENTACIÓN TRABAJADORES ===
  @override
  Future<List<TrabajadorModel>> getWorkers(String farmId) async {
    try {
      final snapshot = await firestore
          .collection('farms')
          .doc(farmId)
          .collection('workers')
          .get();

      final workers = snapshot.docs
          .map((doc) => TrabajadorModel.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();

      // Ordenar por fecha de creación (más recientes primero) si existe, sino por nombre
      workers.sort((a, b) {
        if (a.createdAt != null && b.createdAt != null) {
          return b.createdAt!.compareTo(a.createdAt!);
        }
        if (a.createdAt != null) return -1;
        if (b.createdAt != null) return 1;
        return a.fullName.compareTo(b.fullName);
      });

      return workers;
    } catch (e) {
      throw ServerException('Error al obtener los trabajadores: $e');
    }
  }

  @override
  Future<TrabajadorModel> getWorker(String farmId, String workerId) async {
    try {
      final doc = await firestore
          .collection('farms')
          .doc(farmId)
          .collection('workers')
          .doc(workerId)
          .get();

      if (!doc.exists) {
        throw ServerException('Trabajador no encontrado con ID: $workerId');
      }

      return TrabajadorModel.fromJson({
        ...doc.data()!,
        'id': doc.id,
      });
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('Error al obtener el trabajador: $e');
    }
  }

  @override
  Future<TrabajadorModel> addWorker(TrabajadorModel worker) async {
    try {
      final docRef = firestore
          .collection('farms')
          .doc(worker.farmId)
          .collection('workers')
          .doc(worker.id);

      // Asignar el ID proporcionado y fechas
      final workerWithId = worker.copyWith(
        createdAt: worker.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final json = workerWithId.toJson();
      json.remove('id'); // No guardar el ID en el documento (se usa como doc.id)

      await docRef.set(json);

      // Retornar el trabajador creado
      return workerWithId;
    } catch (e) {
      throw ServerException('Error al agregar el trabajador: $e');
    }
  }

  @override
  Future<TrabajadorModel> updateWorker(TrabajadorModel worker) async {
    try {
      final docRef = firestore
          .collection('farms')
          .doc(worker.farmId)
          .collection('workers')
          .doc(worker.id);

      // Verificar que el documento existe
      final doc = await docRef.get();
      if (!doc.exists) {
        throw ServerException('Trabajador no encontrado con ID: ${worker.id}');
      }

      // Actualizar con fecha de actualización
      final workerToUpdate = worker.copyWith(
        updatedAt: DateTime.now(),
      );

      final json = workerToUpdate.toJson();
      json.remove('id'); // No guardar el ID en el documento

      await docRef.update(json);

      // Retornar el trabajador actualizado
      return workerToUpdate;
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('Error al actualizar el trabajador: $e');
    }
  }

  @override
  Future<void> deleteWorker(String farmId, String workerId) async {
    try {
      await firestore
          .collection('farms')
          .doc(farmId)
          .collection('workers')
          .doc(workerId)
          .delete();
    } catch (e) {
      throw ServerException('Error al eliminar el trabajador: $e');
    }
  }

  @override
  Future<List<TrabajadorModel>> searchWorkers(String farmId, String query) async {
    try {
      final snapshot = await firestore
          .collection('farms')
          .doc(farmId)
          .collection('workers')
          .get();

      final lowerQuery = query.toLowerCase();
      return snapshot.docs
          .map((doc) => TrabajadorModel.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .where((worker) {
            return worker.fullName.toLowerCase().contains(lowerQuery) ||
                worker.identification.toLowerCase().contains(lowerQuery) ||
                worker.position.toLowerCase().contains(lowerQuery);
          })
          .toList();
    } catch (e) {
      throw ServerException('Error al buscar trabajadores: $e');
    }
  }

  // === IMPLEMENTACIÓN PAGOS Y PRÉSTAMOS ===
  @override
  Future<List<PagoModel>> getPagosByWorker(String farmId, String workerId) async {
    try {
      final snapshot = await firestore
          .collection('farms')
          .doc(farmId)
          .collection('workers')
          .doc(workerId)
          .collection('pagos')
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => PagoModel.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      throw ServerException('Error al obtener los pagos: $e');
    }
  }

  @override
  Stream<List<PagoModel>> getPagosByWorkerStream(String farmId, String workerId) {
    try {
      return firestore
          .collection('farms')
          .doc(farmId)
          .collection('workers')
          .doc(workerId)
          .collection('pagos')
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => PagoModel.fromJson({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList();
      });
    } catch (e) {
      throw ServerException('Error al obtener el stream de pagos: $e');
    }
  }

  @override
  Future<PagoModel> addPago(PagoModel pago) async {
    try {
      final docRef = firestore
          .collection('farms')
          .doc(pago.farmId)
          .collection('workers')
          .doc(pago.workerId)
          .collection('pagos')
          .doc(pago.id);

      final json = pago.toJson();
      json.remove('id'); // No guardar el ID en el documento

      await docRef.set(json);

      // Retornar el modelo con el ID original (no el de Firestore)
      return PagoModel.fromJson({
        ...json,
        'id': pago.id, // Usar el ID original que se pasó
      });
    } catch (e) {
      throw ServerException('Error al agregar pago: $e');
    }
  }

  @override
  Future<PagoModel> updatePago(PagoModel pago) async {
    try {
      await firestore
          .collection('farms')
          .doc(pago.farmId)
          .collection('workers')
          .doc(pago.workerId)
          .collection('pagos')
          .doc(pago.id)
          .update(pago.toJson());

      return pago;
    } catch (e) {
      throw ServerException('Error al actualizar pago: $e');
    }
  }

  @override
  Future<void> deletePago(String farmId, String workerId, String pagoId) async {
    try {
      await firestore
          .collection('farms')
          .doc(farmId)
          .collection('workers')
          .doc(workerId)
          .collection('pagos')
          .doc(pagoId)
          .delete();
    } catch (e) {
      throw ServerException('Error al eliminar pago: $e');
    }
  }

  @override
  Future<List<PrestamoModel>> getPrestamosByWorker(String farmId, String workerId) async {
    try {
      final snapshot = await firestore
          .collection('farms')
          .doc(farmId)
          .collection('workers')
          .doc(workerId)
          .collection('prestamos')
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => PrestamoModel.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      throw ServerException('Error al obtener los préstamos: $e');
    }
  }

  @override
  Stream<List<PrestamoModel>> getPrestamosByWorkerStream(String farmId, String workerId) {
    try {
      return firestore
          .collection('farms')
          .doc(farmId)
          .collection('workers')
          .doc(workerId)
          .collection('prestamos')
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => PrestamoModel.fromJson({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList();
      });
    } catch (e) {
      throw ServerException('Error al obtener el stream de préstamos: $e');
    }
  }

  @override
  Future<PrestamoModel> addPrestamo(PrestamoModel prestamo) async {
    try {
      final docRef = firestore
          .collection('farms')
          .doc(prestamo.farmId)
          .collection('workers')
          .doc(prestamo.workerId)
          .collection('prestamos')
          .doc(prestamo.id);

      final json = prestamo.toJson();
      json.remove('id'); // Firestore genera el ID

      await docRef.set(json);

      return PrestamoModel.fromJson({
        ...json,
        'id': docRef.id,
      });
    } catch (e) {
      throw ServerException('Error al agregar préstamo: $e');
    }
  }

  @override
  Future<PrestamoModel> updatePrestamo(PrestamoModel prestamo) async {
    try {
      await firestore
          .collection('farms')
          .doc(prestamo.farmId)
          .collection('workers')
          .doc(prestamo.workerId)
          .collection('prestamos')
          .doc(prestamo.id)
          .update(prestamo.toJson());

      return prestamo;
    } catch (e) {
      throw ServerException('Error al actualizar préstamo: $e');
    }
  }

  @override
  Future<void> deletePrestamo(String farmId, String workerId, String prestamoId) async {
    try {
      await firestore
          .collection('farms')
          .doc(farmId)
          .collection('workers')
          .doc(workerId)
          .collection('prestamos')
          .doc(prestamoId)
          .delete();
    } catch (e) {
      throw ServerException('Error al eliminar préstamo: $e');
    }
  }
}

