enum ReproductionEventType {
  heat,
  insemination,
  pregnancy,
  calving,
  abortion,
}

extension ReproductionEventTypeExtension on ReproductionEventType {
  // Mapeo de valores antiguos
  static ReproductionEventType? fromString(String value) {
    switch (value) {
      case 'fecundacion':
        return ReproductionEventType.insemination;
      case 'parto':
        return ReproductionEventType.calving;
      case 'chequeo':
        return ReproductionEventType.pregnancy;
      case 'aborto':
        return ReproductionEventType.abortion;
      default:
        return ReproductionEventType.values.firstWhere(
          (e) => e.name == value,
          orElse: () => ReproductionEventType.heat,
        );
    }
  }
  
  // Getters para compatibilidad
  bool get isFecundacion => this == ReproductionEventType.insemination;
  bool get isParto => this == ReproductionEventType.calving;
  bool get isChequeo => this == ReproductionEventType.pregnancy;
  bool get isAborto => this == ReproductionEventType.abortion;
}

class ReproductionEvent {
  final String id;
  final String cattleId;
  final String farmId;
  final DateTime eventDate;
  final ReproductionEventType eventType;
  final String? notes;
  final String? relatedCattleId;
  final String? fatherId;
  final bool? calfBorn;
  final String? calfGender;
  final double? calfWeight;

  ReproductionEvent({
    required this.id,
    required this.cattleId,
    required this.farmId,
    required this.eventDate,
    required this.eventType,
    this.notes,
    this.relatedCattleId,
    this.fatherId,
    this.calfBorn,
    this.calfGender,
    this.calfWeight,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cattleId': cattleId,
      'farmId': farmId,
      'eventDate': eventDate.toIso8601String(),
      'eventType': eventType.name,
      'notes': notes,
      'relatedCattleId': relatedCattleId,
      'fatherId': fatherId,
      'calfBorn': calfBorn,
      'calfGender': calfGender,
      'calfWeight': calfWeight,
    };
  }

  factory ReproductionEvent.fromJson(Map<String, dynamic> json) {
    return ReproductionEvent(
      id: json['id'] as String,
      cattleId: json['cattleId'] as String,
      farmId: json['farmId'] as String,
      eventDate: DateTime.parse(json['eventDate'] as String),
      eventType: ReproductionEventType.values.firstWhere(
        (e) => e.name == json['eventType'],
        orElse: () => ReproductionEventType.heat,
      ),
      notes: json['notes'] as String?,
      relatedCattleId: json['relatedCattleId'] as String?,
      fatherId: json['fatherId'] as String?,
      calfBorn: json['calfBorn'] as bool?,
      calfGender: json['calfGender'] as String?,
      calfWeight: json['calfWeight'] != null ? (json['calfWeight'] as num).toDouble() : null,
    );
  }

  String get eventTypeString {
    switch (eventType) {
      case ReproductionEventType.heat:
        return 'Celo';
      case ReproductionEventType.insemination:
        return 'Inseminación';
      case ReproductionEventType.pregnancy:
        return 'Prenada';
      case ReproductionEventType.calving:
        return 'Parto';
      case ReproductionEventType.abortion:
        return 'Aborto';
    }
  }

  // Getters para compatibilidad con código existente
  bool get isCalfBorn => calfBorn ?? (eventType == ReproductionEventType.calving);
  String? get calfId => relatedCattleId;
}





