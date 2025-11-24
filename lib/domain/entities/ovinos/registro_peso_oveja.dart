/// Entidad de dominio para Registro de Peso de Oveja
class RegistroPesoOveja {
  final String id;
  final String ovejaId;
  final String farmId;
  final DateTime fechaRegistro;
  final double peso;
  final String? observaciones;
  final String? condicionCorporal; // Delgada, Normal, Gorda
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const RegistroPesoOveja({
    required this.id,
    required this.ovejaId,
    required this.farmId,
    required this.fechaRegistro,
    required this.peso,
    this.observaciones,
    this.condicionCorporal,
    this.createdAt,
    this.updatedAt,
  });

  /// Valida que la entidad sea válida
  bool get isValid {
    if (id.isEmpty || ovejaId.isEmpty || farmId.isEmpty) return false;
    if (peso <= 0) return false;
    if (fechaRegistro.isAfter(DateTime.now())) return false;
    return true;
  }
}



