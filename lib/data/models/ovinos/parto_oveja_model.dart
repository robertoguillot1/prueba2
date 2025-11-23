import '../../../domain/entities/ovinos/parto_oveja.dart';

/// Modelo de datos para PartoOveja
class PartoOvejaModel extends PartoOveja {
  const PartoOvejaModel({
    required super.id,
    required super.ovejaId,
    required super.farmId,
    required super.fechaParto,
    required super.cantidadCrias,
    super.pesoCria,
    super.observaciones,
    super.complicaciones,
    super.tipoParto,
    super.createdAt,
    super.updatedAt,
  });

  /// Crea un modelo desde JSON
  factory PartoOvejaModel.fromJson(Map<String, dynamic> json) {
    return PartoOvejaModel(
      id: json['id'] as String,
      ovejaId: json['ovejaId'] as String,
      farmId: json['farmId'] as String,
      fechaParto: DateTime.parse(json['fechaParto'] as String),
      cantidadCrias: json['cantidadCrias'] as int,
      pesoCria: json['pesoCria'] != null
          ? (json['pesoCria'] as num).toDouble()
          : null,
      observaciones: json['observaciones'] as String?,
      complicaciones: json['complicaciones'] as bool?,
      tipoParto: json['tipoParto'] as String?,
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
      'ovejaId': ovejaId,
      'farmId': farmId,
      'fechaParto': fechaParto.toIso8601String(),
      'cantidadCrias': cantidadCrias,
      'pesoCria': pesoCria,
      'observaciones': observaciones,
      'complicaciones': complicaciones,
      'tipoParto': tipoParto,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Crea una copia del modelo con campos modificados
  PartoOvejaModel copyWith({
    String? id,
    String? ovejaId,
    String? farmId,
    DateTime? fechaParto,
    int? cantidadCrias,
    double? pesoCria,
    String? observaciones,
    bool? complicaciones,
    String? tipoParto,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PartoOvejaModel(
      id: id ?? this.id,
      ovejaId: ovejaId ?? this.ovejaId,
      farmId: farmId ?? this.farmId,
      fechaParto: fechaParto ?? this.fechaParto,
      cantidadCrias: cantidadCrias ?? this.cantidadCrias,
      pesoCria: pesoCria ?? this.pesoCria,
      observaciones: observaciones ?? this.observaciones,
      complicaciones: complicaciones ?? this.complicaciones,
      tipoParto: tipoParto ?? this.tipoParto,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convierte la entidad a modelo
  factory PartoOvejaModel.fromEntity(PartoOveja entity) {
    return PartoOvejaModel(
      id: entity.id,
      ovejaId: entity.ovejaId,
      farmId: entity.farmId,
      fechaParto: entity.fechaParto,
      cantidadCrias: entity.cantidadCrias,
      pesoCria: entity.pesoCria,
      observaciones: entity.observaciones,
      complicaciones: entity.complicaciones,
      tipoParto: entity.tipoParto,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

