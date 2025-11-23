import '../../../../core/config/api_config.dart';
import '../../../../core/utils/result.dart';
import '../../../../domain/entities/ovinos/oveja.dart';
import '../../../models/ovinos/oveja_model.dart';
import '../api_client.dart';

/// Data Source remoto para Ovejas
/// 
/// Implementa las operaciones CRUD usando la API REST.
/// Para usar este data source, reemplaza el `OvejasDataSourceImpl` local
/// en `DependencyInjection` con una instancia de esta clase.
class OvejasRemoteDataSource {
  final ApiClient apiClient;

  OvejasRemoteDataSource(this.apiClient);

  /// Obtiene todas las ovejas de una finca
  Future<Result<List<OvejaModel>>> getAllOvejas(String farmId) async {
    final endpoint = ApiConfig.ovejas(farmId);
    final result = await apiClient.get(endpoint);

    return result.map((data) {
      final List<dynamic> items = data['data'] as List<dynamic>? ?? [];
      return items
          .map((item) => OvejaModel.fromJson(item as Map<String, dynamic>))
          .toList();
    });
  }

  /// Obtiene una oveja por su ID
  Future<Result<OvejaModel>> getOvejaById(String id, String farmId) async {
    final endpoint = ApiConfig.oveja(farmId, id);
    final result = await apiClient.get(endpoint);

    return result.map((data) {
      return OvejaModel.fromJson(data['data'] as Map<String, dynamic>);
    });
  }

  /// Crea una nueva oveja
  Future<Result<OvejaModel>> createOveja(Oveja oveja) async {
    final endpoint = ApiConfig.ovejas(oveja.farmId);
    final body = OvejaModel.fromEntity(oveja).toJson();
    final result = await apiClient.post(endpoint, body);

    return result.map((data) {
      return OvejaModel.fromJson(data['data'] as Map<String, dynamic>);
    });
  }

  /// Actualiza una oveja existente
  Future<Result<OvejaModel>> updateOveja(Oveja oveja) async {
    final endpoint = ApiConfig.oveja(oveja.farmId, oveja.id);
    final body = OvejaModel.fromEntity(oveja).toJson();
    final result = await apiClient.put(endpoint, body);

    return result.map((data) {
      return OvejaModel.fromJson(data['data'] as Map<String, dynamic>);
    });
  }

  /// Elimina una oveja
  Future<Result<void>> deleteOveja(String id, String farmId) async {
    final endpoint = ApiConfig.oveja(farmId, id);
    return await apiClient.delete(endpoint);
  }

  /// Busca ovejas por nombre o identificación
  Future<Result<List<OvejaModel>>> searchOvejas(
    String farmId,
    String query,
  ) async {
    final endpoint = '${ApiConfig.ovejas(farmId)}?search=$query';
    final result = await apiClient.get(endpoint);

    return result.map((data) {
      final List<dynamic> items = data['data'] as List<dynamic>? ?? [];
      return items
          .map((item) => OvejaModel.fromJson(item as Map<String, dynamic>))
          .toList();
    });
  }
}


