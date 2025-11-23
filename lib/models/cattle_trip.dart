class CattleTrip {
  final String id;
  final String farmId;
  final DateTime tripDate;
  final String destination;
  final String purpose;
  final List<String> cattleIds;
  final String? notes;

  CattleTrip({
    required this.id,
    required this.farmId,
    required this.tripDate,
    required this.destination,
    required this.purpose,
    required this.cattleIds,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmId': farmId,
      'tripDate': tripDate.toIso8601String(),
      'destination': destination,
      'purpose': purpose,
      'cattleIds': cattleIds,
      'notes': notes,
    };
  }

  factory CattleTrip.fromJson(Map<String, dynamic> json) {
    return CattleTrip(
      id: json['id'] as String,
      farmId: json['farmId'] as String,
      tripDate: DateTime.parse(json['tripDate'] as String),
      destination: json['destination'] as String,
      purpose: json['purpose'] as String,
      cattleIds: (json['cattleIds'] as List<dynamic>).map((e) => e as String).toList(),
      notes: json['notes'] as String?,
    );
  }

  // Getters para compatibilidad con código existente
  String? get toFarmId => destination;
  bool get isLote => cattleIds.length > 1;
  String? get transporterName => null; // No está en el modelo actual
  String? get vehicleInfo => null; // No está en el modelo actual
  String get reasonString => purpose;
}





