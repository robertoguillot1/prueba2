import '../entities/auth/user_entity.dart';

/// Repositorio abstracto para Autenticación
abstract class AuthRepository {
  /// Verifica si ya hay sesión iniciada
  /// Retorna el usuario actual si existe, null si no hay sesión
  Future<UserEntity?> getCurrentUser();

  /// Inicia sesión con email y contraseña
  /// Lanza excepciones si hay error en la autenticación
  Future<void> signInWithEmailAndPassword(String email, String password);

  /// Cierra sesión del usuario actual
  Future<void> signOut();
}


