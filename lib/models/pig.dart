enum PigGender {
  male,
  female,
}

enum FeedingStage {
  inicio,
  levante,
  engorde,
}

extension FeedingStageExtension on FeedingStage {
  // Mapeo de valores antiguos para compatibilidad
  static FeedingStage? _parseFeedingStage(String value) {
    switch (value) {
      case 'desarrollo':
        return FeedingStage.levante;
      case 'finalizacion':
        return FeedingStage.engorde;
      case 'inicio':
        return FeedingStage.inicio;
      case 'levante':
        return FeedingStage.levante;
      case 'engorde':
        return FeedingStage.engorde;
      default:
        return FeedingStage.values.firstWhere(
          (e) => e.name == value,
          orElse: () => FeedingStage.inicio,
        );
    }
  }
}

class Pig {
  final String id;
  final String farmId;
  final String? identification;
  final PigGender gender;
  final DateTime birthDate;
  final double currentWeight;
  final FeedingStage feedingStage;
  final String? notes;
  final DateTime updatedAt;

  Pig({
    required this.id,
    required this.farmId,
    this.identification,
    required this.gender,
    required this.birthDate,
    required this.currentWeight,
    required this.feedingStage,
    this.notes,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmId': farmId,
      'identification': identification,
      'gender': gender.name,
      'birthDate': birthDate.toIso8601String(),
      'currentWeight': currentWeight,
      'feedingStage': feedingStage.name,
      'notes': notes,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Pig.fromJson(Map<String, dynamic> json) {
    return Pig(
      id: json['id'] as String,
      farmId: json['farmId'] as String,
      identification: json['identification'] as String?,
      gender: PigGender.values.firstWhere(
        (e) => e.name == json['gender'],
        orElse: () => PigGender.male,
      ),
      birthDate: DateTime.parse(json['birthDate'] as String),
      currentWeight: (json['currentWeight'] as num).toDouble(),
      feedingStage: FeedingStageExtension._parseFeedingStage(json['feedingStage'] as String) ?? FeedingStage.inicio,
      notes: json['notes'] as String?,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  String get genderString {
    switch (gender) {
      case PigGender.male:
        return 'Macho';
      case PigGender.female:
        return 'Hembra';
    }
  }

  String get feedingStageString {
    switch (feedingStage) {
      case FeedingStage.inicio:
        return 'Inicio';
      case FeedingStage.levante:
        return 'Levante';
      case FeedingStage.engorde:
        return 'Engorde';
    }
  }

  double get estimatedDailyConsumption {
    // Estimación basada en el peso y etapa de alimentación
    double baseConsumption = currentWeight * 0.04; // 4% del peso
    switch (feedingStage) {
      case FeedingStage.inicio:
        return baseConsumption * 0.8;
      case FeedingStage.levante:
        return baseConsumption;
      case FeedingStage.engorde:
        return baseConsumption * 1.2;
    }
  }

  int get ageInDays {
    final now = DateTime.now();
    return now.difference(birthDate).inDays;
  }

  Pig copyWith({
    String? id,
    String? farmId,
    String? identification,
    PigGender? gender,
    DateTime? birthDate,
    double? currentWeight,
    FeedingStage? feedingStage,
    String? notes,
    DateTime? updatedAt,
  }) {
    return Pig(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      identification: identification ?? this.identification,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      currentWeight: currentWeight ?? this.currentWeight,
      feedingStage: feedingStage ?? this.feedingStage,
      notes: notes ?? this.notes,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}





