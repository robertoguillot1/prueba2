import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Entidad de dominio para Bovino
class BovineEntity extends Equatable {
  final String id;
  final String farmId;
  final String identifier; // Arete/número de identificación
  final String? name;
  final String breed; // Raza
  final BovineGender gender;
  final DateTime birthDate;
  final double weight;
  final BovinePurpose purpose; // carne/leche/doble
  final BovineStatus status; // activo/vendido/muerto
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? motherId; // ID de la madre (genealogía)
  final String? fatherId; // ID del padre (genealogía)
  
  // Nuevos campos para sistema completo
  final int previousCalvings; // Número de partos previos
  final HealthStatus healthStatus; // Estado de salud
  final ProductionStage productionStage; // Etapa de producción
  final BreedingStatus? breedingStatus; // Estado reproductivo (solo hembras)
  final DateTime? lastHeatDate; // Última fecha de celo (solo hembras)
  final DateTime? inseminationDate; // Fecha de inseminación (solo hembras)
  final DateTime? expectedCalvingDate; // Fecha esperada de parto (solo hembras)
  final String? notes; // Notas adicionales

  const BovineEntity({
    required this.id,
    required this.farmId,
    required this.identifier,
    this.name,
    required this.breed,
    required this.gender,
    required this.birthDate,
    required this.weight,
    required this.purpose,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.motherId,
    this.fatherId,
    this.previousCalvings = 0,
    this.healthStatus = HealthStatus.healthy,
    this.productionStage = ProductionStage.raising,
    this.breedingStatus,
    this.lastHeatDate,
    this.inseminationDate,
    this.expectedCalvingDate,
    this.notes,
  });

  /// Calcula la edad del bovino en años basada en birthDate
  int get age {
    final now = DateTime.now();
    int years = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      years--;
    }
    return years;
  }

  /// Calcula la edad en meses (para categorización)
  int get ageInMonths {
    final now = DateTime.now();
    final difference = now.difference(birthDate);
    return (difference.inDays / 30.44).floor(); // Promedio de días por mes
  }

  /// Representación legible de la edad
  String get ageDisplay {
    final months = ageInMonths;
    if (months < 12) {
      return '$months ${months == 1 ? "mes" : "meses"}';
    } else {
      final years = (months / 12).floor();
      final remainingMonths = months % 12;
      if (remainingMonths == 0) {
        return '$years ${years == 1 ? "año" : "años"}';
      } else {
        return '$years ${years == 1 ? "año" : "años"} y $remainingMonths ${remainingMonths == 1 ? "mes" : "meses"}';
      }
    }
  }

  /// Categoría automática basada en edad, género y partos
  BovineCategory get category {
    final months = ageInMonths;
    final hasBirths = previousCalvings > 0;

    if (gender == BovineGender.male) {
      // MACHOS
      if (months < 12) {
        return BovineCategory.ternero; // 0-12 meses
      } else if (months < 24) {
        return BovineCategory.novillo; // 12-24 meses
      } else {
        return BovineCategory.toro; // 24+ meses
      }
    } else {
      // HEMBRAS
      if (months < 12) {
        return BovineCategory.ternera; // 0-12 meses
      } else if (hasBirths) {
        return BovineCategory.vaca; // Ya ha parido = VACA
      } else if (months < 24) {
        return BovineCategory.novilla; // 12-24 meses sin parir
      } else {
        return BovineCategory.vaca; // 24+ meses (aunque no haya parido)
      }
    }
  }

  /// Crea una copia de la entidad con los valores actualizados
  BovineEntity copyWith({
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
  }) {
    return BovineEntity(
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
    );
  }

  /// Valida que la entidad sea válida
  /// Nota: No validamos el ID porque se genera automáticamente en Firestore
  bool get isValid {
    return farmId.isNotEmpty &&
        identifier.isNotEmpty &&
        breed.isNotEmpty &&
        weight > 0 &&
        // Permitir fecha de hoy, pero no fechas futuras
        birthDate.isBefore(DateTime.now().add(const Duration(days: 1)));
  }

  @override
  List<Object?> get props => [
        id,
        farmId,
        identifier,
        name,
        breed,
        gender,
        birthDate,
        weight,
        purpose,
        status,
        createdAt,
        updatedAt,
        motherId,
        fatherId,
        previousCalvings,
        healthStatus,
        productionStage,
        breedingStatus,
        lastHeatDate,
        inseminationDate,
        expectedCalvingDate,
        notes,
      ];
}

/// Género del bovino
enum BovineGender {
  male, // Macho
  female, // Hembra
}

/// Propósito del bovino
enum BovinePurpose {
  meat, // Carne
  milk, // Leche
  dual, // Doble propósito
}

/// Estado del bovino
enum BovineStatus {
  active, // Activo
  sold, // Vendido
  dead, // Muerto
}

/// Categoría del bovino (calculada automáticamente)
enum BovineCategory {
  ternero, // Macho 0-12 meses
  ternera, // Hembra 0-12 meses
  novillo, // Macho 12-24 meses
  novilla, // Hembra 12-24 meses (sin parir)
  toro, // Macho 24+ meses
  vaca, // Hembra después del 1er parto o 24+ meses
}

/// Estado de salud del bovino
enum HealthStatus {
  healthy, // Sano
  sick, // Enfermo
  underTreatment, // En tratamiento
  recovering, // Recuperándose
}

/// Etapa de producción
enum ProductionStage {
  raising, // Levante
  productive, // Productiva
  dry, // Seca
}

/// Estado reproductivo (solo hembras)
enum BreedingStatus {
  notSpecified, // No especificado
  pregnant, // Gestante
  inseminated, // Inseminada
  empty, // Vacía
  served, // Servida
}

// Extensions para obtener nombres y propiedades visuales

extension BovineCategoryExtension on BovineCategory {
  String get displayName {
    switch (this) {
      case BovineCategory.ternero:
        return 'Ternero/Becerro';
      case BovineCategory.ternera:
        return 'Ternera/Becerra';
      case BovineCategory.novillo:
        return 'Novillo/Torete';
      case BovineCategory.novilla:
        return 'Novilla';
      case BovineCategory.toro:
        return 'Toro';
      case BovineCategory.vaca:
        return 'Vaca';
    }
  }

  IconData get icon {
    switch (this) {
      case BovineCategory.ternero:
      case BovineCategory.ternera:
        return Icons.child_care;
      case BovineCategory.novillo:
      case BovineCategory.novilla:
        return Icons.pets;
      case BovineCategory.toro:
      case BovineCategory.vaca:
        return Icons.agriculture;
    }
  }

  Color get color {
    switch (this) {
      case BovineCategory.ternero:
      case BovineCategory.ternera:
        return Colors.amber;
      case BovineCategory.novillo:
      case BovineCategory.novilla:
        return Colors.orange;
      case BovineCategory.toro:
        return Colors.blue;
      case BovineCategory.vaca:
        return Colors.pink;
    }
  }
}

extension HealthStatusExtension on HealthStatus {
  String get displayName {
    switch (this) {
      case HealthStatus.healthy:
        return 'Sano';
      case HealthStatus.sick:
        return 'Enfermo';
      case HealthStatus.underTreatment:
        return 'En Tratamiento';
      case HealthStatus.recovering:
        return 'Recuperándose';
    }
  }

  Color get color {
    switch (this) {
      case HealthStatus.healthy:
        return Colors.green;
      case HealthStatus.sick:
        return Colors.red;
      case HealthStatus.underTreatment:
        return Colors.orange;
      case HealthStatus.recovering:
        return Colors.blue;
    }
  }
}

extension ProductionStageExtension on ProductionStage {
  String get displayName {
    switch (this) {
      case ProductionStage.raising:
        return 'Levante';
      case ProductionStage.productive:
        return 'Productiva';
      case ProductionStage.dry:
        return 'Seca';
    }
  }
}

extension BreedingStatusExtension on BreedingStatus {
  String get displayName {
    switch (this) {
      case BreedingStatus.notSpecified:
        return 'No especificado';
      case BreedingStatus.pregnant:
        return 'Gestante';
      case BreedingStatus.inseminated:
        return 'Inseminada';
      case BreedingStatus.empty:
        return 'Vacía';
      case BreedingStatus.served:
        return 'Servida';
    }
  }

  Color get color {
    switch (this) {
      case BreedingStatus.notSpecified:
        return Colors.grey;
      case BreedingStatus.pregnant:
        return Colors.purple;
      case BreedingStatus.inseminated:
        return Colors.blue;
      case BreedingStatus.empty:
        return Colors.orange;
      case BreedingStatus.served:
        return Colors.green;
    }
  }
}

