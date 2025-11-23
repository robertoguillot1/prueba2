class CattleVaccine {
  final String id;
  final String cattleId;
  final String farmId;
  final DateTime date;
  final String vaccineName;
  final String? batchNumber;
  final String? notes;
  final DateTime? nextDoseDate;
  final String? administeredBy;
  final String? observations;

  CattleVaccine({
    required this.id,
    required this.cattleId,
    required this.farmId,
    required this.date,
    required this.vaccineName,
    this.batchNumber,
    this.notes,
    this.nextDoseDate,
    this.administeredBy,
    this.observations,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cattleId': cattleId,
      'farmId': farmId,
      'date': date.toIso8601String(),
      'vaccineName': vaccineName,
      'batchNumber': batchNumber,
      'notes': notes,
      'nextDoseDate': nextDoseDate?.toIso8601String(),
      'administeredBy': administeredBy,
      'observations': observations,
    };
  }

  factory CattleVaccine.fromJson(Map<String, dynamic> json) {
    return CattleVaccine(
      id: json['id'] as String,
      cattleId: json['cattleId'] as String,
      farmId: json['farmId'] as String,
      date: DateTime.parse(json['date'] as String),
      vaccineName: json['vaccineName'] as String,
      batchNumber: json['batchNumber'] as String?,
      notes: json['notes'] as String?,
      nextDoseDate: json['nextDoseDate'] != null
          ? DateTime.parse(json['nextDoseDate'] as String)
          : null,
      administeredBy: json['administeredBy'] as String?,
      observations: json['observations'] as String?,
    );
  }

  // Getters para compatibilidad con código existente
  DateTime get applicationDate => date;
}





