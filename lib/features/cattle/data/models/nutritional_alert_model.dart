import '../../domain/entities/nutritional_alert.dart';

class NutritionalAlertModel extends NutritionalAlert {
  const NutritionalAlertModel({
    required super.id,
    required super.bovineId,
    required super.farmId,
    required super.alertType,
    required super.description,
    required super.severity,
    required super.dateDetected,
    super.isResolved,
  });

  factory NutritionalAlertModel.fromJson(Map<String, dynamic> json) {
    return NutritionalAlertModel(
      id: json['id'],
      bovineId: json['bovineId'],
      farmId: json['farmId'],
      alertType: json['alertType'],
      description: json['description'],
      severity: json['severity'],
      dateDetected: DateTime.parse(json['dateDetected']),
      isResolved: json['isResolved'] == 1 || json['isResolved'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bovineId': bovineId,
      'farmId': farmId,
      'alertType': alertType,
      'description': description,
      'severity': severity,
      'dateDetected': dateDetected.toIso8601String(),
      'isResolved': isResolved ? 1 : 0,
    };
  }
}
