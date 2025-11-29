import '../../repositories/auth_repository.dart';

/// Caso de uso para cerrar sesión del usuario actual
class SignOut {
  final AuthRepository repository;

  SignOut(this.repository);

  /// Cierra la sesión del usuario actual
  Future<void> call() async {
    return await repository.signOut();
  }
}







