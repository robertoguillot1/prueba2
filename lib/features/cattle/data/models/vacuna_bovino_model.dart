import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/vacuna_bovino_entity.dart';

/// Modelo de datos para VacunaBovino
/// Extiende VacunaBovinoEntity y agrega métodos de serialización para Firestore
class VacunaBovinoModel extends VacunaBovinoEntity {
  const VacunaBovinoModel({
    required String id,
    required String bovinoId,
    required String farmId,
    required DateTime fechaAplicacion,
    required String nombreVacuna,
    String? lote,
    DateTime? proximaDosis,
    String? notas,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) : super(
          id: id,
          bovinoId: bovinoId,
          farmId: farmId,
          fechaAplicacion: fechaAplicacion,
          nombreVacuna: nombreVacuna,
          lote: lote,
          proximaDosis: proximaDosis,
          notas: notas,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  /// Crea un modelo desde JSON de Firestore
  factory VacunaBovinoModel.fromJson(Map<String, dynamic> json) {
    return VacunaBovinoModel(
      id: json['id'] as String,
      bovinoId: json['bovinoId'] as String,
      farmId: json['farmId'] as String,
      fechaAplicacion: (json['fechaAplicacion'] as Timestamp).toDate(),
      nombreVacuna: json['nombreVacuna'] as String,
      lote: json['lote'] as String?,
      proximaDosis: json['proximaDosis'] != null
          ? (json['proximaDosis'] as Timestamp).toDate()
          : null,
      notas: json['notas'] as String?,
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
      'bovinoId': bovinoId,
      'farmId': farmId,
      'fechaAplicacion': Timestamp.fromDate(fechaAplicacion),
      'nombreVacuna': nombreVacuna,
      if (lote != null) 'lote': lote,
      if (proximaDosis != null)
        'proximaDosis': Timestamp.fromDate(proximaDosis!),
      if (notas != null) 'notas': notas,
      'createdAt': Timestamp.fromDate(createdAt),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  /// Convierte una entidad a modelo
  factory VacunaBovinoModel.fromEntity(VacunaBovinoEntity entity) {
    return VacunaBovinoModel(
      id: entity.id,
      bovinoId: entity.bovinoId,
      farmId: entity.farmId,
      fechaAplicacion: entity.fechaAplicacion,
      nombreVacuna: entity.nombreVacuna,
      lote: entity.lote,
      proximaDosis: entity.proximaDosis,
      notas: entity.notas,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Crea una copia del modelo
  VacunaBovinoModel copyWith({
    String? id,
    String? bovinoId,
    String? farmId,
    DateTime? fechaAplicacion,
    String? nombreVacuna,
    String? lote,
    DateTime? proximaDosis,
    String? notas,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VacunaBovinoModel(
      id: id ?? this.id,
      bovinoId: bovinoId ?? this.bovinoId,
      farmId: farmId ?? this.farmId,
      fechaAplicacion: fechaAplicacion ?? this.fechaAplicacion,
      nombreVacuna: nombreVacuna ?? this.nombreVacuna,
      lote: lote ?? this.lote,
      proximaDosis: proximaDosis ?? this.proximaDosis,
      notas: notas ?? this.notas,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

