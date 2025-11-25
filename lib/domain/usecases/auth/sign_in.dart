import '../../repositories/auth_repository.dart';

/// Caso de uso para iniciar sesión con email y contraseña
class SignIn {
  final AuthRepository repository;

  SignIn(this.repository);

  /// Inicia sesión con las credenciales proporcionadas
  /// Lanza excepciones si hay error en la autenticación
  Future<void> call({
    required String email,
    required String password,
  }) async {
    return await repository.signInWithEmailAndPassword(email, password);
  }
}

