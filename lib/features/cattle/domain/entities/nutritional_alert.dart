import 'package:equatable/equatable.dart';

class NutritionalAlert extends Equatable {
  final String id;
  final String bovineId;
  final String farmId;
  final String alertType; // e.g., "Deficit", "Excess", "Imbalance"
  final String description;
  final String severity; // "Low", "Medium", "High"
  final DateTime dateDetected;
  final bool isResolved;

  const NutritionalAlert({
    required this.id,
    required this.bovineId,
    required this.farmId,
    required this.alertType,
    required this.description,
    required this.severity,
    required this.dateDetected,
    this.isResolved = false,
  });

  @override
  List<Object?> get props => [
        id,
        bovineId,
        farmId,
        alertType,
        description,
        severity,
        dateDetected,
        isResolved,
      ];
}
