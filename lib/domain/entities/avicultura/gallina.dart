/// Entidad de dominio para Gallina
class Gallina {
  final String id;
  final String farmId;
  final String? identification;
  final String? name;
  final DateTime fechaNacimiento;
  final String? raza;
  final GallinaGender gender;
  final EstadoGallina estado;
  final DateTime? fechaIngresoLote;
  final String? loteId;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Gallina({
    required this.id,
    required this.farmId,
    this.identification,
    this.name,
    required this.fechaNacimiento,
    this.raza,
    required this.gender,
    required this.estado,
    this.fechaIngresoLote,
    this.loteId,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  /// Calcula la edad en semanas
  int get edadEnSemanas {
    final now = DateTime.now();
    final diferencia = now.difference(fechaNacimiento).inDays;
    return (diferencia / 7).floor();
  }

  /// Indica si está en pico de producción (18-30 semanas)
  bool get estaEnPicoProduccion {
    return edadEnSemanas >= 18 && edadEnSemanas <= 30;
  }

  /// Indica si debe descartarse (> 100 semanas)
  bool get debeDescartarse {
    return edadEnSemanas > 100;
  }

  /// Valida que la entidad sea válida
  bool get isValid {
    if (id.isEmpty || farmId.isEmpty) return false;
    if (fechaNacimiento.isAfter(DateTime.now())) return false;
    return true;
  }
}

/// Género de la gallina
enum GallinaGender {
  male,
  female,
}

/// Estado de la gallina
enum EstadoGallina {
  activa,
  enferma,
  muerta,
  descartada,
}

