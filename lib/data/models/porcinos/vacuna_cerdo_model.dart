import '../../../domain/entities/porcinos/vacuna_cerdo.dart';

/// Modelo de datos para VacunaCerdo
class VacunaCerdoModel extends VacunaCerdo {
  const VacunaCerdoModel({
    required super.id,
    required super.cerdoId,
    required super.farmId,
    required super.date,
    required super.vaccineName,
    super.batchNumber,
    super.notes,
    super.nextDoseDate,
    super.administeredBy,
    super.observations,
    super.createdAt,
    super.updatedAt,
  });

  /// Crea un modelo desde JSON
  factory VacunaCerdoModel.fromJson(Map<String, dynamic> json) {
    return VacunaCerdoModel(
      id: json['id'] as String,
      cerdoId: json['cerdoId'] as String,
      farmId: json['farmId'] as String,
      date: DateTime.parse(json['date'] as String),
      vaccineName: json['vaccineName'] as String,
      batchNumber: json['batchNumber'] as String?,
      notes: json['notes'] as String?,
      nextDoseDate: json['nextDoseDate'] != null
          ? DateTime.parse(json['nextDoseDate'] as String)
          : null,
      administeredBy: json['administeredBy'] as String?,
      observations: json['observations'] as String?,
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
      'date': date.toIso8601String(),
      'vaccineName': vaccineName,
      'batchNumber': batchNumber,
      'notes': notes,
      'nextDoseDate': nextDoseDate?.toIso8601String(),
      'administeredBy': administeredBy,
      'observations': observations,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Crea una copia del modelo con campos modificados
  VacunaCerdoModel copyWith({
    String? id,
    String? cerdoId,
    String? farmId,
    DateTime? date,
    String? vaccineName,
    String? batchNumber,
    String? notes,
    DateTime? nextDoseDate,
    String? administeredBy,
    String? observations,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VacunaCerdoModel(
      id: id ?? this.id,
      cerdoId: cerdoId ?? this.cerdoId,
      farmId: farmId ?? this.farmId,
      date: date ?? this.date,
      vaccineName: vaccineName ?? this.vaccineName,
      batchNumber: batchNumber ?? this.batchNumber,
      notes: notes ?? this.notes,
      nextDoseDate: nextDoseDate ?? this.nextDoseDate,
      administeredBy: administeredBy ?? this.administeredBy,
      observations: observations ?? this.observations,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convierte la entidad a modelo
  factory VacunaCerdoModel.fromEntity(VacunaCerdo entity) {
    return VacunaCerdoModel(
      id: entity.id,
      cerdoId: entity.cerdoId,
      farmId: entity.farmId,
      date: entity.date,
      vaccineName: entity.vaccineName,
      batchNumber: entity.batchNumber,
      notes: entity.notes,
      nextDoseDate: entity.nextDoseDate,
      administeredBy: entity.administeredBy,
      observations: entity.observations,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

