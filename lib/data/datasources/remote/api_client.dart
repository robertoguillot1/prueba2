import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/api_config.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/result.dart';

/// Cliente HTTP para comunicación con la API REST
/// 
/// Esta clase encapsula todas las operaciones HTTP (GET, POST, PUT, DELETE)
/// y maneja errores de manera consistente.
class ApiClient {
  final String baseUrl;
  final Duration timeout;
  String? _authToken;

  ApiClient({
    String? baseUrl,
    Duration? timeout,
  })  : baseUrl = baseUrl ?? ApiConfig.baseUrl,
        timeout = timeout ?? ApiConfig.timeout;

  /// Establece el token de autenticación
  void setAuthToken(String token) {
    _authToken = token;
  }

  /// Limpia el token de autenticación
  void clearAuthToken() {
    _authToken = null;
  }

  /// Obtiene los headers con autenticación si está disponible
  Map<String, String> _getHeaders() {
    if (_authToken != null) {
      return ApiConfig.headersWithAuth(_authToken!);
    }
    return ApiConfig.headers;
  }

  /// Realiza una petición GET
  /// 
  /// [endpoint] - Ruta del endpoint (sin baseUrl)
  /// 
  /// Retorna un `Result<Map<String, dynamic>>` con la respuesta o un error
  Future<Result<Map<String, dynamic>>> get(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .get(uri, headers: _getHeaders())
          .timeout(timeout);

      return _handleResponse(response);
    } on http.ClientException catch (e) {
      return Error(NetworkFailure('Error de conexión: ${e.message}'));
    } catch (e) {
      return Error(UnknownFailure('Error inesperado: $e'));
    }
  }

  /// Realiza una petición POST
  /// 
  /// [endpoint] - Ruta del endpoint
  /// [body] - Cuerpo de la petición (se serializa a JSON)
  /// 
  /// Retorna un `Result<Map<String, dynamic>>` con la respuesta o un error
  Future<Result<Map<String, dynamic>>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .post(
            uri,
            headers: _getHeaders(),
            body: jsonEncode(body),
          )
          .timeout(timeout);

      return _handleResponse(response);
    } on http.ClientException catch (e) {
      return Error(NetworkFailure('Error de conexión: ${e.message}'));
    } catch (e) {
      return Error(UnknownFailure('Error inesperado: $e'));
    }
  }

  /// Realiza una petición PUT
  /// 
  /// [endpoint] - Ruta del endpoint
  /// [body] - Cuerpo de la petición (se serializa a JSON)
  /// 
  /// Retorna un `Result<Map<String, dynamic>>` con la respuesta o un error
  Future<Result<Map<String, dynamic>>> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .put(
            uri,
            headers: _getHeaders(),
            body: jsonEncode(body),
          )
          .timeout(timeout);

      return _handleResponse(response);
    } on http.ClientException catch (e) {
      return Error(NetworkFailure('Error de conexión: ${e.message}'));
    } catch (e) {
      return Error(UnknownFailure('Error inesperado: $e'));
    }
  }

  /// Realiza una petición DELETE
  /// 
  /// [endpoint] - Ruta del endpoint
  /// 
  /// Retorna un `Result<void>` indicando éxito o error
  Future<Result<void>> delete(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .delete(uri, headers: _getHeaders())
          .timeout(timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return const Success(null);
      }

      return Error(_parseError(response));
    } on http.ClientException catch (e) {
      return Error(NetworkFailure('Error de conexión: ${e.message}'));
    } catch (e) {
      return Error(UnknownFailure('Error inesperado: $e'));
    }
  }

  /// Maneja la respuesta HTTP y la convierte en un Result
  Result<Map<String, dynamic>> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return Success(data);
      } catch (e) {
        return Error(ServerFailure('Error al parsear la respuesta: $e'));
      }
    }

    return Error(_parseError(response));
  }

  /// Parsea un error desde la respuesta HTTP
  Failure _parseError(http.Response response) {
    try {
      final errorData = jsonDecode(response.body) as Map<String, dynamic>;
      final message = errorData['message'] as String? ?? 'Error desconocido';
      
      switch (response.statusCode) {
        case 400:
          return ValidationFailure(message);
        case 401:
          return UnauthorizedFailure(message);
        case 404:
          return NotFoundFailure(message);
        case 500:
        case 502:
        case 503:
          return ServerFailure(message);
        default:
          return UnknownFailure(message);
      }
    } catch (e) {
      return UnknownFailure('Error ${response.statusCode}: ${response.body}');
    }
  }
}



