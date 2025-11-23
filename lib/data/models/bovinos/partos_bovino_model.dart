import '../../../domain/entities/bovinos/partos_bovino.dart';

/// Modelo de datos para PartosBovino
class PartosBovinoModel extends PartosBovino {
  const PartosBovinoModel({
    required super.id,
    required super.bovinoId,
    required super.farmId,
    required super.fechaParto,
    super.cantidadCrias,
    super.pesoCria,
    super.tipoParto,
    super.complicaciones,
    super.observaciones,
    super.createdAt,
    super.updatedAt,
  });

  /// Crea un modelo desde JSON
  factory PartosBovinoModel.fromJson(Map<String, dynamic> json) {
    return PartosBovinoModel(
      id: json['id'] as String,
      bovinoId: json['bovinoId'] as String,
      farmId: json['farmId'] as String,
      fechaParto: DateTime.parse(json['fechaParto'] as String),
      cantidadCrias: json['cantidadCrias'] as int?,
      pesoCria: json['pesoCria'] != null
          ? (json['pesoCria'] as num).toDouble()
          : null,
      tipoParto: json['tipoParto'] as String?,
      complicaciones: json['complicaciones'] as bool?,
      observaciones: json['observaciones'] as String?,
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
      'fechaParto': fechaParto.toIso8601String(),
      'cantidadCrias': cantidadCrias,
      'pesoCria': pesoCria,
      'tipoParto': tipoParto,
      'complicaciones': complicaciones,
      'observaciones': observaciones,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Crea una copia del modelo con campos modificados
  PartosBovinoModel copyWith({
    String? id,
    String? bovinoId,
    String? farmId,
    DateTime? fechaParto,
    int? cantidadCrias,
    double? pesoCria,
    String? tipoParto,
    bool? complicaciones,
    String? observaciones,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PartosBovinoModel(
      id: id ?? this.id,
      bovinoId: bovinoId ?? this.bovinoId,
      farmId: farmId ?? this.farmId,
      fechaParto: fechaParto ?? this.fechaParto,
      cantidadCrias: cantidadCrias ?? this.cantidadCrias,
      pesoCria: pesoCria ?? this.pesoCria,
      tipoParto: tipoParto ?? this.tipoParto,
      complicaciones: complicaciones ?? this.complicaciones,
      observaciones: observaciones ?? this.observaciones,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convierte la entidad a modelo
  factory PartosBovinoModel.fromEntity(PartosBovino entity) {
    return PartosBovinoModel(
      id: entity.id,
      bovinoId: entity.bovinoId,
      farmId: entity.farmId,
      fechaParto: entity.fechaParto,
      cantidadCrias: entity.cantidadCrias,
      pesoCria: entity.pesoCria,
      tipoParto: entity.tipoParto,
      complicaciones: entity.complicaciones,
      observaciones: entity.observaciones,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

