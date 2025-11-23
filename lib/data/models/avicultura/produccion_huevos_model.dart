import '../../../domain/entities/avicultura/produccion_huevos.dart';

/// Modelo de datos para ProduccionHuevos
class ProduccionHuevosModel extends ProduccionHuevos {
  const ProduccionHuevosModel({
    required super.id,
    required super.gallinaId,
    super.loteId,
    required super.farmId,
    required super.fecha,
    required super.cantidadHuevos,
    super.pesoPromedio,
    super.huevosComerciales,
    super.huevosDescarte,
    super.observaciones,
    super.createdAt,
    super.updatedAt,
  });

  /// Crea un modelo desde JSON
  factory ProduccionHuevosModel.fromJson(Map<String, dynamic> json) {
    return ProduccionHuevosModel(
      id: json['id'] as String,
      gallinaId: json['gallinaId'] as String,
      loteId: json['loteId'] as String?,
      farmId: json['farmId'] as String,
      fecha: DateTime.parse(json['fecha'] as String),
      cantidadHuevos: json['cantidadHuevos'] as int,
      pesoPromedio: json['pesoPromedio'] != null
          ? (json['pesoPromedio'] as num).toDouble()
          : null,
      huevosComerciales: json['huevosComerciales'] as int?,
      huevosDescarte: json['huevosDescarte'] as int?,
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
      'fecha': fecha.toIso8601String(),
      'cantidadHuevos': cantidadHuevos,
      'pesoPromedio': pesoPromedio,
      'huevosComerciales': huevosComerciales,
      'huevosDescarte': huevosDescarte,
      'observaciones': observaciones,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Crea una copia del modelo con campos modificados
  ProduccionHuevosModel copyWith({
    String? id,
    String? gallinaId,
    String? loteId,
    String? farmId,
    DateTime? fecha,
    int? cantidadHuevos,
    double? pesoPromedio,
    int? huevosComerciales,
    int? huevosDescarte,
    String? observaciones,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProduccionHuevosModel(
      id: id ?? this.id,
      gallinaId: gallinaId ?? this.gallinaId,
      loteId: loteId ?? this.loteId,
      farmId: farmId ?? this.farmId,
      fecha: fecha ?? this.fecha,
      cantidadHuevos: cantidadHuevos ?? this.cantidadHuevos,
      pesoPromedio: pesoPromedio ?? this.pesoPromedio,
      huevosComerciales: huevosComerciales ?? this.huevosComerciales,
      huevosDescarte: huevosDescarte ?? this.huevosDescarte,
      observaciones: observaciones ?? this.observaciones,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convierte la entidad a modelo
  factory ProduccionHuevosModel.fromEntity(ProduccionHuevos entity) {
    return ProduccionHuevosModel(
      id: entity.id,
      gallinaId: entity.gallinaId,
      loteId: entity.loteId,
      farmId: entity.farmId,
      fecha: entity.fecha,
      cantidadHuevos: entity.cantidadHuevos,
      pesoPromedio: entity.pesoPromedio,
      huevosComerciales: entity.huevosComerciales,
      huevosDescarte: entity.huevosDescarte,
      observaciones: entity.observaciones,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

