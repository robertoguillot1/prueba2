import '../../repositories/auth_repository.dart';

/// Caso de uso para registrar un nuevo usuario con email y contraseña
class SignUp {
  final AuthRepository repository;

  SignUp(this.repository);

  /// Registra un nuevo usuario con las credenciales proporcionadas
  /// Lanza excepciones si hay error en el registro
  Future<void> call({
    required String email,
    required String password,
  }) async {
    return await repository.signUpWithEmailAndPassword(email, password);
  }
}



