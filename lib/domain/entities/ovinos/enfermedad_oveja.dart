/// Entidad de dominio para Enfermedad de Oveja
class EnfermedadOveja {
  final String id;
  final String ovejaId;
  final String farmId;
  final DateTime fechaDiagnostico;
  final String nombreEnfermedad;
  final String? sintomas;
  final String? tratamiento;
  final DateTime? fechaRecuperacion;
  final bool curada;
  final String? observaciones;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const EnfermedadOveja({
    required this.id,
    required this.ovejaId,
    required this.farmId,
    required this.fechaDiagnostico,
    required this.nombreEnfermedad,
    this.sintomas,
    this.tratamiento,
    this.fechaRecuperacion,
    this.curada = false,
    this.observaciones,
    this.createdAt,
    this.updatedAt,
  });

  /// Valida que la entidad sea válida
  bool get isValid {
    if (id.isEmpty || ovejaId.isEmpty || farmId.isEmpty) return false;
    if (nombreEnfermedad.isEmpty) return false;
    if (fechaDiagnostico.isAfter(DateTime.now())) return false;
    if (fechaRecuperacion != null && 
        fechaRecuperacion!.isBefore(fechaDiagnostico)) return false;
    return true;
  }

  /// Indica si la enfermedad está activa
  bool get isActiva => !curada;
}

