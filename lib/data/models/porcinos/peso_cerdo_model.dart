import '../../../domain/entities/porcinos/peso_cerdo.dart';

/// Modelo de datos para PesoCerdo
class PesoCerdoModel extends PesoCerdo {
  const PesoCerdoModel({
    required super.id,
    required super.cerdoId,
    required super.farmId,
    required super.recordDate,
    required super.weight,
    super.notes,
    super.createdAt,
    super.updatedAt,
  });

  /// Crea un modelo desde JSON
  factory PesoCerdoModel.fromJson(Map<String, dynamic> json) {
    return PesoCerdoModel(
      id: json['id'] as String,
      cerdoId: json['cerdoId'] as String,
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
      'cerdoId': cerdoId,
      'farmId': farmId,
      'recordDate': recordDate.toIso8601String(),
      'weight': weight,
      'notes': notes,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Crea una copia del modelo con campos modificados
  PesoCerdoModel copyWith({
    String? id,
    String? cerdoId,
    String? farmId,
    DateTime? recordDate,
    double? weight,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PesoCerdoModel(
      id: id ?? this.id,
      cerdoId: cerdoId ?? this.cerdoId,
      farmId: farmId ?? this.farmId,
      recordDate: recordDate ?? this.recordDate,
      weight: weight ?? this.weight,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convierte la entidad a modelo
  factory PesoCerdoModel.fromEntity(PesoCerdo entity) {
    return PesoCerdoModel(
      id: entity.id,
      cerdoId: entity.cerdoId,
      farmId: entity.farmId,
      recordDate: entity.recordDate,
      weight: entity.weight,
      notes: entity.notes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

