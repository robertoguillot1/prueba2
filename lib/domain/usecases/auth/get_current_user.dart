import '../../entities/auth/user_entity.dart';
import '../../repositories/auth_repository.dart';

/// Caso de uso para obtener el usuario actual autenticado
class GetCurrentUser {
  final AuthRepository repository;

  GetCurrentUser(this.repository);

  /// Obtiene el usuario actual si hay una sesión activa
  /// Retorna null si no hay sesión iniciada
  Future<UserEntity?> call() async {
    return await repository.getCurrentUser();
  }
}





