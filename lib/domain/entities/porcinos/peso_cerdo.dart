/// Entidad de dominio para Peso de Cerdo
class PesoCerdo {
  final String id;
  final String cerdoId;
  final String farmId;
  final DateTime recordDate;
  final double weight;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PesoCerdo({
    required this.id,
    required this.cerdoId,
    required this.farmId,
    required this.recordDate,
    required this.weight,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  /// Valida que la entidad sea válida
  bool get isValid {
    if (id.isEmpty || cerdoId.isEmpty || farmId.isEmpty) return false;
    if (weight <= 0) return false;
    if (recordDate.isAfter(DateTime.now())) return false;
    return true;
  }
}

