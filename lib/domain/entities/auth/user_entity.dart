/// Entidad de dominio para Usuario de autenticación
class UserEntity {
  final String id;
  final String email;

  const UserEntity({
    required this.id,
    required this.email,
  });

  /// Crea una copia de la entidad con los valores actualizados
  UserEntity copyWith({
    String? id,
    String? email,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
    );
  }

  /// Valida que la entidad sea válida
  bool get isValid {
    return id.isNotEmpty && email.isNotEmpty;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserEntity && other.id == id && other.email == email;
  }

  @override
  int get hashCode => id.hashCode ^ email.hashCode;

  @override
  String toString() => 'UserEntity(id: $id, email: $email)';
}





