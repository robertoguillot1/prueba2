import '../../../domain/entities/avicultura/gallina.dart';

/// Modelo de datos para Gallina
class GallinaModel extends Gallina {
  const GallinaModel({
    required String id,
    required String farmId,
    String? identification,
    String? name,
    required DateTime fechaNacimiento,
    String? raza,
    required GallinaGender gender,
    required EstadoGallina estado,
    DateTime? fechaIngresoLote,
    String? loteId,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super(
          id: id,
          farmId: farmId,
          identification: identification,
          name: name,
          fechaNacimiento: fechaNacimiento,
          raza: raza,
          gender: gender,
          estado: estado,
          fechaIngresoLote: fechaIngresoLote,
          loteId: loteId,
          notes: notes,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  /// Crea un modelo desde JSON
  factory GallinaModel.fromJson(Map<String, dynamic> json) {
    return GallinaModel(
      id: json['id'] as String,
      farmId: json['farmId'] as String,
      identification: json['identification'] as String?,
      name: json['name'] as String?,
      fechaNacimiento: DateTime.parse(json['fechaNacimiento'] as String),
      raza: json['raza'] as String?,
      gender: GallinaGender.values.firstWhere(
        (e) => e.name == json['gender'],
        orElse: () => GallinaGender.female,
      ),
      estado: EstadoGallina.values.firstWhere(
        (e) => e.name == json['estado'],
        orElse: () => EstadoGallina.activa,
      ),
      fechaIngresoLote: json['fechaIngresoLote'] != null
          ? DateTime.parse(json['fechaIngresoLote'] as String)
          : null,
      loteId: json['loteId'] as String?,
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
      'farmId': farmId,
      'identification': identification,
      'name': name,
      'fechaNacimiento': fechaNacimiento.toIso8601String(),
      'raza': raza,
      'gender': gender.name,
      'estado': estado.name,
      'fechaIngresoLote': fechaIngresoLote?.toIso8601String(),
      'loteId': loteId,
      'notes': notes,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Crea una copia del modelo con campos modificados
  GallinaModel copyWith({
    String? id,
    String? farmId,
    String? identification,
    String? name,
    DateTime? fechaNacimiento,
    String? raza,
    GallinaGender? gender,
    EstadoGallina? estado,
    DateTime? fechaIngresoLote,
    String? loteId,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GallinaModel(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      identification: identification ?? this.identification,
      name: name ?? this.name,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      raza: raza ?? this.raza,
      gender: gender ?? this.gender,
      estado: estado ?? this.estado,
      fechaIngresoLote: fechaIngresoLote ?? this.fechaIngresoLote,
      loteId: loteId ?? this.loteId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convierte la entidad a modelo
  factory GallinaModel.fromEntity(Gallina entity) {
    return GallinaModel(
      id: entity.id,
      farmId: entity.farmId,
      identification: entity.identification,
      name: entity.name,
      fechaNacimiento: entity.fechaNacimiento,
      raza: entity.raza,
      gender: entity.gender,
      estado: entity.estado,
      fechaIngresoLote: entity.fechaIngresoLote,
      loteId: entity.loteId,
      notes: entity.notes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

