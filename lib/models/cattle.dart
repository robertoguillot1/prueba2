enum CattleCategory {
  vaca,
  toro,
  ternero,
  novilla,
}

enum CattleGender {
  male,
  female,
}

enum ProductionStage {
  levante,
  desarrollo,
  produccion,
  descarte,
}

extension ProductionStageExtension on ProductionStage {
  // Mapeo de valores antiguos
  static ProductionStage? fromString(String value) {
    switch (value) {
      case 'cria':
        return ProductionStage.levante;
      case 'ceba':
        return ProductionStage.desarrollo;
      case 'reproductiva':
        return ProductionStage.produccion;
      default:
        return ProductionStage.values.firstWhere(
          (e) => e.name == value,
          orElse: () => ProductionStage.levante,
        );
    }
  }
}

enum HealthStatus {
  sano,
  enfermo,
  tratamiento,
}

enum BreedingStatus {
  vacia,      // Sin estado
  enCelo,     // En celo
  prenada,    // Gestante
  lactante,   // Parida
  seca,       // Seca
}

extension BreedingStatusExtension on BreedingStatus {
  // Mapeo de valores antiguos
  static BreedingStatus? fromString(String value) {
    switch (value) {
      case 'ninguno':
        return BreedingStatus.vacia;
      case 'enCelo':
        return BreedingStatus.enCelo;
      case 'gestante':
        return BreedingStatus.prenada;
      case 'parida':
        return BreedingStatus.lactante;
      case 'descansando':
        return BreedingStatus.seca;
      default:
        return BreedingStatus.values.firstWhere(
          (e) => e.name == value,
          orElse: () => BreedingStatus.vacia,
        );
    }
  }
  
  // Getters para compatibilidad
  bool get isNinguno => this == BreedingStatus.vacia;
  bool get isEnCelo => this == BreedingStatus.enCelo;
  bool get isGestante => this == BreedingStatus.prenada;
  bool get isParida => this == BreedingStatus.lactante;
  bool get isDescansando => this == BreedingStatus.seca;
  
  String get displayName {
    switch (this) {
      case BreedingStatus.vacia:
        return 'Sin estado';
      case BreedingStatus.enCelo:
        return 'En celo';
      case BreedingStatus.prenada:
        return 'Gestante';
      case BreedingStatus.lactante:
        return 'Parida';
      case BreedingStatus.seca:
        return 'Seca';
    }
  }
}

class Cattle {
  final String id;
  final String farmId;
  final String? identification;
  final String? name;
  final CattleCategory category;
  final CattleGender gender;
  final double currentWeight;
  final DateTime birthDate;
  final ProductionStage productionStage;
  final HealthStatus healthStatus;
  final BreedingStatus? breedingStatus;
  final DateTime? lastHeatDate;
  final DateTime? inseminationDate;
  final DateTime? expectedCalvingDate;
  final int? previousCalvings;
  final String? notes;
  final String? photoUrl;
  final String? idPadre; // ID del padre
  final String? nombrePadre; // Nombre del padre (cache)
  final String? idMadre; // ID de la madre
  final String? nombreMadre; // Nombre de la madre (cache)
  final String? raza; // Raza del animal
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Cattle({
    required this.id,
    required this.farmId,
    this.identification,
    this.name,
    required this.category,
    required this.gender,
    required this.currentWeight,
    required this.birthDate,
    required this.productionStage,
    required this.healthStatus,
    this.breedingStatus,
    this.lastHeatDate,
    this.inseminationDate,
    this.expectedCalvingDate,
    this.previousCalvings,
    this.notes,
    this.photoUrl,
    this.idPadre,
    this.nombrePadre,
    this.idMadre,
    this.nombreMadre,
    this.raza,
    this.createdAt,
    this.updatedAt,
  });

  String get categoryString {
    switch (category) {
      case CattleCategory.vaca:
        return 'Vaca';
      case CattleCategory.toro:
        return 'Toro';
      case CattleCategory.ternero:
        return 'Ternero';
      case CattleCategory.novilla:
        return 'Novilla';
    }
  }

  String get genderString {
    switch (gender) {
      case CattleGender.male:
        return 'Macho';
      case CattleGender.female:
        return 'Hembra';
    }
  }

  String get productionStageString {
    switch (productionStage) {
      case ProductionStage.levante:
        return 'Levante';
      case ProductionStage.desarrollo:
        return 'Desarrollo';
      case ProductionStage.produccion:
        return 'Producción';
      case ProductionStage.descarte:
        return 'Descarte';
    }
  }

  String get healthStatusString {
    switch (healthStatus) {
      case HealthStatus.sano:
        return 'Sano';
      case HealthStatus.enfermo:
        return 'Enfermo';
      case HealthStatus.tratamiento:
        return 'En Tratamiento';
    }
  }

  String get breedingStatusString {
    if (breedingStatus == null) return 'N/A';
    switch (breedingStatus!) {
      case BreedingStatus.vacia:
        return 'Vacía';
      case BreedingStatus.enCelo:
        return 'En celo';
      case BreedingStatus.prenada:
        return 'Prenada';
      case BreedingStatus.lactante:
        return 'Lactante';
      case BreedingStatus.seca:
        return 'Seca';
    }
  }

  int get ageInYears {
    final now = DateTime.now();
    int years = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      years--;
    }
    return years;
  }

  bool get needsSpecialCare {
    if (healthStatus == HealthStatus.enfermo || healthStatus == HealthStatus.tratamiento) {
      return true;
    }
    if (breedingStatus == BreedingStatus.prenada && isVeryCloseToCalving) {
      return true;
    }
    return false;
  }

  bool get isVeryCloseToCalving {
    if (expectedCalvingDate == null) return false;
    final now = DateTime.now();
    final daysUntil = expectedCalvingDate!.difference(now).inDays;
    return daysUntil >= 0 && daysUntil <= 30;
  }

  String get gestationMonthString {
    if (inseminationDate == null) return 'N/A';
    final now = DateTime.now();
    final months = (now.difference(inseminationDate!).inDays / 30).floor();
    return '$months meses';
  }

  int? get daysUntilCalving {
    if (expectedCalvingDate == null) return null;
    final now = DateTime.now();
    return expectedCalvingDate!.difference(now).inDays;
  }

  // Getter para calcular la fecha probable de parto
  DateTime? get fechaProbableParto {
    // Si ya existe expectedCalvingDate, usarlo
    if (expectedCalvingDate != null) return expectedCalvingDate;
    
    // Si hay fecha de inseminación, calcular (inseminación + 283 días)
    if (inseminationDate != null) {
      return inseminationDate!.add(const Duration(days: 283));
    }
    
    return null;
  }

  // Getter para calcular la fecha de secado (60 días antes del parto)
  DateTime? get fechaSecado {
    final fechaParto = fechaProbableParto;
    if (fechaParto == null) return null;
    return fechaParto.subtract(const Duration(days: 60));
  }

  // Getter para calcular días hasta el secado
  int? get diasHastaSecado {
    final fechaSecadoCalculada = fechaSecado;
    if (fechaSecadoCalculada == null) return null;
    final now = DateTime.now();
    return fechaSecadoCalculada.difference(now).inDays;
  }

  // Getter para verificar si necesita secado
  // Solo si está preñada y no está seca (está en producción)
  bool get necesitaSecado {
    if (breedingStatus != BreedingStatus.prenada) return false;
    if (breedingStatus == BreedingStatus.seca) return false; // Ya está seca
    return fechaSecado != null;
  }

  // Getter para determinar el nivel de urgencia del secado
  // Retorna: null (no necesita), 'warning' (15-30 días), 'urgent' (<15 días o pasado)
  String? get nivelUrgenciaSecado {
    if (!necesitaSecado) return null;
    final dias = diasHastaSecado;
    if (dias == null) return null;
    
    if (dias < 15) return 'urgent'; // Menos de 15 días o ya pasó
    if (dias <= 30) return 'warning'; // Entre 15 y 30 días
    return null; // Más de 30 días, no es urgente aún
  }

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

  factory Cattle.fromJson(Map<String, dynamic> json) {
    return Cattle(
      id: json['id'] as String,
      farmId: json['farmId'] as String,
      identification: json['identification'] as String?,
      name: json['name'] as String?,
      category: CattleCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => CattleCategory.vaca,
      ),
      gender: CattleGender.values.firstWhere(
        (e) => e.name == json['gender'],
        orElse: () => CattleGender.female,
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

  Cattle copyWith({
    String? id,
    String? farmId,
    String? identification,
    String? name,
    CattleCategory? category,
    CattleGender? gender,
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
    return Cattle(
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
}




