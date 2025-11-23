import '../../../domain/entities/porcinos/alimentacion_cerdo.dart';

/// Modelo de datos para AlimentacionCerdo
class AlimentacionCerdoModel extends AlimentacionCerdo {
  const AlimentacionCerdoModel({
    required super.id,
    super.cerdoId,
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
  factory AlimentacionCerdoModel.fromJson(Map<String, dynamic> json) {
    return AlimentacionCerdoModel(
      id: json['id'] as String,
      cerdoId: json['cerdoId'] as String?,
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
      'cerdoId': cerdoId,
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
  AlimentacionCerdoModel copyWith({
    String? id,
    String? cerdoId,
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
    return AlimentacionCerdoModel(
      id: id ?? this.id,
      cerdoId: cerdoId ?? this.cerdoId,
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
  factory AlimentacionCerdoModel.fromEntity(AlimentacionCerdo entity) {
    return AlimentacionCerdoModel(
      id: entity.id,
      cerdoId: entity.cerdoId,
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

