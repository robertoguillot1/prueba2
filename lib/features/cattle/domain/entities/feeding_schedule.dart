import 'package:equatable/equatable.dart';

class FeedingSchedule extends Equatable {
  final String id;
  final String bovineId;
  final String farmId;
  final String feedType; // e.g., "Concentrado", "Pasto", "Sal"
  final double amountKg;
  final String frequency; // e.g., "AM", "PM", "Diario"
  final DateTime startDate;
  final DateTime? endDate;
  final String? notes;

  const FeedingSchedule({
    required this.id,
    required this.bovineId,
    required this.farmId,
    required this.feedType,
    required this.amountKg,
    required this.frequency,
    required this.startDate,
    this.endDate,
    this.notes,
  });

  @override
  List<Object?> get props => [
        id,
        bovineId,
        farmId,
        feedType,
        amountKg,
        frequency,
        startDate,
        endDate,
        notes,
      ];
}
