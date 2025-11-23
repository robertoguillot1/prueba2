import '../../../domain/entities/trabajadores/asistencia.dart';

/// Modelo de datos para Asistencia
class AsistenciaModel extends Asistencia {
  const AsistenciaModel({
    required super.id,
    required super.trabajadorId,
    required super.farmId,
    required super.fecha,
    super.horaEntrada,
    super.horaSalida,
    super.horasTrabajadas,
    required super.presente,
    super.motivoAusencia,
    super.observaciones,
    super.createdAt,
    super.updatedAt,
  });

  /// Crea un modelo desde JSON
  factory AsistenciaModel.fromJson(Map<String, dynamic> json) {
    return AsistenciaModel(
      id: json['id'] as String,
      trabajadorId: json['trabajadorId'] as String,
      farmId: json['farmId'] as String,
      fecha: DateTime.parse(json['fecha'] as String),
      horaEntrada: json['horaEntrada'] != null
          ? DateTime.parse(json['horaEntrada'] as String)
          : null,
      horaSalida: json['horaSalida'] != null
          ? DateTime.parse(json['horaSalida'] as String)
          : null,
      horasTrabajadas: json['horasTrabajadas'] as int?,
      presente: json['presente'] as bool,
      motivoAusencia: json['motivoAusencia'] as String?,
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
      'trabajadorId': trabajadorId,
      'farmId': farmId,
      'fecha': fecha.toIso8601String(),
      'horaEntrada': horaEntrada?.toIso8601String(),
      'horaSalida': horaSalida?.toIso8601String(),
      'horasTrabajadas': horasTrabajadas,
      'presente': presente,
      'motivoAusencia': motivoAusencia,
      'observaciones': observaciones,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Crea una copia del modelo con campos modificados
  AsistenciaModel copyWith({
    String? id,
    String? trabajadorId,
    String? farmId,
    DateTime? fecha,
    DateTime? horaEntrada,
    DateTime? horaSalida,
    int? horasTrabajadas,
    bool? presente,
    String? motivoAusencia,
    String? observaciones,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AsistenciaModel(
      id: id ?? this.id,
      trabajadorId: trabajadorId ?? this.trabajadorId,
      farmId: farmId ?? this.farmId,
      fecha: fecha ?? this.fecha,
      horaEntrada: horaEntrada ?? this.horaEntrada,
      horaSalida: horaSalida ?? this.horaSalida,
      horasTrabajadas: horasTrabajadas ?? this.horasTrabajadas,
      presente: presente ?? this.presente,
      motivoAusencia: motivoAusencia ?? this.motivoAusencia,
      observaciones: observaciones ?? this.observaciones,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convierte la entidad a modelo
  factory AsistenciaModel.fromEntity(Asistencia entity) {
    return AsistenciaModel(
      id: entity.id,
      trabajadorId: entity.trabajadorId,
      farmId: entity.farmId,
      fecha: entity.fecha,
      horaEntrada: entity.horaEntrada,
      horaSalida: entity.horaSalida,
      horasTrabajadas: entity.horasTrabajadas,
      presente: entity.presente,
      motivoAusencia: entity.motivoAusencia,
      observaciones: entity.observaciones,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

