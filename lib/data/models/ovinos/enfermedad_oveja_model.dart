import '../../../domain/entities/ovinos/enfermedad_oveja.dart';

/// Modelo de datos para EnfermedadOveja
class EnfermedadOvejaModel extends EnfermedadOveja {
  const EnfermedadOvejaModel({
    required super.id,
    required super.ovejaId,
    required super.farmId,
    required super.fechaDiagnostico,
    required super.nombreEnfermedad,
    super.sintomas,
    super.tratamiento,
    super.fechaRecuperacion,
    super.curada = false,
    super.observaciones,
    super.createdAt,
    super.updatedAt,
  });

  /// Crea un modelo desde JSON
  factory EnfermedadOvejaModel.fromJson(Map<String, dynamic> json) {
    return EnfermedadOvejaModel(
      id: json['id'] as String,
      ovejaId: json['ovejaId'] as String,
      farmId: json['farmId'] as String,
      fechaDiagnostico: DateTime.parse(json['fechaDiagnostico'] as String),
      nombreEnfermedad: json['nombreEnfermedad'] as String,
      sintomas: json['sintomas'] as String?,
      tratamiento: json['tratamiento'] as String?,
      fechaRecuperacion: json['fechaRecuperacion'] != null
          ? DateTime.parse(json['fechaRecuperacion'] as String)
          : null,
      curada: json['curada'] as bool? ?? false,
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
      'ovejaId': ovejaId,
      'farmId': farmId,
      'fechaDiagnostico': fechaDiagnostico.toIso8601String(),
      'nombreEnfermedad': nombreEnfermedad,
      'sintomas': sintomas,
      'tratamiento': tratamiento,
      'fechaRecuperacion': fechaRecuperacion?.toIso8601String(),
      'curada': curada,
      'observaciones': observaciones,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Crea una copia del modelo con campos modificados
  EnfermedadOvejaModel copyWith({
    String? id,
    String? ovejaId,
    String? farmId,
    DateTime? fechaDiagnostico,
    String? nombreEnfermedad,
    String? sintomas,
    String? tratamiento,
    DateTime? fechaRecuperacion,
    bool? curada,
    String? observaciones,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EnfermedadOvejaModel(
      id: id ?? this.id,
      ovejaId: ovejaId ?? this.ovejaId,
      farmId: farmId ?? this.farmId,
      fechaDiagnostico: fechaDiagnostico ?? this.fechaDiagnostico,
      nombreEnfermedad: nombreEnfermedad ?? this.nombreEnfermedad,
      sintomas: sintomas ?? this.sintomas,
      tratamiento: tratamiento ?? this.tratamiento,
      fechaRecuperacion: fechaRecuperacion ?? this.fechaRecuperacion,
      curada: curada ?? this.curada,
      observaciones: observaciones ?? this.observaciones,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convierte la entidad a modelo
  factory EnfermedadOvejaModel.fromEntity(EnfermedadOveja entity) {
    return EnfermedadOvejaModel(
      id: entity.id,
      ovejaId: entity.ovejaId,
      farmId: entity.farmId,
      fechaDiagnostico: entity.fechaDiagnostico,
      nombreEnfermedad: entity.nombreEnfermedad,
      sintomas: entity.sintomas,
      tratamiento: entity.tratamiento,
      fechaRecuperacion: entity.fechaRecuperacion,
      curada: entity.curada,
      observaciones: entity.observaciones,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

