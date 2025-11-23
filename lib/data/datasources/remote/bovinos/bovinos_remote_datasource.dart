import '../../../../core/config/api_config.dart';
import '../../../../core/utils/result.dart';
import '../../../models/bovinos/bovino_model.dart';
import '../api_client.dart';

/// Data source remoto para Bovinos
abstract class BovinosRemoteDataSource {
  Future<Result<List<BovinoModel>>> fetchAll(String farmId);
  Future<Result<BovinoModel>> fetchById(String farmId, String id);
  Future<Result<BovinoModel>> create(String farmId, BovinoModel bovino);
  Future<Result<BovinoModel>> update(String farmId, BovinoModel bovino);
  Future<Result<void>> delete(String farmId, String id);
  Future<Result<List<BovinoModel>>> search(String farmId, String query);
}

class BovinosRemoteDataSourceImpl implements BovinosRemoteDataSource {
  final ApiClient apiClient;

  BovinosRemoteDataSourceImpl(this.apiClient);

  @override
  Future<Result<List<BovinoModel>>> fetchAll(String farmId) async {
    final result = await apiClient.get(ApiConfig.bovinos(farmId));
    return result.map((data) {
      final List<dynamic> items = data['data'] as List<dynamic>;
      return items.map((json) => BovinoModel.fromJson(json as Map<String, dynamic>)).toList();
    });
  }

  @override
  Future<Result<BovinoModel>> fetchById(String farmId, String id) async {
    final result = await apiClient.get(ApiConfig.bovino(farmId, id));
    return result.map((data) {
      return BovinoModel.fromJson(data['data'] as Map<String, dynamic>);
    });
  }

  @override
  Future<Result<BovinoModel>> create(String farmId, BovinoModel bovino) async {
    final result = await apiClient.post(
      ApiConfig.bovinos(farmId),
      bovino.toJson(),
    );
    return result.map((data) {
      return BovinoModel.fromJson(data['data'] as Map<String, dynamic>);
    });
  }

  @override
  Future<Result<BovinoModel>> update(String farmId, BovinoModel bovino) async {
    final result = await apiClient.put(
      ApiConfig.bovino(farmId, bovino.id),
      bovino.toJson(),
    );
    return result.map((data) {
      return BovinoModel.fromJson(data['data'] as Map<String, dynamic>);
    });
  }

  @override
  Future<Result<void>> delete(String farmId, String id) async {
    return await apiClient.delete(ApiConfig.bovino(farmId, id));
  }

  @override
  Future<Result<List<BovinoModel>>> search(String farmId, String query) async {
    final result = await apiClient.get('${ApiConfig.bovinos(farmId)}/search?q=$query');
    return result.map((data) {
      final List<dynamic> items = data['data'] as List<dynamic>;
      return items.map((json) => BovinoModel.fromJson(json as Map<String, dynamic>)).toList();
    });
  }
}

