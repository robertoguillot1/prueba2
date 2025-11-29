import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/weight_record_entity.dart';

/// Modelo de datos para WeightRecord
/// Extiende WeightRecordEntity y agrega métodos de serialización para Firestore
class WeightRecordModel extends WeightRecordEntity {
  const WeightRecordModel({
    required String id,
    required String bovineId,
    required String farmId,
    required DateTime recordDate,
    required double weight,
    String? notes,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) : super(
          id: id,
          bovineId: bovineId,
          farmId: farmId,
          recordDate: recordDate,
          weight: weight,
          notes: notes,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  /// Crea un modelo desde JSON de Firestore
  factory WeightRecordModel.fromJson(Map<String, dynamic> json) {
    return WeightRecordModel(
      id: json['id'] as String,
      bovineId: json['bovineId'] as String,
      farmId: json['farmId'] as String,
      recordDate: (json['recordDate'] as Timestamp).toDate(),
      weight: (json['weight'] as num).toDouble(),
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Convierte el modelo a JSON para Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bovineId': bovineId,
      'farmId': farmId,
      'recordDate': Timestamp.fromDate(recordDate),
      'weight': weight,
      if (notes != null) 'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  /// Convierte una entidad a modelo
  factory WeightRecordModel.fromEntity(WeightRecordEntity entity) {
    return WeightRecordModel(
      id: entity.id,
      bovineId: entity.bovineId,
      farmId: entity.farmId,
      recordDate: entity.recordDate,
      weight: entity.weight,
      notes: entity.notes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Crea una copia del modelo
  WeightRecordModel copyWith({
    String? id,
    String? bovineId,
    String? farmId,
    DateTime? recordDate,
    double? weight,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WeightRecordModel(
      id: id ?? this.id,
      bovineId: bovineId ?? this.bovineId,
      farmId: farmId ?? this.farmId,
      recordDate: recordDate ?? this.recordDate,
      weight: weight ?? this.weight,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

