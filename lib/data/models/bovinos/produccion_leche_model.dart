import '../../../domain/entities/bovinos/produccion_leche.dart';

/// Modelo de datos para ProduccionLeche
class ProduccionLecheModel extends ProduccionLeche {
  const ProduccionLecheModel({
    required String id,
    required String bovinoId,
    required String farmId,
    required DateTime recordDate,
    required double litersProduced,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super(
          id: id,
          bovinoId: bovinoId,
          farmId: farmId,
          recordDate: recordDate,
          litersProduced: litersProduced,
          notes: notes,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  /// Crea un modelo desde JSON
  factory ProduccionLecheModel.fromJson(Map<String, dynamic> json) {
    return ProduccionLecheModel(
      id: json['id'] as String,
      bovinoId: json['bovinoId'] as String,
      farmId: json['farmId'] as String,
      recordDate: DateTime.parse(json['recordDate'] as String),
      litersProduced: (json['litersProduced'] as num).toDouble(),
      notes: json['notes'] as String?,
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
      'recordDate': recordDate.toIso8601String(),
      'litersProduced': litersProduced,
      'notes': notes,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Crea una copia del modelo con campos modificados
  ProduccionLecheModel copyWith({
    String? id,
    String? bovinoId,
    String? farmId,
    DateTime? recordDate,
    double? litersProduced,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProduccionLecheModel(
      id: id ?? this.id,
      bovinoId: bovinoId ?? this.bovinoId,
      farmId: farmId ?? this.farmId,
      recordDate: recordDate ?? this.recordDate,
      litersProduced: litersProduced ?? this.litersProduced,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convierte la entidad a modelo
  factory ProduccionLecheModel.fromEntity(ProduccionLeche entity) {
    return ProduccionLecheModel(
      id: entity.id,
      bovinoId: entity.bovinoId,
      farmId: entity.farmId,
      recordDate: entity.recordDate,
      litersProduced: entity.litersProduced,
      notes: entity.notes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

