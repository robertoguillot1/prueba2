import '../../../domain/entities/bovinos/vacunas_bovino.dart';

/// Modelo de datos para VacunasBovino
class VacunasBovinoModel extends VacunasBovino {
  const VacunasBovinoModel({
    required super.id,
    required super.bovinoId,
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
  factory VacunasBovinoModel.fromJson(Map<String, dynamic> json) {
    return VacunasBovinoModel(
      id: json['id'] as String,
      bovinoId: json['bovinoId'] as String,
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
      'bovinoId': bovinoId,
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
  VacunasBovinoModel copyWith({
    String? id,
    String? bovinoId,
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
    return VacunasBovinoModel(
      id: id ?? this.id,
      bovinoId: bovinoId ?? this.bovinoId,
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
  factory VacunasBovinoModel.fromEntity(VacunasBovino entity) {
    return VacunasBovinoModel(
      id: entity.id,
      bovinoId: entity.bovinoId,
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

