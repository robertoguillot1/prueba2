/// Entidad de dominio para Parto de Oveja
class PartoOveja {
  final String id;
  final String ovejaId;
  final String farmId;
  final DateTime fechaParto;
  final int cantidadCrias;
  final double? pesoCria;
  final String? observaciones;
  final bool? complicaciones;
  final String? tipoParto; // Normal, Cesárea, etc.
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PartoOveja({
    required this.id,
    required this.ovejaId,
    required this.farmId,
    required this.fechaParto,
    required this.cantidadCrias,
    this.pesoCria,
    this.observaciones,
    this.complicaciones,
    this.tipoParto,
    this.createdAt,
    this.updatedAt,
  });

  /// Valida que la entidad sea válida
  bool get isValid {
    if (id.isEmpty || ovejaId.isEmpty || farmId.isEmpty) return false;
    if (cantidadCrias < 0) return false;
    if (pesoCria != null && pesoCria! < 0) return false;
    if (fechaParto.isAfter(DateTime.now())) return false;
    return true;
  }
}

