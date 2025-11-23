import '../../../../core/config/api_config.dart';
import '../../../../core/utils/result.dart';
import '../../../models/porcinos/cerdo_model.dart';
import '../api_client.dart';

/// Data source remoto para Porcinos
abstract class PorcinosRemoteDataSource {
  Future<Result<List<CerdoModel>>> fetchAll(String farmId);
  Future<Result<CerdoModel>> fetchById(String farmId, String id);
  Future<Result<CerdoModel>> create(String farmId, CerdoModel cerdo);
  Future<Result<CerdoModel>> update(String farmId, CerdoModel cerdo);
  Future<Result<void>> delete(String farmId, String id);
  Future<Result<List<CerdoModel>>> search(String farmId, String query);
}

class PorcinosRemoteDataSourceImpl implements PorcinosRemoteDataSource {
  final ApiClient apiClient;

  PorcinosRemoteDataSourceImpl(this.apiClient);

  @override
  Future<Result<List<CerdoModel>>> fetchAll(String farmId) async {
    final result = await apiClient.get(ApiConfig.cerdos(farmId));
    return result.map((data) {
      final List<dynamic> items = data['data'] as List<dynamic>;
      return items.map((json) => CerdoModel.fromJson(json as Map<String, dynamic>)).toList();
    });
  }

  @override
  Future<Result<CerdoModel>> fetchById(String farmId, String id) async {
    final result = await apiClient.get(ApiConfig.cerdo(farmId, id));
    return result.map((data) {
      return CerdoModel.fromJson(data['data'] as Map<String, dynamic>);
    });
  }

  @override
  Future<Result<CerdoModel>> create(String farmId, CerdoModel cerdo) async {
    final result = await apiClient.post(
      ApiConfig.cerdos(farmId),
      cerdo.toJson(),
    );
    return result.map((data) {
      return CerdoModel.fromJson(data['data'] as Map<String, dynamic>);
    });
  }

  @override
  Future<Result<CerdoModel>> update(String farmId, CerdoModel cerdo) async {
    final result = await apiClient.put(
      ApiConfig.cerdo(farmId, cerdo.id),
      cerdo.toJson(),
    );
    return result.map((data) {
      return CerdoModel.fromJson(data['data'] as Map<String, dynamic>);
    });
  }

  @override
  Future<Result<void>> delete(String farmId, String id) async {
    return await apiClient.delete(ApiConfig.cerdo(farmId, id));
  }

  @override
  Future<Result<List<CerdoModel>>> search(String farmId, String query) async {
    final result = await apiClient.get('${ApiConfig.cerdos(farmId)}/search?q=$query');
    return result.map((data) {
      final List<dynamic> items = data['data'] as List<dynamic>;
      return items.map((json) => CerdoModel.fromJson(json as Map<String, dynamic>)).toList();
    });
  }
}

