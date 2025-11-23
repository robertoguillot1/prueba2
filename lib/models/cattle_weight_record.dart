class CattleWeightRecord {
  final String id;
  final String cattleId;
  final String farmId;
  final DateTime recordDate;
  final double weight;
  final String? notes;

  CattleWeightRecord({
    required this.id,
    required this.cattleId,
    required this.farmId,
    required this.recordDate,
    required this.weight,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cattleId': cattleId,
      'farmId': farmId,
      'recordDate': recordDate.toIso8601String(),
      'weight': weight,
      'notes': notes,
    };
  }

  factory CattleWeightRecord.fromJson(Map<String, dynamic> json) {
    return CattleWeightRecord(
      id: json['id'] as String,
      cattleId: json['cattleId'] as String,
      farmId: json['farmId'] as String,
      recordDate: DateTime.parse(json['recordDate'] as String),
      weight: (json['weight'] as num).toDouble(),
      notes: json['notes'] as String?,
    );
  }
}





