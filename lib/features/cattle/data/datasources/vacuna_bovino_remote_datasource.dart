import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/failures.dart';
import '../models/vacuna_bovino_model.dart';

/// Interface para el datasource remoto de vacunas
abstract class VacunaBovinoRemoteDataSource {
  Future<List<VacunaBovinoModel>> getVacunasByBovino(
    String bovinoId,
    String farmId,
  );
  
  Future<VacunaBovinoModel> getVacunaById(
    String id,
    String bovinoId,
    String farmId,
  );
  
  Future<VacunaBovinoModel> addVacuna(VacunaBovinoModel vacuna);
  
  Future<VacunaBovinoModel> updateVacuna(VacunaBovinoModel vacuna);
  
  Future<void> deleteVacuna(String id, String bovinoId, String farmId);
  
  Future<List<VacunaBovinoModel>> getVacunasConRefuerzoPendiente(String farmId);
}

/// Implementación del datasource usando Firestore
class VacunaBovinoRemoteDataSourceImpl implements VacunaBovinoRemoteDataSource {
  final FirebaseFirestore firestore;

  VacunaBovinoRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  /// Referencia a la colección de vacunas de un bovino
  CollectionReference _getVacunasCollection(String farmId, String bovinoId) {
    return firestore
        .collection('farms')
        .doc(farmId)
        .collection('cattle')
        .doc(bovinoId)
        .collection('vaccines');
  }

  @override
  Future<List<VacunaBovinoModel>> getVacunasByBovino(
    String bovinoId,
    String farmId,
  ) async {
    try {
      final snapshot = await _getVacunasCollection(farmId, bovinoId)
          .orderBy('fechaAplicacion', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => VacunaBovinoModel.fromJson({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .toList();
    } catch (e) {
      throw ServerFailure('Error al obtener vacunas: $e');
    }
  }

  @override
  Future<VacunaBovinoModel> getVacunaById(
    String id,
    String bovinoId,
    String farmId,
  ) async {
    try {
      final doc = await _getVacunasCollection(farmId, bovinoId).doc(id).get();

      if (!doc.exists) {
        throw CacheFailure('Vacuna no encontrada');
      }

      return VacunaBovinoModel.fromJson({
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      });
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Error al obtener vacuna: $e');
    }
  }

  @override
  Future<VacunaBovinoModel> addVacuna(VacunaBovinoModel vacuna) async {
    try {
      if (!vacuna.isValid) {
        throw ValidationFailure('Datos de vacuna inválidos');
      }

      final docRef = _getVacunasCollection(vacuna.farmId, vacuna.bovinoId).doc();
      final newVacuna = vacuna.copyWith(id: docRef.id);
      
      await docRef.set(newVacuna.toJson());
      
      return newVacuna;
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Error al crear vacuna: $e');
    }
  }

  @override
  Future<VacunaBovinoModel> updateVacuna(VacunaBovinoModel vacuna) async {
    try {
      if (!vacuna.isValid) {
        throw ValidationFailure('Datos de vacuna inválidos');
      }

      final updatedVacuna = vacuna.copyWith(updatedAt: DateTime.now());
      
      await _getVacunasCollection(vacuna.farmId, vacuna.bovinoId)
          .doc(vacuna.id)
          .update(updatedVacuna.toJson());
      
      return updatedVacuna;
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Error al actualizar vacuna: $e');
    }
  }

  @override
  Future<void> deleteVacuna(String id, String bovinoId, String farmId) async {
    try {
      await _getVacunasCollection(farmId, bovinoId).doc(id).delete();
    } catch (e) {
      throw ServerFailure('Error al eliminar vacuna: $e');
    }
  }

  @override
  Future<List<VacunaBovinoModel>> getVacunasConRefuerzoPendiente(
    String farmId,
  ) async {
    try {
      // Esta consulta es más compleja ya que requiere iterar por todos los bovinos
      // Por simplicidad, retornamos lista vacía y se puede optimizar más adelante
      // con una colección de nivel superior para alertas
      return [];
    } catch (e) {
      throw ServerFailure('Error al obtener vacunas con refuerzo pendiente: $e');
    }
  }
}

