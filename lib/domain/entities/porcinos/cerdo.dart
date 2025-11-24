/// Entidad de dominio para Cerdo
class Cerdo {
  final String id;
  final String farmId;
  final String? identification;
  final CerdoGender gender;
  final DateTime birthDate;
  final double currentWeight;
  final FeedingStage feedingStage;
  final String? notes;
  final DateTime updatedAt;

  const Cerdo({
    required this.id,
    required this.farmId,
    this.identification,
    required this.gender,
    required this.birthDate,
    required this.currentWeight,
    required this.feedingStage,
    this.notes,
    required this.updatedAt,
  });

  /// Calcula la edad en días
  int get ageInDays {
    final now = DateTime.now();
    return now.difference(birthDate).inDays;
  }

  /// Estima el consumo diario basado en peso y etapa
  double get estimatedDailyConsumption {
    double baseConsumption = currentWeight * 0.04; // 4% del peso
    switch (feedingStage) {
      case FeedingStage.inicio:
        return baseConsumption * 0.8;
      case FeedingStage.levante:
        return baseConsumption;
      case FeedingStage.engorde:
        return baseConsumption * 1.2;
    }
  }

  /// Valida que la entidad sea válida
  bool get isValid {
    if (id.isEmpty || farmId.isEmpty) return false;
    if (currentWeight <= 0) return false;
    if (birthDate.isAfter(DateTime.now())) return false;
    return true;
  }
}

/// Género del cerdo
enum CerdoGender {
  male,
  female,
}

/// Etapa de alimentación
enum FeedingStage {
  inicio,
  levante,
  engorde,
}



