import '../../domain/entities/farm/farm.dart';
import '../../domain/repositories/farm_repository.dart';
import '../datasources/remote/farm/farm_remote_datasource.dart';
import '../models/farm/farm_model.dart';

/// Implementación del repositorio de Fincas
class FarmRepositoryImpl implements FarmRepository {
  final FarmRemoteDataSource _remoteDataSource;

  FarmRepositoryImpl({
    required FarmRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Stream<List<Farm>> getFarmsStream(String userId) {
    return _remoteDataSource.getFarmsStream(userId);
  }

  @override
  Future<Farm?> getFarmById(String userId, String farmId) async {
    try {
      return await _remoteDataSource.getFarmById(userId, farmId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Farm> createFarm(Farm farm) async {
    try {
      final farmModel = FarmModel(
        id: farm.id,
        ownerId: farm.ownerId,
        name: farm.name,
        location: farm.location,
        description: farm.description,
        imageUrl: farm.imageUrl,
        primaryColor: farm.primaryColor,
        createdAt: farm.createdAt,
        updatedAt: farm.updatedAt,
      );
      return await _remoteDataSource.createFarm(farmModel);
    } catch (e) {
      throw Exception('Error al crear la finca: $e');
    }
  }

  @override
  Future<Farm> updateFarm(Farm farm) async {
    try {
      final farmModel = FarmModel(
        id: farm.id,
        ownerId: farm.ownerId,
        name: farm.name,
        location: farm.location,
        description: farm.description,
        imageUrl: farm.imageUrl,
        primaryColor: farm.primaryColor,
        createdAt: farm.createdAt,
        updatedAt: farm.updatedAt,
      );
      return await _remoteDataSource.updateFarm(farmModel);
    } catch (e) {
      throw Exception('Error al actualizar la finca: $e');
    }
  }

  @override
  Future<void> deleteFarm(String userId, String farmId) async {
    try {
      await _remoteDataSource.deleteFarm(userId, farmId);
    } catch (e) {
      throw Exception('Error al eliminar la finca: $e');
    }
  }

  @override
  Future<void> setCurrentFarmId(String userId, String farmId) async {
    try {
      await _remoteDataSource.setCurrentFarmId(userId, farmId);
    } catch (e) {
      throw Exception('Error al establecer la finca actual: $e');
    }
  }

  @override
  Future<String?> getCurrentFarmId(String userId) async {
    try {
      return await _remoteDataSource.getCurrentFarmId(userId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Farm>> getFarms(String userId) async {
    try {
      final farmModels = await _remoteDataSource.getFarms(userId);
      return farmModels;
    } catch (e) {
      throw Exception('Error al obtener las fincas: $e');
    }
  }
}

