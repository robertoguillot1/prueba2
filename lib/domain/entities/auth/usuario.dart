/// Entidad de dominio para Usuario
class Usuario {
  final String id;
  final String email;
  final String nombre;
  final Rol rol;
  final String? farmId;
  final String? photoUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Usuario({
    required this.id,
    required this.email,
    required this.nombre,
    required this.rol,
    this.farmId,
    this.photoUrl,
    this.createdAt,
    this.updatedAt,
  });

  /// Verifica si el usuario es administrador
  bool get isAdmin => rol == Rol.admin;

  /// Verifica si el usuario es trabajador
  bool get isTrabajador => rol == Rol.trabajador;

  /// Verifica si el usuario es invitado
  bool get isInvitado => rol == Rol.invitado;

  /// Verifica si puede crear/editar
  bool get canEdit => isAdmin || isTrabajador;

  /// Verifica si solo puede ver
  bool get canOnlyView => isInvitado;
}

/// Roles de usuario
enum Rol {
  admin,
  trabajador,
  invitado,
}



