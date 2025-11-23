import '../../../domain/entities/avicultura/mortalidad_gallina.dart';

/// Modelo de datos para MortalidadGallina
class MortalidadGallinaModel extends MortalidadGallina {
  const MortalidadGallinaModel({
    required super.id,
    required super.gallinaId,
    super.loteId,
    required super.farmId,
    required super.fechaMuerte,
    super.causaMuerte,
    super.edadEnSemanas,
    super.peso,
    super.observaciones,
    super.createdAt,
    super.updatedAt,
  });

  /// Crea un modelo desde JSON
  factory MortalidadGallinaModel.fromJson(Map<String, dynamic> json) {
    return MortalidadGallinaModel(
      id: json['id'] as String,
      gallinaId: json['gallinaId'] as String,
      loteId: json['loteId'] as String?,
      farmId: json['farmId'] as String,
      fechaMuerte: DateTime.parse(json['fechaMuerte'] as String),
      causaMuerte: json['causaMuerte'] as String?,
      edadEnSemanas: json['edadEnSemanas'] as int?,
      peso: json['peso'] != null
          ? (json['peso'] as num).toDouble()
          : null,
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
      'gallinaId': gallinaId,
      'loteId': loteId,
      'farmId': farmId,
      'fechaMuerte': fechaMuerte.toIso8601String(),
      'causaMuerte': causaMuerte,
      'edadEnSemanas': edadEnSemanas,
      'peso': peso,
      'observaciones': observaciones,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Crea una copia del modelo con campos modificados
  MortalidadGallinaModel copyWith({
    String? id,
    String? gallinaId,
    String? loteId,
    String? farmId,
    DateTime? fechaMuerte,
    String? causaMuerte,
    int? edadEnSemanas,
    double? peso,
    String? observaciones,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MortalidadGallinaModel(
      id: id ?? this.id,
      gallinaId: gallinaId ?? this.gallinaId,
      loteId: loteId ?? this.loteId,
      farmId: farmId ?? this.farmId,
      fechaMuerte: fechaMuerte ?? this.fechaMuerte,
      causaMuerte: causaMuerte ?? this.causaMuerte,
      edadEnSemanas: edadEnSemanas ?? this.edadEnSemanas,
      peso: peso ?? this.peso,
      observaciones: observaciones ?? this.observaciones,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convierte la entidad a modelo
  factory MortalidadGallinaModel.fromEntity(MortalidadGallina entity) {
    return MortalidadGallinaModel(
      id: entity.id,
      gallinaId: entity.gallinaId,
      loteId: entity.loteId,
      farmId: entity.farmId,
      fechaMuerte: entity.fechaMuerte,
      causaMuerte: entity.causaMuerte,
      edadEnSemanas: entity.edadEnSemanas,
      peso: entity.peso,
      observaciones: entity.observaciones,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

