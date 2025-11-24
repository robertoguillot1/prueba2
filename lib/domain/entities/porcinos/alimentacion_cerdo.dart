/// Entidad de dominio para Alimentación de Cerdo
class AlimentacionCerdo {
  final String id;
  final String? cerdoId;
  final String farmId;
  final DateTime fecha;
  final double cantidadAlimento; // En kg
  final String tipoAlimento;
  final double? costo;
  final String? proveedor;
  final String? observaciones;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AlimentacionCerdo({
    required this.id,
    this.cerdoId,
    required this.farmId,
    required this.fecha,
    required this.cantidadAlimento,
    required this.tipoAlimento,
    this.costo,
    this.proveedor,
    this.observaciones,
    this.createdAt,
    this.updatedAt,
  });

  /// Valida que la entidad sea válida
  bool get isValid {
    if (id.isEmpty || farmId.isEmpty) return false;
    if (cantidadAlimento <= 0) return false;
    if (tipoAlimento.isEmpty) return false;
    if (costo != null && costo! < 0) return false;
    if (fecha.isAfter(DateTime.now())) return false;
    return true;
  }
}



