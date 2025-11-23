import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/entities/auth/usuario.dart';
import '../../data/models/auth/usuario_model.dart';
import '../../core/utils/result.dart';
import '../../core/errors/failures.dart';
import '../../data/datasources/remote/api_client.dart';
import '../../core/config/api_config.dart';

/// Servicio de autenticación
class AuthService {
  final ApiClient _apiClient;
  final SharedPreferences _prefs;
  static const String _userKey = 'current_user';
  static const String _tokenKey = 'auth_token';

  AuthService({
    required ApiClient apiClient,
    required SharedPreferences prefs,
  })  : _apiClient = apiClient,
        _prefs = prefs;

  /// Inicia sesión con email y contraseña
  Future<Result<Usuario>> login(String email, String password) async {
    try {
      final result = await _apiClient.post(
        '/auth/login',
        {
          'email': email,
          'password': password,
        },
      );

      return result.map((data) {
        final token = data['token'] as String;
        final userData = data['user'] as Map<String, dynamic>;
        
        // Guardar token
        _prefs.setString(_tokenKey, token);
        _apiClient.setAuthToken(token);
        
        // Guardar usuario
        final usuario = UsuarioModel.fromJson(userData);
        _prefs.setString(_userKey, jsonEncode(UsuarioModel.fromEntity(usuario).toJson()));
        
        return usuario;
      });
    } catch (e) {
      return Error(UnknownFailure('Error al iniciar sesión: $e'));
    }
  }

  /// Cierra sesión
  Future<void> logout() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userKey);
    _apiClient.clearAuthToken();
  }

  /// Verifica si hay una sesión activa
  Future<bool> hasSession() async {
    final token = _prefs.getString(_tokenKey);
    if (token == null) return false;
    
    _apiClient.setAuthToken(token);
    return true;
  }

  /// Obtiene el usuario actual
  Usuario? getCurrentUser() {
    final userJson = _prefs.getString(_userKey);
    if (userJson == null) return null;
    
    try {
      final userData = jsonDecode(userJson) as Map<String, dynamic>;
      return UsuarioModel.fromJson(userData);
    } catch (e) {
      return null;
    }
  }

  /// Obtiene el token de autenticación
  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  /// Recupera la contraseña
  Future<Result<void>> recoverPassword(String email) async {
    try {
      final result = await _apiClient.post(
        '/auth/recover-password',
        {'email': email},
      );
      return result.map((_) => null);
    } catch (e) {
      return Error(UnknownFailure('Error al recuperar contraseña: $e'));
    }
  }
}

