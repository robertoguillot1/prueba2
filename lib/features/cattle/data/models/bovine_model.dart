import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/bovine_entity.dart';

/// Modelo de datos para Bovine
/// Extiende BovineEntity y agrega métodos de serialización para Firestore
class BovineModel extends BovineEntity {
  const BovineModel({
    required String id,
    required String farmId,
    required String identifier,
    String? name,
    required String breed,
    required BovineGender gender,
    required DateTime birthDate,
    required double weight,
    required BovinePurpose purpose,
    required BovineStatus status,
    required DateTime createdAt,
    DateTime? updatedAt,
    String? motherId,
    String? fatherId,
  }) : super(
          id: id,
          farmId: farmId,
          identifier: identifier,
          name: name,
          breed: breed,
          gender: gender,
          birthDate: birthDate,
          weight: weight,
          purpose: purpose,
          status: status,
          createdAt: createdAt,
          updatedAt: updatedAt,
          motherId: motherId,
          fatherId: fatherId,
        );

  /// Crea un modelo desde JSON de Firestore
  factory BovineModel.fromJson(Map<String, dynamic> json) {
    return BovineModel(
      id: json['id'] as String,
      farmId: json['farmId'] as String,
      identifier: json['identifier'] as String,
      name: json['name'] as String?,
      breed: json['breed'] as String,
      gender: _parseGender(json['gender'] as String),
      birthDate: json['birthDate'] != null
          ? (json['birthDate'] as Timestamp).toDate()
          : DateTime.now(),
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      purpose: _parsePurpose(json['purpose'] as String),
      status: _parseStatus(json['status'] as String),
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
      motherId: json['motherId'] as String?,
      fatherId: json['fatherId'] as String?,
    );
  }

  /// Convierte el modelo a JSON para Firestore
  Map<String, dynamic> toJson() {
    return {
      'farmId': farmId,
      'identifier': identifier,
      if (name != null) 'name': name,
      'breed': breed,
      'gender': _genderToString(gender),
      'birthDate': Timestamp.fromDate(birthDate),
      'weight': weight,
      'purpose': _purposeToString(purpose),
      'status': _statusToString(status),
      'createdAt': Timestamp.fromDate(createdAt),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
      if (motherId != null) 'motherId': motherId,
      if (fatherId != null) 'fatherId': fatherId,
    };
  }

  /// Crea una copia del modelo
  BovineModel copyWith({
    String? id,
    String? farmId,
    String? identifier,
    String? name,
    String? breed,
    BovineGender? gender,
    DateTime? birthDate,
    double? weight,
    BovinePurpose? purpose,
    BovineStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? motherId,
    String? fatherId,
  }) {
    return BovineModel(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      identifier: identifier ?? this.identifier,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      weight: weight ?? this.weight,
      purpose: purpose ?? this.purpose,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      motherId: motherId ?? this.motherId,
      fatherId: fatherId ?? this.fatherId,
    );
  }

  /// Convierte una entidad a modelo
  factory BovineModel.fromEntity(BovineEntity entity) {
    return BovineModel(
      id: entity.id,
      farmId: entity.farmId,
      identifier: entity.identifier,
      name: entity.name,
      breed: entity.breed,
      gender: entity.gender,
      birthDate: entity.birthDate,
      weight: entity.weight,
      purpose: entity.purpose,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      motherId: entity.motherId,
      fatherId: entity.fatherId,
    );
  }

  // Métodos auxiliares para conversión de enums

  static BovineGender _parseGender(String value) {
    switch (value.toLowerCase()) {
      case 'male':
      case 'macho':
        return BovineGender.male;
      case 'female':
      case 'hembra':
        return BovineGender.female;
      default:
        return BovineGender.male;
    }
  }

  static String _genderToString(BovineGender gender) {
    switch (gender) {
      case BovineGender.male:
        return 'male';
      case BovineGender.female:
        return 'female';
    }
  }

  static BovinePurpose _parsePurpose(String value) {
    switch (value.toLowerCase()) {
      case 'meat':
      case 'carne':
        return BovinePurpose.meat;
      case 'milk':
      case 'leche':
        return BovinePurpose.milk;
      case 'dual':
      case 'doble':
        return BovinePurpose.dual;
      default:
        return BovinePurpose.dual;
    }
  }

  static String _purposeToString(BovinePurpose purpose) {
    switch (purpose) {
      case BovinePurpose.meat:
        return 'meat';
      case BovinePurpose.milk:
        return 'milk';
      case BovinePurpose.dual:
        return 'dual';
    }
  }

  static BovineStatus _parseStatus(String value) {
    switch (value.toLowerCase()) {
      case 'active':
      case 'activo':
        return BovineStatus.active;
      case 'sold':
      case 'vendido':
        return BovineStatus.sold;
      case 'dead':
      case 'muerto':
        return BovineStatus.dead;
      default:
        return BovineStatus.active;
    }
  }

  static String _statusToString(BovineStatus status) {
    switch (status) {
      case BovineStatus.active:
        return 'active';
      case BovineStatus.sold:
        return 'sold';
      case BovineStatus.dead:
        return 'dead';
    }
  }
}

