import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/milk_production_model.dart';

/// Excepción para errores del servidor
class ServerException implements Exception {
  final String message;
  const ServerException(this.message);

  @override
  String toString() => message;
}

/// Contrato abstracto para el datasource remoto de Producción de Leche
abstract class MilkProductionRemoteDataSource {
  /// Obtiene todos los registros de producción de leche de un bovino
  Future<List<MilkProductionModel>> getProductionsByBovine(
    String bovineId,
    String farmId,
  );

  /// Obtiene la producción de leche por rango de fechas
  Future<List<MilkProductionModel>> getProductionsByDateRange(
    String farmId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Obtiene un registro de producción por su ID
  Future<MilkProductionModel> getProductionById(
    String id,
    String bovineId,
    String farmId,
  );

  /// Agrega un nuevo registro de producción de leche
  Future<MilkProductionModel> addProduction(MilkProductionModel production);

  /// Actualiza un registro de producción existente
  Future<MilkProductionModel> updateProduction(MilkProductionModel production);

  /// Elimina un registro de producción por su ID
  Future<void> deleteProduction(String id, String bovineId, String farmId);
}

/// Implementación del datasource usando Firestore
class MilkProductionRemoteDataSourceImpl
    implements MilkProductionRemoteDataSource {
  final FirebaseFirestore firestore;

  MilkProductionRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  /// Referencia a la colección de producción de leche de un bovino
  CollectionReference _getProductionsCollection(String farmId, String bovineId) {
    return firestore
        .collection('farms')
        .doc(farmId)
        .collection('cattle')
        .doc(bovineId)
        .collection('milk_production');
  }

  @override
  Future<List<MilkProductionModel>> getProductionsByBovine(
    String bovineId,
    String farmId,
  ) async {
    try {
      final snapshot = await _getProductionsCollection(farmId, bovineId)
          .orderBy('recordDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => MilkProductionModel.fromJson({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .toList();
    } catch (e) {
      throw ServerException('Error al obtener producción de leche: $e');
    }
  }

  @override
  Future<List<MilkProductionModel>> getProductionsByDateRange(
    String farmId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      // Obtener todos los bovinos de la finca
      final cattleSnapshot = await firestore
          .collection('farms')
          .doc(farmId)
          .collection('cattle')
          .get();

      final List<MilkProductionModel> allProductions = [];

      // Para cada bovino, obtener sus producciones en el rango de fechas
      for (final cattleDoc in cattleSnapshot.docs) {
        final productionsSnapshot = await firestore
            .collection('farms')
            .doc(farmId)
            .collection('cattle')
            .doc(cattleDoc.id)
            .collection('milk_production')
            .where('recordDate',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
            .where('recordDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
            .get();

        // Filtrar y ordenar en memoria para evitar problemas con índices compuestos
        final productions = productionsSnapshot.docs
            .map((doc) => MilkProductionModel.fromJson({
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>,
                }))
            .toList();

        // Ordenar por fecha descendente
        productions.sort((a, b) => b.recordDate.compareTo(a.recordDate));

        allProductions.addAll(productions);
      }

      return allProductions;
    } catch (e) {
      throw ServerException('Error al obtener producción por rango de fechas: $e');
    }
  }

  @override
  Future<MilkProductionModel> getProductionById(
    String id,
    String bovineId,
    String farmId,
  ) async {
    try {
      final doc = await _getProductionsCollection(farmId, bovineId).doc(id).get();

      if (!doc.exists) {
        throw ServerException('Registro de producción no encontrado');
      }

      return MilkProductionModel.fromJson({
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      });
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Error al obtener registro de producción: $e');
    }
  }

  @override
  Future<MilkProductionModel> addProduction(
      MilkProductionModel production) async {
    try {
      if (!production.isValid) {
        throw ServerException('Datos de producción inválidos');
      }

      final docRef =
          _getProductionsCollection(production.farmId, production.bovineId).doc();
      final newProduction = production.copyWith(id: docRef.id);

      await docRef.set(newProduction.toJson());

      return newProduction;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Error al crear registro de producción: $e');
    }
  }

  @override
  Future<MilkProductionModel> updateProduction(
      MilkProductionModel production) async {
    try {
      if (!production.isValid) {
        throw ServerException('Datos de producción inválidos');
      }

      final updatedProduction = production.copyWith(updatedAt: DateTime.now());

      await _getProductionsCollection(production.farmId, production.bovineId)
          .doc(production.id)
          .update(updatedProduction.toJson());

      return updatedProduction;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Error al actualizar registro de producción: $e');
    }
  }

  @override
  Future<void> deleteProduction(
      String id, String bovineId, String farmId) async {
    try {
      await _getProductionsCollection(farmId, bovineId).doc(id).delete();
    } catch (e) {
      throw ServerException('Error al eliminar registro de producción: $e');
    }
  }
}

