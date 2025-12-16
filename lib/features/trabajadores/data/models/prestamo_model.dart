import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/prestamo.dart';

class PrestamoModel extends Prestamo {
  const PrestamoModel({
    required super.id,
    required super.workerId,
    required super.farmId,
    required super.amount,
    required super.date,
    required super.description,
    super.isPaid,
  });

  factory PrestamoModel.fromJson(Map<String, dynamic> json) {
    return PrestamoModel(
      id: json['id'] as String,
      workerId: json['workerId'] as String? ?? json['worker_id'] as String? ?? '',
      farmId: json['farmId'] as String? ?? json['farm_id'] as String? ?? '',
      amount: (json['amount'] as num).toDouble(),
      date: json['date'] is String 
          ? DateTime.parse(json['date'] as String)
          : (json['date'] as Timestamp).toDate(),
      description: json['description'] as String,
      isPaid: json['isPaid'] as bool? ?? (json['is_paid'] == 1 || json['is_paid'] == true),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workerId': workerId,
      'farmId': farmId,
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
      'isPaid': isPaid,
    };
  }

  factory PrestamoModel.fromEntity(Prestamo entity) {
    return PrestamoModel(
      id: entity.id,
      workerId: entity.workerId,
      farmId: entity.farmId,
      amount: entity.amount,
      date: entity.date,
      description: entity.description,
      isPaid: entity.isPaid,
    );
  }
}
