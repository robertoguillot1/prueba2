import '../../domain/entities/feeding_schedule.dart';

class FeedingScheduleModel extends FeedingSchedule {
  const FeedingScheduleModel({
    required super.id,
    required super.bovineId,
    required super.farmId,
    required super.feedType,
    required super.amountKg,
    required super.frequency,
    required super.startDate,
    super.endDate,
    super.notes,
  });

  factory FeedingScheduleModel.fromJson(Map<String, dynamic> json) {
    return FeedingScheduleModel(
      id: json['id'],
      bovineId: json['bovineId'],
      farmId: json['farmId'],
      feedType: json['feedType'],
      amountKg: (json['amountKg'] as num).toDouble(),
      frequency: json['frequency'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bovineId': bovineId,
      'farmId': farmId,
      'feedType': feedType,
      'amountKg': amountKg,
      'frequency': frequency,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'notes': notes,
    };
  }

  factory FeedingScheduleModel.fromEntity(FeedingSchedule entity) {
    return FeedingScheduleModel(
      id: entity.id,
      bovineId: entity.bovineId,
      farmId: entity.farmId,
      feedType: entity.feedType,
      amountKg: entity.amountKg,
      frequency: entity.frequency,
      startDate: entity.startDate,
      endDate: entity.endDate,
      notes: entity.notes,
    );
  }
}
