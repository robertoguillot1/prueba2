/// Entidad de dominio para Bovino
class Bovino {
  final String id;
  final String farmId;
  final String? identification;
  final String? name;
  final BovinoCategory category;
  final BovinoGender gender;
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
  final String? idPadre;
  final String? nombrePadre;
  final String? idMadre;
  final String? nombreMadre;
  final String? raza;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Bovino({
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

  /// Calcula la edad en años
  int get ageInYears {
    final now = DateTime.now();
    int years = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      years--;
    }
    return years;
  }

  /// Indica si necesita cuidados especiales
  bool get needsSpecialCare {
    if (healthStatus == HealthStatus.enfermo || 
        healthStatus == HealthStatus.tratamiento) {
      return true;
    }
    if (breedingStatus == BreedingStatus.prenada && isVeryCloseToCalving) {
      return true;
    }
    return false;
  }

  /// Indica si está muy cerca del parto
  bool get isVeryCloseToCalving {
    if (expectedCalvingDate == null) return false;
    final now = DateTime.now();
    final daysUntil = expectedCalvingDate!.difference(now).inDays;
    return daysUntil >= 0 && daysUntil <= 30;
  }

  /// Calcula días hasta el parto
  int? get daysUntilCalving {
    if (expectedCalvingDate == null) return null;
    final now = DateTime.now();
    return expectedCalvingDate!.difference(now).inDays;
  }

  /// Valida que la entidad sea válida
  bool get isValid {
    if (id.isEmpty || farmId.isEmpty) return false;
    if (currentWeight <= 0) return false;
    if (birthDate.isAfter(DateTime.now())) return false;
    if (previousCalvings != null && previousCalvings! < 0) return false;
    return true;
  }
}

/// Categoría del bovino
enum BovinoCategory {
  vaca,
  toro,
  ternero,
  novilla,
}

/// Género del bovino
enum BovinoGender {
  male,
  female,
}

/// Etapa de producción
enum ProductionStage {
  levante,
  desarrollo,
  produccion,
  descarte,
}

/// Estado de salud
enum HealthStatus {
  sano,
  enfermo,
  tratamiento,
}

/// Estado reproductivo
enum BreedingStatus {
  vacia,
  enCelo,
  prenada,
  lactante,
  seca,
}

