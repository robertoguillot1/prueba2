import '../../../domain/entities/bovinos/peso_bovino.dart';

/// Modelo de datos para PesoBovino
class PesoBovinoModel extends PesoBovino {
  const PesoBovinoModel({
    required String id,
    required String bovinoId,
    required String farmId,
    required DateTime recordDate,
    required double weight,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super(
          id: id,
          bovinoId: bovinoId,
          farmId: farmId,
          recordDate: recordDate,
          weight: weight,
          notes: notes,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  /// Crea un modelo desde JSON
  factory PesoBovinoModel.fromJson(Map<String, dynamic> json) {
    return PesoBovinoModel(
      id: json['id'] as String,
      bovinoId: json['bovinoId'] as String,
      farmId: json['farmId'] as String,
      recordDate: DateTime.parse(json['recordDate'] as String),
      weight: (json['weight'] as num).toDouble(),
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Convierte el modelo a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bovinoId': bovinoId,
      'farmId': farmId,
      'recordDate': recordDate.toIso8601String(),
      'weight': weight,
      'notes': notes,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Crea una copia del modelo con campos modificados
  PesoBovinoModel copyWith({
    String? id,
    String? bovinoId,
    String? farmId,
    DateTime? recordDate,
    double? weight,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PesoBovinoModel(
      id: id ?? this.id,
      bovinoId: bovinoId ?? this.bovinoId,
      farmId: farmId ?? this.farmId,
      recordDate: recordDate ?? this.recordDate,
      weight: weight ?? this.weight,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convierte la entidad a modelo
  factory PesoBovinoModel.fromEntity(PesoBovino entity) {
    return PesoBovinoModel(
      id: entity.id,
      bovinoId: entity.bovinoId,
      farmId: entity.farmId,
      recordDate: entity.recordDate,
      weight: entity.weight,
      notes: entity.notes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

