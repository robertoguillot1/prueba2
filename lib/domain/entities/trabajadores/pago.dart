/// Entidad de dominio para Pago/Salario
class Pago {
  final String id;
  final String trabajadorId;
  final String farmId;
  final DateTime date;
  final double amount;
  final TipoPago tipoPago;
  final String? concepto;
  final String? observaciones;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Pago({
    required this.id,
    required this.trabajadorId,
    required this.farmId,
    required this.date,
    required this.amount,
    required this.tipoPago,
    this.concepto,
    this.observaciones,
    this.createdAt,
    this.updatedAt,
  });

  /// Valida que la entidad sea válida
  bool get isValid {
    if (id.isEmpty || trabajadorId.isEmpty || farmId.isEmpty) return false;
    if (amount <= 0) return false;
    if (date.isAfter(DateTime.now())) return false;
    return true;
  }
}

/// Tipo de pago
enum TipoPago {
  salario,
  adelanto,
  bonificacion,
  otro,
}


