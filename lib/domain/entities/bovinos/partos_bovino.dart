/// Entidad de dominio para Parto de Bovino
class PartosBovino {
  final String id;
  final String bovinoId;
  final String farmId;
  final DateTime fechaParto;
  final int? cantidadCrias;
  final double? pesoCria;
  final String? tipoParto; // Normal, Cesárea, etc.
  final bool? complicaciones;
  final String? observaciones;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PartosBovino({
    required this.id,
    required this.bovinoId,
    required this.farmId,
    required this.fechaParto,
    this.cantidadCrias,
    this.pesoCria,
    this.tipoParto,
    this.complicaciones,
    this.observaciones,
    this.createdAt,
    this.updatedAt,
  });

  /// Valida que la entidad sea válida
  bool get isValid {
    if (id.isEmpty || bovinoId.isEmpty || farmId.isEmpty) return false;
    if (cantidadCrias != null && cantidadCrias! < 0) return false;
    if (pesoCria != null && pesoCria! < 0) return false;
    if (fechaParto.isAfter(DateTime.now())) return false;
    return true;
  }
}



