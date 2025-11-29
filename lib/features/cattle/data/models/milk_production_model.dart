import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/milk_production_entity.dart';

/// Modelo de datos para MilkProduction
/// Extiende MilkProductionEntity y agrega métodos de serialización para Firestore
class MilkProductionModel extends MilkProductionEntity {
  const MilkProductionModel({
    required String id,
    required String bovineId,
    required String farmId,
    required DateTime recordDate,
    required double litersProduced,
    String? notes,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) : super(
          id: id,
          bovineId: bovineId,
          farmId: farmId,
          recordDate: recordDate,
          litersProduced: litersProduced,
          notes: notes,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  /// Crea un modelo desde JSON de Firestore
  factory MilkProductionModel.fromJson(Map<String, dynamic> json) {
    return MilkProductionModel(
      id: json['id'] as String,
      bovineId: json['bovineId'] as String,
      farmId: json['farmId'] as String,
      recordDate: (json['recordDate'] as Timestamp).toDate(),
      litersProduced: (json['litersProduced'] as num).toDouble(),
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
      'litersProduced': litersProduced,
      if (notes != null) 'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  /// Convierte una entidad a modelo
  factory MilkProductionModel.fromEntity(MilkProductionEntity entity) {
    return MilkProductionModel(
      id: entity.id,
      bovineId: entity.bovineId,
      farmId: entity.farmId,
      recordDate: entity.recordDate,
      litersProduced: entity.litersProduced,
      notes: entity.notes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Crea una copia del modelo
  MilkProductionModel copyWith({
    String? id,
    String? bovineId,
    String? farmId,
    DateTime? recordDate,
    double? litersProduced,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MilkProductionModel(
      id: id ?? this.id,
      bovineId: bovineId ?? this.bovineId,
      farmId: farmId ?? this.farmId,
      recordDate: recordDate ?? this.recordDate,
      litersProduced: litersProduced ?? this.litersProduced,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

