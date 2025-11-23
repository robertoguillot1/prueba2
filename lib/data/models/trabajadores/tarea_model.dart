import '../../../domain/entities/trabajadores/tarea.dart';

/// Modelo de datos para Tarea
class TareaModel extends Tarea {
  const TareaModel({
    required super.id,
    required super.trabajadorId,
    required super.farmId,
    required super.titulo,
    required super.descripcion,
    required super.fechaAsignacion,
    super.fechaCompletada,
    required super.estado,
    super.observaciones,
    super.createdAt,
    super.updatedAt,
  });

  /// Crea un modelo desde JSON
  factory TareaModel.fromJson(Map<String, dynamic> json) {
    return TareaModel(
      id: json['id'] as String,
      trabajadorId: json['trabajadorId'] as String,
      farmId: json['farmId'] as String,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String,
      fechaAsignacion: DateTime.parse(json['fechaAsignacion'] as String),
      fechaCompletada: json['fechaCompletada'] != null
          ? DateTime.parse(json['fechaCompletada'] as String)
          : null,
      estado: TareaEstado.values.firstWhere(
        (e) => e.name == json['estado'],
        orElse: () => TareaEstado.pendiente,
      ),
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
      'titulo': titulo,
      'descripcion': descripcion,
      'fechaAsignacion': fechaAsignacion.toIso8601String(),
      'fechaCompletada': fechaCompletada?.toIso8601String(),
      'estado': estado.name,
      'observaciones': observaciones,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Crea una copia del modelo con campos modificados
  TareaModel copyWith({
    String? id,
    String? trabajadorId,
    String? farmId,
    String? titulo,
    String? descripcion,
    DateTime? fechaAsignacion,
    DateTime? fechaCompletada,
    TareaEstado? estado,
    String? observaciones,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TareaModel(
      id: id ?? this.id,
      trabajadorId: trabajadorId ?? this.trabajadorId,
      farmId: farmId ?? this.farmId,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      fechaAsignacion: fechaAsignacion ?? this.fechaAsignacion,
      fechaCompletada: fechaCompletada ?? this.fechaCompletada,
      estado: estado ?? this.estado,
      observaciones: observaciones ?? this.observaciones,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convierte la entidad a modelo
  factory TareaModel.fromEntity(Tarea entity) {
    return TareaModel(
      id: entity.id,
      trabajadorId: entity.trabajadorId,
      farmId: entity.farmId,
      titulo: entity.titulo,
      descripcion: entity.descripcion,
      fechaAsignacion: entity.fechaAsignacion,
      fechaCompletada: entity.fechaCompletada,
      estado: entity.estado,
      observaciones: entity.observaciones,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

