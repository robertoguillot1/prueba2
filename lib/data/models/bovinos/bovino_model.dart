import '../../../domain/entities/bovinos/bovino.dart';

/// Modelo de datos para Bovino
class BovinoModel extends Bovino {
  const BovinoModel({
    required String id,
    required String farmId,
    String? identification,
    String? name,
    required BovinoCategory category,
    required BovinoGender gender,
    required double currentWeight,
    required DateTime birthDate,
    required ProductionStage productionStage,
    required HealthStatus healthStatus,
    BreedingStatus? breedingStatus,
    DateTime? lastHeatDate,
    DateTime? inseminationDate,
    DateTime? expectedCalvingDate,
    int? previousCalvings,
    String? notes,
    String? photoUrl,
    String? idPadre,
    String? nombrePadre,
    String? idMadre,
    String? nombreMadre,
    String? raza,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super(
          id: id,
          farmId: farmId,
          identification: identification,
          name: name,
          category: category,
          gender: gender,
          currentWeight: currentWeight,
          birthDate: birthDate,
          productionStage: productionStage,
          healthStatus: healthStatus,
          breedingStatus: breedingStatus,
          lastHeatDate: lastHeatDate,
          inseminationDate: inseminationDate,
          expectedCalvingDate: expectedCalvingDate,
          previousCalvings: previousCalvings,
          notes: notes,
          photoUrl: photoUrl,
          idPadre: idPadre,
          nombrePadre: nombrePadre,
          idMadre: idMadre,
          nombreMadre: nombreMadre,
          raza: raza,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  /// Crea un modelo desde JSON
  factory BovinoModel.fromJson(Map<String, dynamic> json) {
    return BovinoModel(
      id: json['id'] as String,
      farmId: json['farmId'] as String,
      identification: json['identification'] as String?,
      name: json['name'] as String?,
      category: BovinoCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => BovinoCategory.vaca,
      ),
      gender: BovinoGender.values.firstWhere(
        (e) => e.name == json['gender'],
        orElse: () => BovinoGender.female,
      ),
      currentWeight: (json['currentWeight'] as num).toDouble(),
      birthDate: DateTime.parse(json['birthDate'] as String),
      productionStage: ProductionStage.values.firstWhere(
        (e) => e.name == json['productionStage'],
        orElse: () => ProductionStage.levante,
      ),
      healthStatus: HealthStatus.values.firstWhere(
        (e) => e.name == json['healthStatus'],
        orElse: () => HealthStatus.sano,
      ),
      breedingStatus: json['breedingStatus'] != null
          ? BreedingStatus.values.firstWhere(
              (e) => e.name == json['breedingStatus'],
              orElse: () => BreedingStatus.vacia,
            )
          : null,
      lastHeatDate: json['lastHeatDate'] != null
          ? DateTime.parse(json['lastHeatDate'] as String)
          : null,
      inseminationDate: json['inseminationDate'] != null
          ? DateTime.parse(json['inseminationDate'] as String)
          : null,
      expectedCalvingDate: json['expectedCalvingDate'] != null
          ? DateTime.parse(json['expectedCalvingDate'] as String)
          : null,
      previousCalvings: json['previousCalvings'] as int?,
      notes: json['notes'] as String?,
      photoUrl: json['photoUrl'] as String?,
      idPadre: json['idPadre'] as String?,
      nombrePadre: json['nombrePadre'] as String?,
      idMadre: json['idMadre'] as String?,
      nombreMadre: json['nombreMadre'] as String?,
      raza: json['raza'] as String?,
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
      'category': category.name,
      'gender': gender.name,
      'currentWeight': currentWeight,
      'birthDate': birthDate.toIso8601String(),
      'productionStage': productionStage.name,
      'healthStatus': healthStatus.name,
      'breedingStatus': breedingStatus?.name,
      'lastHeatDate': lastHeatDate?.toIso8601String(),
      'inseminationDate': inseminationDate?.toIso8601String(),
      'expectedCalvingDate': expectedCalvingDate?.toIso8601String(),
      'previousCalvings': previousCalvings,
      'notes': notes,
      'photoUrl': photoUrl,
      'idPadre': idPadre,
      'nombrePadre': nombrePadre,
      'idMadre': idMadre,
      'nombreMadre': nombreMadre,
      'raza': raza,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Crea una copia del modelo con campos modificados
  BovinoModel copyWith({
    String? id,
    String? farmId,
    String? identification,
    String? name,
    BovinoCategory? category,
    BovinoGender? gender,
    double? currentWeight,
    DateTime? birthDate,
    ProductionStage? productionStage,
    HealthStatus? healthStatus,
    BreedingStatus? breedingStatus,
    DateTime? lastHeatDate,
    DateTime? inseminationDate,
    DateTime? expectedCalvingDate,
    int? previousCalvings,
    String? notes,
    String? photoUrl,
    String? idPadre,
    String? nombrePadre,
    String? idMadre,
    String? nombreMadre,
    String? raza,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BovinoModel(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      identification: identification ?? this.identification,
      name: name ?? this.name,
      category: category ?? this.category,
      gender: gender ?? this.gender,
      currentWeight: currentWeight ?? this.currentWeight,
      birthDate: birthDate ?? this.birthDate,
      productionStage: productionStage ?? this.productionStage,
      healthStatus: healthStatus ?? this.healthStatus,
      breedingStatus: breedingStatus ?? this.breedingStatus,
      lastHeatDate: lastHeatDate ?? this.lastHeatDate,
      inseminationDate: inseminationDate ?? this.inseminationDate,
      expectedCalvingDate: expectedCalvingDate ?? this.expectedCalvingDate,
      previousCalvings: previousCalvings ?? this.previousCalvings,
      notes: notes ?? this.notes,
      photoUrl: photoUrl ?? this.photoUrl,
      idPadre: idPadre ?? this.idPadre,
      nombrePadre: nombrePadre ?? this.nombrePadre,
      idMadre: idMadre ?? this.idMadre,
      nombreMadre: nombreMadre ?? this.nombreMadre,
      raza: raza ?? this.raza,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convierte la entidad a modelo
  factory BovinoModel.fromEntity(Bovino entity) {
    return BovinoModel(
      id: entity.id,
      farmId: entity.farmId,
      identification: entity.identification,
      name: entity.name,
      category: entity.category,
      gender: entity.gender,
      currentWeight: entity.currentWeight,
      birthDate: entity.birthDate,
      productionStage: entity.productionStage,
      healthStatus: entity.healthStatus,
      breedingStatus: entity.breedingStatus,
      lastHeatDate: entity.lastHeatDate,
      inseminationDate: entity.inseminationDate,
      expectedCalvingDate: entity.expectedCalvingDate,
      previousCalvings: entity.previousCalvings,
      notes: entity.notes,
      photoUrl: entity.photoUrl,
      idPadre: entity.idPadre,
      nombrePadre: entity.nombrePadre,
      idMadre: entity.idMadre,
      nombreMadre: entity.nombreMadre,
      raza: entity.raza,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

