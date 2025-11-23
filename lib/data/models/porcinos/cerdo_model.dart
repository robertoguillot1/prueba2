import '../../../domain/entities/porcinos/cerdo.dart';

/// Modelo de datos para Cerdo
class CerdoModel extends Cerdo {
  const CerdoModel({
    required String id,
    required String farmId,
    String? identification,
    required CerdoGender gender,
    required DateTime birthDate,
    required double currentWeight,
    required FeedingStage feedingStage,
    String? notes,
    required DateTime updatedAt,
  }) : super(
          id: id,
          farmId: farmId,
          identification: identification,
          gender: gender,
          birthDate: birthDate,
          currentWeight: currentWeight,
          feedingStage: feedingStage,
          notes: notes,
          updatedAt: updatedAt,
        );

  /// Crea un modelo desde JSON
  factory CerdoModel.fromJson(Map<String, dynamic> json) {
    return CerdoModel(
      id: json['id'] as String,
      farmId: json['farmId'] as String,
      identification: json['identification'] as String?,
      gender: CerdoGender.values.firstWhere(
        (e) => e.name == json['gender'],
        orElse: () => CerdoGender.male,
      ),
      birthDate: DateTime.parse(json['birthDate'] as String),
      currentWeight: (json['currentWeight'] as num).toDouble(),
      feedingStage: FeedingStage.values.firstWhere(
        (e) => e.name == json['feedingStage'],
        orElse: () => FeedingStage.inicio,
      ),
      notes: json['notes'] as String?,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convierte el modelo a JSON
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

  /// Crea una copia del modelo con campos modificados
  CerdoModel copyWith({
    String? id,
    String? farmId,
    String? identification,
    CerdoGender? gender,
    DateTime? birthDate,
    double? currentWeight,
    FeedingStage? feedingStage,
    String? notes,
    DateTime? updatedAt,
  }) {
    return CerdoModel(
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

  /// Convierte la entidad a modelo
  factory CerdoModel.fromEntity(Cerdo entity) {
    return CerdoModel(
      id: entity.id,
      farmId: entity.farmId,
      identification: entity.identification,
      gender: entity.gender,
      birthDate: entity.birthDate,
      currentWeight: entity.currentWeight,
      feedingStage: entity.feedingStage,
      notes: entity.notes,
      updatedAt: entity.updatedAt,
    );
  }
}

