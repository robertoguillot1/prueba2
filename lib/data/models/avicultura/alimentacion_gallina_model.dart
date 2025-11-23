import '../../../domain/entities/avicultura/alimentacion_gallina.dart';

/// Modelo de datos para AlimentacionGallina
class AlimentacionGallinaModel extends AlimentacionGallina {
  const AlimentacionGallinaModel({
    required super.id,
    super.gallinaId,
    super.loteId,
    required super.farmId,
    required super.fecha,
    required super.cantidadAlimento,
    required super.tipoAlimento,
    super.costo,
    super.proveedor,
    super.observaciones,
    super.createdAt,
    super.updatedAt,
  });

  /// Crea un modelo desde JSON
  factory AlimentacionGallinaModel.fromJson(Map<String, dynamic> json) {
    return AlimentacionGallinaModel(
      id: json['id'] as String,
      gallinaId: json['gallinaId'] as String?,
      loteId: json['loteId'] as String?,
      farmId: json['farmId'] as String,
      fecha: DateTime.parse(json['fecha'] as String),
      cantidadAlimento: (json['cantidadAlimento'] as num).toDouble(),
      tipoAlimento: json['tipoAlimento'] as String,
      costo: json['costo'] != null
          ? (json['costo'] as num).toDouble()
          : null,
      proveedor: json['proveedor'] as String?,
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
      'cantidadAlimento': cantidadAlimento,
      'tipoAlimento': tipoAlimento,
      'costo': costo,
      'proveedor': proveedor,
      'observaciones': observaciones,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Crea una copia del modelo con campos modificados
  AlimentacionGallinaModel copyWith({
    String? id,
    String? gallinaId,
    String? loteId,
    String? farmId,
    DateTime? fecha,
    double? cantidadAlimento,
    String? tipoAlimento,
    double? costo,
    String? proveedor,
    String? observaciones,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AlimentacionGallinaModel(
      id: id ?? this.id,
      gallinaId: gallinaId ?? this.gallinaId,
      loteId: loteId ?? this.loteId,
      farmId: farmId ?? this.farmId,
      fecha: fecha ?? this.fecha,
      cantidadAlimento: cantidadAlimento ?? this.cantidadAlimento,
      tipoAlimento: tipoAlimento ?? this.tipoAlimento,
      costo: costo ?? this.costo,
      proveedor: proveedor ?? this.proveedor,
      observaciones: observaciones ?? this.observaciones,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convierte la entidad a modelo
  factory AlimentacionGallinaModel.fromEntity(AlimentacionGallina entity) {
    return AlimentacionGallinaModel(
      id: entity.id,
      gallinaId: entity.gallinaId,
      loteId: entity.loteId,
      farmId: entity.farmId,
      fecha: entity.fecha,
      cantidadAlimento: entity.cantidadAlimento,
      tipoAlimento: entity.tipoAlimento,
      costo: entity.costo,
      proveedor: entity.proveedor,
      observaciones: entity.observaciones,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

