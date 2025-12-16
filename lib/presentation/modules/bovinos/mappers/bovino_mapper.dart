import '../../../../domain/entities/bovinos/bovino.dart' as old;
import '../../../../features/cattle/domain/entities/bovine_entity.dart';

/// Mapper para convertir entre el modelo viejo (Bovino) y el nuevo (BovineEntity)
class BovinoMapper {
  /// Convierte un Bovino (viejo) a BovineEntity (nuevo)
  static BovineEntity toEntity(old.Bovino bovino) {
    return BovineEntity(
      id: bovino.id,
      farmId: bovino.farmId,
      identifier: bovino.identification ?? 'SIN-ID',
      name: bovino.name,
      breed: bovino.raza ?? 'Desconocida',
      gender: _mapGender(bovino.gender),
      birthDate: bovino.birthDate,
      weight: bovino.currentWeight,
      purpose: _inferPurpose(bovino),
      status: _mapStatus(bovino.healthStatus),
      createdAt: bovino.createdAt ?? DateTime.now(),
      updatedAt: bovino.updatedAt,
    );
  }

  /// Mapea el género (los enums tienen los mismos valores)
  static BovineGender _mapGender(old.BovinoGender oldGender) {
    switch (oldGender) {
      case old.BovinoGender.male:
        return BovineGender.male;
      case old.BovinoGender.female:
        return BovineGender.female;
    }
  }

  /// Infiere el propósito basándose en la categoría y etapa de producción
  static BovinePurpose _inferPurpose(old.Bovino bovino) {
    // Si es vaca o tiene estado de lactancia/prenada, probablemente es leche o dual
    if (bovino.category == old.BovinoCategory.vaca) {
      if (bovino.breedingStatus == old.BreedingStatus.lactante ||
          bovino.breedingStatus == old.BreedingStatus.prenada) {
        return BovinePurpose.dual; // Probablemente dual propósito
      }
      return BovinePurpose.milk; // Vacas generalmente para leche
    }

    // Si es toro, probablemente reproducción o carne
    if (bovino.category == old.BovinoCategory.toro) {
      return BovinePurpose.meat; // Toros usualmente para carne
    }

    // Terneros y novillos en desarrollo
    if (bovino.category == old.BovinoCategory.ternero ||
        bovino.category == old.BovinoCategory.novilla) {
      if (bovino.productionStage == old.ProductionStage.levante ||
          bovino.productionStage == old.ProductionStage.desarrollo) {
        return BovinePurpose.dual; // En desarrollo, podría ser dual
      }
    }

    // Si está en descarte, probablemente carne
    if (bovino.productionStage == old.ProductionStage.descarte) {
      return BovinePurpose.meat;
    }

    // Por defecto: dual propósito (más seguro)
    return BovinePurpose.dual;
  }

  /// Mapea el estado de salud a estado general
  static BovineStatus _mapStatus(old.HealthStatus healthStatus) {
    switch (healthStatus) {
      case old.HealthStatus.sano:
        return BovineStatus.active; // Sano = Activo
      case old.HealthStatus.enfermo:
        return BovineStatus.active; // Enfermo pero aún en la finca = Activo
      case old.HealthStatus.tratamiento:
        return BovineStatus.active; // En tratamiento = Activo
      default:
        return BovineStatus.active; // Por defecto, activo
    }
  }

  /// Convierte una lista de Bovino a lista de BovineEntity
  static List<BovineEntity> toEntityList(List<old.Bovino> bovinos) {
    return bovinos.map((bovino) => toEntity(bovino)).toList();
  }

  /// Convierte un BovineEntity (nuevo) a Bovino (viejo)
  /// Útil para mantener compatibilidad con widgets legacy
  static old.Bovino fromEntity(BovineEntity entity) {
    return old.Bovino(
      id: entity.id,
      farmId: entity.farmId,
      identification: entity.identifier,
      name: entity.name,
      category: _mapCategoryFromEntity(entity),
      gender: _mapGenderFromEntity(entity.gender),
      currentWeight: entity.weight,
      birthDate: entity.birthDate,
      productionStage: _mapProductionStageFromEntity(entity.productionStage),
      healthStatus: _mapHealthStatusFromEntity(entity.healthStatus),
      breedingStatus: entity.breedingStatus != null 
          ? _mapBreedingStatusFromEntity(entity.breedingStatus!)
          : null,
      lastHeatDate: entity.lastHeatDate,
      inseminationDate: entity.inseminationDate,
      expectedCalvingDate: entity.expectedCalvingDate,
      previousCalvings: entity.previousCalvings,
      notes: entity.notes,
      photoUrl: entity.photoUrl,
      idPadre: entity.fatherId,
      nombrePadre: null, // No disponible en BovineEntity
      idMadre: entity.motherId,
      nombreMadre: null, // No disponible en BovineEntity
      raza: entity.breed,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Mapea el género de nuevo a viejo
  static old.BovinoGender _mapGenderFromEntity(BovineGender gender) {
    switch (gender) {
      case BovineGender.male:
        return old.BovinoGender.male;
      case BovineGender.female:
        return old.BovinoGender.female;
    }
  }

  /// Mapea la categoría desde BovineEntity (calculada) a BovinoCategory
  static old.BovinoCategory _mapCategoryFromEntity(BovineEntity entity) {
    final category = entity.category;
    switch (category) {
      case BovineCategory.ternero:
        return old.BovinoCategory.ternero;
      case BovineCategory.ternera:
        return old.BovinoCategory.novilla; // Corregido: ternilla -> novilla
      case BovineCategory.novillo:
        return old.BovinoCategory.ternero; // Aproximación
      case BovineCategory.novilla:
        return old.BovinoCategory.novilla;
      case BovineCategory.toro:
        return old.BovinoCategory.toro;
      case BovineCategory.vaca:
        return old.BovinoCategory.vaca;
    }
  }

  /// Mapea ProductionStage de nuevo a viejo
  static old.ProductionStage _mapProductionStageFromEntity(ProductionStage stage) {
    switch (stage) {
      case ProductionStage.raising:
        return old.ProductionStage.levante;
      case ProductionStage.productive:
        return old.ProductionStage.produccion;
      case ProductionStage.dry:
        return old.ProductionStage.descarte; // Aproximación
    }
  }

  /// Mapea HealthStatus de nuevo a viejo
  static old.HealthStatus _mapHealthStatusFromEntity(HealthStatus status) {
    switch (status) {
      case HealthStatus.healthy:
        return old.HealthStatus.sano;
      case HealthStatus.sick:
        return old.HealthStatus.enfermo;
      case HealthStatus.underTreatment:
        return old.HealthStatus.tratamiento;
      case HealthStatus.recovering:
        return old.HealthStatus.enfermo; // Aproximación
    }
  }

  /// Mapea BreedingStatus de nuevo a viejo
  static old.BreedingStatus _mapBreedingStatusFromEntity(BreedingStatus status) {
    switch (status) {
      case BreedingStatus.notSpecified:
      case BreedingStatus.empty:
        return old.BreedingStatus.vacia;
      case BreedingStatus.pregnant:
        return old.BreedingStatus.prenada;
      case BreedingStatus.inseminated:
        return old.BreedingStatus.enCelo; // Aproximación
      case BreedingStatus.served:
        return old.BreedingStatus.enCelo; // Aproximación
    }
  }
}



