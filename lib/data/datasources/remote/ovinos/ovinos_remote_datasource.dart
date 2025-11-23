import '../../../../core/config/api_config.dart';
import '../../../../core/utils/result.dart';
import '../../../models/ovinos/oveja_model.dart';
import '../api_client.dart';

/// Data source remoto para Ovinos
abstract class OvinosRemoteDataSource {
  Future<Result<List<OvejaModel>>> fetchAll(String farmId);
  Future<Result<OvejaModel>> fetchById(String farmId, String id);
  Future<Result<OvejaModel>> create(String farmId, OvejaModel oveja);
  Future<Result<OvejaModel>> update(String farmId, OvejaModel oveja);
  Future<Result<void>> delete(String farmId, String id);
  Future<Result<List<OvejaModel>>> search(String farmId, String query);
}

class OvinosRemoteDataSourceImpl implements OvinosRemoteDataSource {
  final ApiClient apiClient;

  OvinosRemoteDataSourceImpl(this.apiClient);

  @override
  Future<Result<List<OvejaModel>>> fetchAll(String farmId) async {
    final result = await apiClient.get(ApiConfig.ovejas(farmId));
    return result.map((data) {
      final List<dynamic> items = data['data'] as List<dynamic>;
      return items.map((json) => OvejaModel.fromJson(json as Map<String, dynamic>)).toList();
    });
  }

  @override
  Future<Result<OvejaModel>> fetchById(String farmId, String id) async {
    final result = await apiClient.get(ApiConfig.oveja(farmId, id));
    return result.map((data) {
      return OvejaModel.fromJson(data['data'] as Map<String, dynamic>);
    });
  }

  @override
  Future<Result<OvejaModel>> create(String farmId, OvejaModel oveja) async {
    final result = await apiClient.post(
      ApiConfig.ovejas(farmId),
      oveja.toJson(),
    );
    return result.map((data) {
      return OvejaModel.fromJson(data['data'] as Map<String, dynamic>);
    });
  }

  @override
  Future<Result<OvejaModel>> update(String farmId, OvejaModel oveja) async {
    final result = await apiClient.put(
      ApiConfig.oveja(farmId, oveja.id),
      oveja.toJson(),
    );
    return result.map((data) {
      return OvejaModel.fromJson(data['data'] as Map<String, dynamic>);
    });
  }

  @override
  Future<Result<void>> delete(String farmId, String id) async {
    return await apiClient.delete(ApiConfig.oveja(farmId, id));
  }

  @override
  Future<Result<List<OvejaModel>>> search(String farmId, String query) async {
    final result = await apiClient.get('${ApiConfig.ovejas(farmId)}/search?q=$query');
    return result.map((data) {
      final List<dynamic> items = data['data'] as List<dynamic>;
      return items.map((json) => OvejaModel.fromJson(json as Map<String, dynamic>)).toList();
    });
  }
}

