import '../../domain/entities/ovinos/oveja.dart';
import '../../domain/entities/bovinos/bovino.dart';
import '../../domain/entities/porcinos/cerdo.dart';
import '../../domain/entities/avicultura/gallina.dart';
import '../../domain/entities/bovinos/produccion_leche.dart';
import '../../domain/entities/avicultura/produccion_huevos.dart';

/// Cálculos avanzados e inteligentes para animales
class AdvancedCalculations {
  // ========== OVINOS / BOVINOS ==========
  
  /// Calcula la fecha probable de parto (gestación ~150 días para ovejas, ~280 para bovinos)
  static DateTime? calculateFechaProbableParto({
    required DateTime fechaMonta,
    required int diasGestacion,
  }) {
    return fechaMonta.add(Duration(days: diasGestacion));
  }

  /// Calcula la ganancia diaria de peso
  static double calculateGananciaDiaria({
    required double pesoInicial,
    required double pesoFinal,
    required int dias,
  }) {
    if (dias == 0) return 0.0;
    return (pesoFinal - pesoInicial) / dias;
  }

  /// Clasifica un animal por etapa según su edad
  static String classifyByAge(DateTime birthDate) {
    final ageInMonths = _calculateAgeInMonths(birthDate);
    if (ageInMonths < 6) return 'Cría';
    if (ageInMonths < 12) return 'Novillo/Joven';
    return 'Adulto';
  }

  /// Verifica si el peso está bajo (alerta)
  static bool isUnderweight(double currentWeight, double expectedWeight, {double threshold = 0.15}) {
    return currentWeight < (expectedWeight * (1 - threshold));
  }

  // ========== PORCINOS ==========
  
  /// Calcula el índice de conversión alimenticia (kg alimento / kg ganancia)
  static double? calculateConversionIndex({
    required double alimentoConsumido,
    required double gananciaPeso,
  }) {
    if (gananciaPeso == 0) return null;
    return alimentoConsumido / gananciaPeso;
  }

  /// Calcula días hasta el destete (típicamente 21-28 días)
  static int calculateDaysToWeaning(DateTime birthDate, {int weaningDays = 28}) {
    final weaningDate = birthDate.add(Duration(days: weaningDays));
    final now = DateTime.now();
    final difference = weaningDate.difference(now);
    return difference.inDays > 0 ? difference.inDays : 0;
  }

  /// Estima el peso según la edad (fórmula aproximada)
  static double estimateWeightByAge(DateTime birthDate, {required double birthWeight}) {
    final ageInDays = DateTime.now().difference(birthDate).inDays;
    // Fórmula simplificada: ganancia promedio de 0.3-0.5 kg/día
    return birthWeight + (ageInDays * 0.4);
  }

  // ========== AVICULTURA ==========
  
  /// Calcula la producción promedio de huevos por día
  static double calculateDailyEggProduction(List<ProduccionHuevos> records) {
    if (records.isEmpty) return 0.0;
    final totalEggs = records.fold(0, (sum, r) => sum + r.cantidadHuevos);
    final days = _calculateDaysBetween(records.first.fecha, records.last.fecha);
    return days > 0 ? totalEggs / days : 0.0;
  }

  /// Calcula la producción semanal
  static double calculateWeeklyProduction(List<ProduccionHuevos> records) {
    final weeklyRecords = records.where((r) {
      final daysAgo = DateTime.now().difference(r.fecha).inDays;
      return daysAgo <= 7;
    }).toList();
    return weeklyRecords.fold(0, (sum, r) => sum + r.cantidadHuevos).toDouble();
  }

  /// Calcula la producción mensual
  static double calculateMonthlyProduction(List<ProduccionHuevos> records) {
    final monthlyRecords = records.where((r) {
      final daysAgo = DateTime.now().difference(r.fecha).inDays;
      return daysAgo <= 30;
    }).toList();
    return monthlyRecords.fold(0, (sum, r) => sum + r.cantidadHuevos).toDouble();
  }

  /// Verifica si hay alerta de baja producción
  static bool hasLowProductionAlert(List<ProduccionHuevos> records, {double threshold = 0.7}) {
    if (records.length < 7) return false; // Necesita al menos una semana de datos
    final weeklyAvg = calculateWeeklyProduction(records) / 7;
    final historicalAvg = calculateDailyEggProduction(records);
    return weeklyAvg < (historicalAvg * threshold);
  }

  /// Calcula el consumo de alimento por lote
  static double calculateFeedConsumptionByLot(List<Map<String, dynamic>> alimentacionRecords) {
    return alimentacionRecords.fold(0.0, (sum, r) {
      return sum + (r['cantidadAlimento'] as num).toDouble();
    });
  }

  // ========== TRABAJADORES ==========
  
  /// Calcula las horas trabajadas en un período
  static double calculateWorkedHours({
    required DateTime startDate,
    required DateTime endDate,
    required int hoursPerDay,
  }) {
    final days = endDate.difference(startDate).inDays;
    return (days * hoursPerDay).toDouble();
  }

  /// Calcula el rendimiento de un trabajador
  static double calculatePerformance({
    required int tasksCompleted,
    required int totalTasks,
  }) {
    if (totalTasks == 0) return 0.0;
    return (tasksCompleted / totalTasks) * 100;
  }

  // ========== UTILIDADES ==========
  
  static int _calculateAgeInMonths(DateTime birthDate) {
    final now = DateTime.now();
    return (now.year - birthDate.year) * 12 + (now.month - birthDate.month);
  }

  static int _calculateDaysBetween(DateTime start, DateTime end) {
    return end.difference(start).inDays + 1;
  }
}

