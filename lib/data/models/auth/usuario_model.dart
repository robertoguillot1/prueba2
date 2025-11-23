import '../../../domain/entities/auth/usuario.dart';

/// Modelo de datos para Usuario
class UsuarioModel extends Usuario {
  const UsuarioModel({
    required super.id,
    required super.email,
    required super.nombre,
    required super.rol,
    super.farmId,
    super.photoUrl,
    super.createdAt,
    super.updatedAt,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id: json['id'] as String,
      email: json['email'] as String,
      nombre: json['nombre'] as String,
      rol: Rol.values.firstWhere(
        (r) => r.name == json['rol'],
        orElse: () => Rol.invitado,
      ),
      farmId: json['farmId'] as String?,
      photoUrl: json['photoUrl'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nombre': nombre,
      'rol': rol.name,
      'farmId': farmId,
      'photoUrl': photoUrl,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory UsuarioModel.fromEntity(Usuario usuario) {
    return UsuarioModel(
      id: usuario.id,
      email: usuario.email,
      nombre: usuario.nombre,
      rol: usuario.rol,
      farmId: usuario.farmId,
      photoUrl: usuario.photoUrl,
      createdAt: usuario.createdAt,
      updatedAt: usuario.updatedAt,
    );
  }
}

