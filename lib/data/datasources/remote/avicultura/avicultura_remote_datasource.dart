import '../../../../core/config/api_config.dart';
import '../../../../core/utils/result.dart';
import '../../../models/avicultura/gallina_model.dart';
import '../api_client.dart';

/// Data source remoto para Avicultura
abstract class AviculturaRemoteDataSource {
  Future<Result<List<GallinaModel>>> fetchAll(String farmId);
  Future<Result<GallinaModel>> fetchById(String farmId, String id);
  Future<Result<GallinaModel>> create(String farmId, GallinaModel gallina);
  Future<Result<GallinaModel>> update(String farmId, GallinaModel gallina);
  Future<Result<void>> delete(String farmId, String id);
  Future<Result<List<GallinaModel>>> search(String farmId, String query);
}

class AviculturaRemoteDataSourceImpl implements AviculturaRemoteDataSource {
  final ApiClient apiClient;

  AviculturaRemoteDataSourceImpl(this.apiClient);

  @override
  Future<Result<List<GallinaModel>>> fetchAll(String farmId) async {
    final result = await apiClient.get(ApiConfig.gallinas(farmId));
    return result.map((data) {
      final List<dynamic> items = data['data'] as List<dynamic>;
      return items.map((json) => GallinaModel.fromJson(json as Map<String, dynamic>)).toList();
    });
  }

  @override
  Future<Result<GallinaModel>> fetchById(String farmId, String id) async {
    final result = await apiClient.get(ApiConfig.gallina(farmId, id));
    return result.map((data) {
      return GallinaModel.fromJson(data['data'] as Map<String, dynamic>);
    });
  }

  @override
  Future<Result<GallinaModel>> create(String farmId, GallinaModel gallina) async {
    final result = await apiClient.post(
      ApiConfig.gallinas(farmId),
      gallina.toJson(),
    );
    return result.map((data) {
      return GallinaModel.fromJson(data['data'] as Map<String, dynamic>);
    });
  }

  @override
  Future<Result<GallinaModel>> update(String farmId, GallinaModel gallina) async {
    final result = await apiClient.put(
      ApiConfig.gallina(farmId, gallina.id),
      gallina.toJson(),
    );
    return result.map((data) {
      return GallinaModel.fromJson(data['data'] as Map<String, dynamic>);
    });
  }

  @override
  Future<Result<void>> delete(String farmId, String id) async {
    return await apiClient.delete(ApiConfig.gallina(farmId, id));
  }

  @override
  Future<Result<List<GallinaModel>>> search(String farmId, String query) async {
    final result = await apiClient.get('${ApiConfig.gallinas(farmId)}/search?q=$query');
    return result.map((data) {
      final List<dynamic> items = data['data'] as List<dynamic>;
      return items.map((json) => GallinaModel.fromJson(json as Map<String, dynamic>)).toList();
    });
  }
}

