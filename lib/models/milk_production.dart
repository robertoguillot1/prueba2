class MilkProduction {
  final String id;
  final String cattleId;
  final String farmId;
  final DateTime recordDate;
  final double litersProduced;
  final String? notes;

  MilkProduction({
    required this.id,
    required this.cattleId,
    required this.farmId,
    required this.recordDate,
    required this.litersProduced,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cattleId': cattleId,
      'farmId': farmId,
      'recordDate': recordDate.toIso8601String(),
      'litersProduced': litersProduced,
      'notes': notes,
    };
  }

  factory MilkProduction.fromJson(Map<String, dynamic> json) {
    return MilkProduction(
      id: json['id'] as String,
      cattleId: json['cattleId'] as String,
      farmId: json['farmId'] as String,
      recordDate: DateTime.parse(json['recordDate'] as String),
      litersProduced: (json['litersProduced'] as num).toDouble(),
      notes: json['notes'] as String?,
    );
  }
}





