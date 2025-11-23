import '../../../../core/config/api_config.dart';
import '../../../../core/utils/result.dart';
import '../../../models/trabajadores/trabajador_model.dart';
import '../api_client.dart';

/// Data source remoto para Trabajadores
abstract class TrabajadoresRemoteDataSource {
  Future<Result<List<TrabajadorModel>>> fetchAll(String farmId);
  Future<Result<TrabajadorModel>> fetchById(String farmId, String id);
  Future<Result<TrabajadorModel>> create(String farmId, TrabajadorModel trabajador);
  Future<Result<TrabajadorModel>> update(String farmId, TrabajadorModel trabajador);
  Future<Result<void>> delete(String farmId, String id);
  Future<Result<List<TrabajadorModel>>> search(String farmId, String query);
}

class TrabajadoresRemoteDataSourceImpl implements TrabajadoresRemoteDataSource {
  final ApiClient apiClient;

  TrabajadoresRemoteDataSourceImpl(this.apiClient);

  @override
  Future<Result<List<TrabajadorModel>>> fetchAll(String farmId) async {
    final result = await apiClient.get(ApiConfig.trabajadores(farmId));
    return result.map((data) {
      final List<dynamic> items = data['data'] as List<dynamic>;
      return items.map((json) => TrabajadorModel.fromJson(json as Map<String, dynamic>)).toList();
    });
  }

  @override
  Future<Result<TrabajadorModel>> fetchById(String farmId, String id) async {
    final result = await apiClient.get(ApiConfig.trabajador(farmId, id));
    return result.map((data) {
      return TrabajadorModel.fromJson(data['data'] as Map<String, dynamic>);
    });
  }

  @override
  Future<Result<TrabajadorModel>> create(String farmId, TrabajadorModel trabajador) async {
    final result = await apiClient.post(
      ApiConfig.trabajadores(farmId),
      trabajador.toJson(),
    );
    return result.map((data) {
      return TrabajadorModel.fromJson(data['data'] as Map<String, dynamic>);
    });
  }

  @override
  Future<Result<TrabajadorModel>> update(String farmId, TrabajadorModel trabajador) async {
    final result = await apiClient.put(
      ApiConfig.trabajador(farmId, trabajador.id),
      trabajador.toJson(),
    );
    return result.map((data) {
      return TrabajadorModel.fromJson(data['data'] as Map<String, dynamic>);
    });
  }

  @override
  Future<Result<void>> delete(String farmId, String id) async {
    return await apiClient.delete(ApiConfig.trabajador(farmId, id));
  }

  @override
  Future<Result<List<TrabajadorModel>>> search(String farmId, String query) async {
    final result = await apiClient.get('${ApiConfig.trabajadores(farmId)}/search?q=$query');
    return result.map((data) {
      final List<dynamic> items = data['data'] as List<dynamic>;
      return items.map((json) => TrabajadorModel.fromJson(json as Map<String, dynamic>)).toList();
    });
  }
}

