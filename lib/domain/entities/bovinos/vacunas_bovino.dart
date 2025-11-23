/// Entidad de dominio para Vacuna de Bovino
class VacunasBovino {
  final String id;
  final String bovinoId;
  final String farmId;
  final DateTime date;
  final String vaccineName;
  final String? batchNumber;
  final String? notes;
  final DateTime? nextDoseDate;
  final String? administeredBy;
  final String? observations;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const VacunasBovino({
    required this.id,
    required this.bovinoId,
    required this.farmId,
    required this.date,
    required this.vaccineName,
    this.batchNumber,
    this.notes,
    this.nextDoseDate,
    this.administeredBy,
    this.observations,
    this.createdAt,
    this.updatedAt,
  });

  /// Indica si necesita próxima dosis
  bool get necesitaProximaDosis {
    if (nextDoseDate == null) return false;
    final now = DateTime.now();
    return nextDoseDate!.isAfter(now) && 
           nextDoseDate!.difference(now).inDays <= 30;
  }

  /// Valida que la entidad sea válida
  bool get isValid {
    if (id.isEmpty || bovinoId.isEmpty || farmId.isEmpty) return false;
    if (vaccineName.isEmpty) return false;
    if (date.isAfter(DateTime.now())) return false;
    if (nextDoseDate != null && 
        nextDoseDate!.isBefore(date)) return false;
    return true;
  }
}


