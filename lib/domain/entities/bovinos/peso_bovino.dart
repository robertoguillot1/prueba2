/// Entidad de dominio para Peso de Bovino
class PesoBovino {
  final String id;
  final String bovinoId;
  final String farmId;
  final DateTime recordDate;
  final double weight;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PesoBovino({
    required this.id,
    required this.bovinoId,
    required this.farmId,
    required this.recordDate,
    required this.weight,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  /// Valida que la entidad sea válida
  bool get isValid {
    if (id.isEmpty || bovinoId.isEmpty || farmId.isEmpty) return false;
    if (weight <= 0) return false;
    if (recordDate.isAfter(DateTime.now())) return false;
    return true;
  }
}


