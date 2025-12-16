import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/pago.dart';

class PagoModel extends Pago {
  const PagoModel({
    required super.id,
    required super.workerId,
    required super.farmId,
    required super.amount,
    required super.date,
    required super.concept,
    super.notes,
  });

  factory PagoModel.fromJson(Map<String, dynamic> json) {
    return PagoModel(
      id: json['id'] as String,
      workerId: json['workerId'] as String? ?? json['worker_id'] as String? ?? '',
      farmId: json['farmId'] as String? ?? json['farm_id'] as String? ?? '',
      amount: (json['amount'] as num).toDouble(),
      date: json['date'] is String 
          ? DateTime.parse(json['date'] as String)
          : (json['date'] as Timestamp).toDate(),
      concept: json['concept'] as String,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workerId': workerId,
      'farmId': farmId,
      'amount': amount,
      'date': date.toIso8601String(),
      'concept': concept,
      'notes': notes,
    };
  }

  factory PagoModel.fromEntity(Pago entity) {
    return PagoModel(
      id: entity.id,
      workerId: entity.workerId,
      farmId: entity.farmId,
      amount: entity.amount,
      date: entity.date,
      concept: entity.concept,
      notes: entity.notes,
    );
  }
}
