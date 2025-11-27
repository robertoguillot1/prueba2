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
}



