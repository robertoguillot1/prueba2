import 'package:intl/intl.dart';

/// Utilidades para cálculos automáticos relacionados con animales
class AnimalCalculations {
  /// Calcula la edad en años, meses y días desde una fecha de nacimiento
  static String calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    final difference = now.difference(birthDate);
    
    final years = (difference.inDays / 365).floor();
    final months = ((difference.inDays % 365) / 30).floor();
    final days = difference.inDays % 30;
    
    if (years > 0) {
      if (months > 0) {
        return '$years año${years > 1 ? 's' : ''} y $months mes${months > 1 ? 'es' : ''}';
      }
      return '$years año${years > 1 ? 's' : ''}';
    } else if (months > 0) {
      return '$months mes${months > 1 ? 'es' : ''}';
    } else {
      return '$days día${days > 1 ? 's' : ''}';
    }
  }

  /// Calcula la edad en días
  static int ageInDays(DateTime birthDate) {
    return DateTime.now().difference(birthDate).inDays;
  }

  /// Calcula la edad en semanas
  static int ageInWeeks(DateTime birthDate) {
    return ageInDays(birthDate) ~/ 7;
  }

  /// Calcula la ganancia de peso entre dos pesos
  static double? calculateWeightGain(double? previousWeight, double? currentWeight) {
    if (previousWeight == null || currentWeight == null) {
      return null;
    }
    return currentWeight - previousWeight;
  }

  /// Calcula el porcentaje de ganancia de peso
  static double? calculateWeightGainPercentage(double? previousWeight, double? currentWeight) {
    if (previousWeight == null || currentWeight == null || previousWeight == 0) {
      return null;
    }
    return ((currentWeight - previousWeight) / previousWeight) * 100;
  }

  /// Calcula la fecha probable de parto basada en la fecha de monta
  /// 
  /// Para ovejas: 150 días (5 meses)
  /// Para bovinos: 280 días (9 meses)
  static DateTime? calculateExpectedCalvingDate(
    DateTime? matingDate, {
    required String animalType,
  }) {
    if (matingDate == null) return null;

    switch (animalType.toLowerCase()) {
      case 'oveja':
      case 'ovino':
        return matingDate.add(const Duration(days: 150));
      case 'bovino':
      case 'vaca':
      case 'toro':
        return matingDate.add(const Duration(days: 280));
      default:
        return null;
    }
  }

  /// Calcula los días restantes hasta el parto
  static int? daysUntilCalving(DateTime? expectedCalvingDate) {
    if (expectedCalvingDate == null) return null;
    final now = DateTime.now();
    final difference = expectedCalvingDate.difference(now).inDays;
    return difference > 0 ? difference : 0;
  }

  /// Determina si un parto está próximo (dentro de 30 días)
  static bool isCalvingNear(DateTime? expectedCalvingDate) {
    final days = daysUntilCalving(expectedCalvingDate);
    return days != null && days <= 30 && days > 0;
  }

  /// Calcula el consumo estimado de alimento para cerdos según la etapa
  /// 
  /// - Inicio: 0.5-1 kg/día
  /// - Desarrollo: 1.5-2.5 kg/día
  /// - Engorde: 2.5-3.5 kg/día
  /// - Finalización: 3-4 kg/día
  static double? estimatePigFeedConsumption(String feedingStage, double? weight) {
    if (weight == null) return null;

    switch (feedingStage.toLowerCase()) {
      case 'inicio':
        return weight * 0.05; // 5% del peso
      case 'desarrollo':
        return weight * 0.04; // 4% del peso
      case 'engorde':
        return weight * 0.035; // 3.5% del peso
      case 'finalización':
        return weight * 0.03; // 3% del peso
      default:
        return weight * 0.04; // Por defecto 4%
    }
  }

  /// Calcula los días al destete (normalmente 21-28 días para cerdos)
  static int? daysUntilWeaning(DateTime? birthDate, {int weaningDays = 21}) {
    if (birthDate == null) return null;
    final weaningDate = birthDate.add(Duration(days: weaningDays));
    final now = DateTime.now();
    final difference = weaningDate.difference(now).inDays;
    return difference > 0 ? difference : 0;
  }

  /// Calcula la producción promedio diaria de huevos
  static double calculateAverageDailyEggProduction(
    List<Map<String, dynamic>> productionRecords,
  ) {
    if (productionRecords.isEmpty) return 0.0;

    final totalEggs = productionRecords
        .map((record) => record['eggs'] as int? ?? 0)
        .fold<int>(0, (sum, eggs) => sum + eggs);

    return totalEggs / productionRecords.length;
  }

  /// Calcula el rendimiento semanal de producción de huevos
  static double calculateWeeklyEggProduction(
    List<Map<String, dynamic>> productionRecords,
  ) {
    if (productionRecords.isEmpty) return 0.0;

    final last7Days = productionRecords.take(7);
    final totalEggs = last7Days
        .map((record) => record['eggs'] as int? ?? 0)
        .fold<int>(0, (sum, eggs) => sum + eggs);

    return totalEggs.toDouble();
  }

  /// Calcula el rendimiento mensual de producción de huevos
  static double calculateMonthlyEggProduction(
    List<Map<String, dynamic>> productionRecords,
  ) {
    if (productionRecords.isEmpty) return 0.0;

    final last30Days = productionRecords.take(30);
    final totalEggs = last30Days
        .map((record) => record['eggs'] as int? ?? 0)
        .fold<int>(0, (sum, eggs) => sum + eggs);

    return totalEggs.toDouble();
  }

  /// Determina si una gallina está en postura basada en la edad
  /// 
  /// Las gallinas generalmente empiezan a poner huevos entre las 18-22 semanas
  static bool isLaying(DateTime? birthDate) {
    if (birthDate == null) return false;
    final ageInWeeks = AnimalCalculations.ageInWeeks(birthDate);
    return ageInWeeks >= 18;
  }

  /// Calcula la producción promedio diaria de leche
  static double calculateAverageDailyMilkProduction(
    List<Map<String, dynamic>> productionRecords,
  ) {
    if (productionRecords.isEmpty) return 0.0;

    final totalLiters = productionRecords
        .map((record) => record['liters'] as double? ?? 0.0)
        .fold<double>(0.0, (sum, liters) => sum + liters);

    return totalLiters / productionRecords.length;
  }

  /// Clasifica un animal por categoría según su edad y peso
  /// 
  /// Para bovinos:
  /// - Ternero: < 1 año
  /// - Novillo/Novilla: 1-2 años
  /// - Adulto: > 2 años
  static String classifyAnimalByAge(DateTime? birthDate, {required String animalType}) {
    if (birthDate == null) return 'Desconocido';
    
    final ageInYears = ageInDays(birthDate) / 365;

    switch (animalType.toLowerCase()) {
      case 'bovino':
      case 'vaca':
      case 'toro':
        if (ageInYears < 1) return 'Ternero/a';
        if (ageInYears < 2) return 'Novillo/a';
        return 'Adulto/a';
      case 'oveja':
      case 'ovino':
        if (ageInYears < 1) return 'Cordero/a';
        return 'Adulto/a';
      case 'cerdo':
      case 'porcino':
        if (ageInDays(birthDate) < 60) return 'Lechón';
        if (ageInDays(birthDate) < 180) return 'Cerdo joven';
        return 'Cerdo adulto';
      default:
        return 'Desconocido';
    }
  }

  /// Formatea un peso con unidades
  static String formatWeight(double? weight, {String unit = 'kg'}) {
    if (weight == null) return 'N/A';
    return '${weight.toStringAsFixed(1)} $unit';
  }

  /// Formatea una fecha de manera legible
  static String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Formatea una fecha y hora de manera legible
  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }
}



