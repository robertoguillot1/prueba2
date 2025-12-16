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
    int previousCalvings = 0,
    HealthStatus healthStatus = HealthStatus.healthy,
    ProductionStage productionStage = ProductionStage.raising,
    BreedingStatus? breedingStatus,
    DateTime? lastHeatDate,
    DateTime? inseminationDate,
    DateTime? expectedCalvingDate,
    String? notes,
    String? photoUrl,
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
          previousCalvings: previousCalvings,
          healthStatus: healthStatus,
          productionStage: productionStage,
          breedingStatus: breedingStatus,
          lastHeatDate: lastHeatDate,
          inseminationDate: inseminationDate,
          expectedCalvingDate: expectedCalvingDate,
          notes: notes,
          photoUrl: photoUrl,
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
      previousCalvings: (json['previousCalvings'] as num?)?.toInt() ?? 0,
      healthStatus: json['healthStatus'] != null
          ? _parseHealthStatus(json['healthStatus'] as String)
          : HealthStatus.healthy,
      productionStage: json['productionStage'] != null
          ? _parseProductionStage(json['productionStage'] as String)
          : ProductionStage.raising,
      breedingStatus: json['breedingStatus'] != null
          ? _parseBreedingStatus(json['breedingStatus'] as String)
          : null,
      lastHeatDate: json['lastHeatDate'] != null
          ? (json['lastHeatDate'] as Timestamp).toDate()
          : null,
      inseminationDate: json['inseminationDate'] != null
          ? (json['inseminationDate'] as Timestamp).toDate()
          : null,
      expectedCalvingDate: json['expectedCalvingDate'] != null
          ? (json['expectedCalvingDate'] as Timestamp).toDate()
          : null,
      notes: json['notes'] as String?,
      photoUrl: json['photoUrl'] as String?,
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
      'previousCalvings': previousCalvings,
      'healthStatus': _healthStatusToString(healthStatus),
      'productionStage': _productionStageToString(productionStage),
      if (breedingStatus != null) 'breedingStatus': _breedingStatusToString(breedingStatus!),
      if (lastHeatDate != null) 'lastHeatDate': Timestamp.fromDate(lastHeatDate!),
      if (inseminationDate != null) 'inseminationDate': Timestamp.fromDate(inseminationDate!),
      if (expectedCalvingDate != null) 'expectedCalvingDate': Timestamp.fromDate(expectedCalvingDate!),
      if (notes != null) 'notes': notes,
      if (photoUrl != null) 'photoUrl': photoUrl,
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
    int? previousCalvings,
    HealthStatus? healthStatus,
    ProductionStage? productionStage,
    BreedingStatus? breedingStatus,
    DateTime? lastHeatDate,
    DateTime? inseminationDate,
    DateTime? expectedCalvingDate,
    String? notes,
    String? photoUrl,
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
      previousCalvings: previousCalvings ?? this.previousCalvings,
      healthStatus: healthStatus ?? this.healthStatus,
      productionStage: productionStage ?? this.productionStage,
      breedingStatus: breedingStatus ?? this.breedingStatus,
      lastHeatDate: lastHeatDate ?? this.lastHeatDate,
      inseminationDate: inseminationDate ?? this.inseminationDate,
      expectedCalvingDate: expectedCalvingDate ?? this.expectedCalvingDate,
      notes: notes ?? this.notes,
      photoUrl: photoUrl ?? this.photoUrl,
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
      previousCalvings: entity.previousCalvings,
      healthStatus: entity.healthStatus,
      productionStage: entity.productionStage,
      breedingStatus: entity.breedingStatus,
      lastHeatDate: entity.lastHeatDate,
      inseminationDate: entity.inseminationDate,
      expectedCalvingDate: entity.expectedCalvingDate,
      notes: entity.notes,
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

  static HealthStatus _parseHealthStatus(String value) {
    switch (value.toLowerCase()) {
      case 'healthy':
      case 'sano':
        return HealthStatus.healthy;
      case 'sick':
      case 'enfermo':
        return HealthStatus.sick;
      case 'undertreatment':
      case 'tratamiento':
        return HealthStatus.underTreatment;
      case 'recovering':
      case 'recuperandose':
        return HealthStatus.recovering;
      default:
        return HealthStatus.healthy;
    }
  }

  static String _healthStatusToString(HealthStatus status) {
    switch (status) {
      case HealthStatus.healthy:
        return 'healthy';
      case HealthStatus.sick:
        return 'sick';
      case HealthStatus.underTreatment:
        return 'underTreatment';
      case HealthStatus.recovering:
        return 'recovering';
    }
  }

  static ProductionStage _parseProductionStage(String value) {
    switch (value.toLowerCase()) {
      case 'raising':
      case 'levante':
        return ProductionStage.raising;
      case 'productive':
      case 'productiva':
        return ProductionStage.productive;
      case 'dry':
      case 'seca':
        return ProductionStage.dry;
      default:
        return ProductionStage.raising;
    }
  }

  static String _productionStageToString(ProductionStage stage) {
    switch (stage) {
      case ProductionStage.raising:
        return 'raising';
      case ProductionStage.productive:
        return 'productive';
      case ProductionStage.dry:
        return 'dry';
    }
  }

  static BreedingStatus _parseBreedingStatus(String value) {
    switch (value.toLowerCase()) {
      case 'notspecified':
      case 'noespecificado':
        return BreedingStatus.notSpecified;
      case 'pregnant':
      case 'gestante':
        return BreedingStatus.pregnant;
      case 'inseminated':
      case 'inseminada':
        return BreedingStatus.inseminated;
      case 'empty':
      case 'vacia':
        return BreedingStatus.empty;
      case 'served':
      case 'servida':
        return BreedingStatus.served;
      default:
        return BreedingStatus.notSpecified;
    }
  }

  static String _breedingStatusToString(BreedingStatus status) {
    switch (status) {
      case BreedingStatus.notSpecified:
        return 'notSpecified';
      case BreedingStatus.pregnant:
        return 'pregnant';
      case BreedingStatus.inseminated:
        return 'inseminated';
      case BreedingStatus.empty:
        return 'empty';
      case BreedingStatus.served:
        return 'served';
    }
  }
}

