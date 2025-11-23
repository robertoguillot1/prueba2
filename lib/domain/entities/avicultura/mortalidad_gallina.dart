/// Entidad de dominio para Mortalidad de Gallina
class MortalidadGallina {
  final String id;
  final String gallinaId;
  final String? loteId;
  final String farmId;
  final DateTime fechaMuerte;
  final String? causaMuerte;
  final int? edadEnSemanas;
  final double? peso;
  final String? observaciones;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MortalidadGallina({
    required this.id,
    required this.gallinaId,
    this.loteId,
    required this.farmId,
    required this.fechaMuerte,
    this.causaMuerte,
    this.edadEnSemanas,
    this.peso,
    this.observaciones,
    this.createdAt,
    this.updatedAt,
  });

  /// Valida que la entidad sea válida
  bool get isValid {
    if (id.isEmpty || gallinaId.isEmpty || farmId.isEmpty) return false;
    if (fechaMuerte.isAfter(DateTime.now())) return false;
    if (edadEnSemanas != null && edadEnSemanas! < 0) return false;
    if (peso != null && peso! < 0) return false;
    return true;
  }
}


