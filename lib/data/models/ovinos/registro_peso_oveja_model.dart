import '../../../domain/entities/ovinos/registro_peso_oveja.dart';

/// Modelo de datos para RegistroPesoOveja
class RegistroPesoOvejaModel extends RegistroPesoOveja {
  const RegistroPesoOvejaModel({
    required super.id,
    required super.ovejaId,
    required super.farmId,
    required super.fechaRegistro,
    required super.peso,
    super.observaciones,
    super.condicionCorporal,
    super.createdAt,
    super.updatedAt,
  });

  /// Crea un modelo desde JSON
  factory RegistroPesoOvejaModel.fromJson(Map<String, dynamic> json) {
    return RegistroPesoOvejaModel(
      id: json['id'] as String,
      ovejaId: json['ovejaId'] as String,
      farmId: json['farmId'] as String,
      fechaRegistro: DateTime.parse(json['fechaRegistro'] as String),
      peso: (json['peso'] as num).toDouble(),
      observaciones: json['observaciones'] as String?,
      condicionCorporal: json['condicionCorporal'] as String?,
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
      'fechaRegistro': fechaRegistro.toIso8601String(),
      'peso': peso,
      'observaciones': observaciones,
      'condicionCorporal': condicionCorporal,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Crea una copia del modelo con campos modificados
  RegistroPesoOvejaModel copyWith({
    String? id,
    String? ovejaId,
    String? farmId,
    DateTime? fechaRegistro,
    double? peso,
    String? observaciones,
    String? condicionCorporal,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RegistroPesoOvejaModel(
      id: id ?? this.id,
      ovejaId: ovejaId ?? this.ovejaId,
      farmId: farmId ?? this.farmId,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      peso: peso ?? this.peso,
      observaciones: observaciones ?? this.observaciones,
      condicionCorporal: condicionCorporal ?? this.condicionCorporal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convierte la entidad a modelo
  factory RegistroPesoOvejaModel.fromEntity(RegistroPesoOveja entity) {
    return RegistroPesoOvejaModel(
      id: entity.id,
      ovejaId: entity.ovejaId,
      farmId: entity.farmId,
      fechaRegistro: entity.fechaRegistro,
      peso: entity.peso,
      observaciones: entity.observaciones,
      condicionCorporal: entity.condicionCorporal,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

