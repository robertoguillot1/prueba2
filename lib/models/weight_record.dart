class WeightRecord {
  final String id;
  final String pigId;
  final String farmId;
  final DateTime recordDate;
  final double weight;
  final String? notes;

  WeightRecord({
    required this.id,
    required this.pigId,
    required this.farmId,
    required this.recordDate,
    required this.weight,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pigId': pigId,
      'farmId': farmId,
      'recordDate': recordDate.toIso8601String(),
      'weight': weight,
      'notes': notes,
    };
  }

  factory WeightRecord.fromJson(Map<String, dynamic> json) {
    return WeightRecord(
      id: json['id'] as String,
      pigId: json['pigId'] as String,
      farmId: json['farmId'] as String,
      recordDate: DateTime.parse(json['recordDate'] as String),
      weight: (json['weight'] as num).toDouble(),
      notes: json['notes'] as String?,
    );
  }
}





