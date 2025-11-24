/// Entidad de dominio para Producción de Huevos
class ProduccionHuevos {
  final String id;
  final String gallinaId;
  final String? loteId;
  final String farmId;
  final DateTime fecha;
  final int cantidadHuevos;
  final double? pesoPromedio; // En gramos
  final int? huevosComerciales; // Huevos aptos para venta
  final int? huevosDescarte; // Huevos no aptos para venta
  final String? observaciones;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProduccionHuevos({
    required this.id,
    required this.gallinaId,
    this.loteId,
    required this.farmId,
    required this.fecha,
    required this.cantidadHuevos,
    this.pesoPromedio,
    this.huevosComerciales,
    this.huevosDescarte,
    this.observaciones,
    this.createdAt,
    this.updatedAt,
  });

  /// Calcula el porcentaje de huevos comerciales
  double? get porcentajeComerciales {
    if (cantidadHuevos == 0) return null;
    if (huevosComerciales == null) return null;
    return (huevosComerciales! / cantidadHuevos) * 100;
  }

  /// Valida que la entidad sea válida
  bool get isValid {
    if (id.isEmpty || gallinaId.isEmpty || farmId.isEmpty) return false;
    if (cantidadHuevos < 0) return false;
    if (pesoPromedio != null && pesoPromedio! < 0) return false;
    if (huevosComerciales != null && huevosComerciales! < 0) return false;
    if (huevosDescarte != null && huevosDescarte! < 0) return false;
    if (fecha.isAfter(DateTime.now())) return false;
    if (huevosComerciales != null && 
        huevosDescarte != null &&
        (huevosComerciales! + huevosDescarte!) > cantidadHuevos) return false;
    return true;
  }
}



