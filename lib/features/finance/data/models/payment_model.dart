import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/payment_entity.dart';

/// Modelo de datos para Pagos (capa de datos)
class PaymentModel extends PaymentEntity {
  const PaymentModel({
    required super.id,
    required super.workerId,
    required super.farmId,
    required super.date,
    required super.amount,
    required super.type,
    super.notes,
    required super.createdAt,
    super.updatedAt,
  });

  /// Crea un PaymentModel desde una entidad
  factory PaymentModel.fromEntity(PaymentEntity entity) {
    return PaymentModel(
      id: entity.id,
      workerId: entity.workerId,
      farmId: entity.farmId,
      date: entity.date,
      amount: entity.amount,
      type: entity.type,
      notes: entity.notes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Crea un PaymentModel desde JSON de Firestore
  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      workerId: json['workerId'] as String,
      farmId: json['farmId'] as String,
      date: (json['date'] as Timestamp).toDate(),
      amount: (json['amount'] as num).toDouble(),
      type: PaymentTypeExtension.fromString(json['type'] as String),
      notes: json['notes'] as String?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Convierte el modelo a JSON para Firestore
  Map<String, dynamic> toJson() {
    return {
      'workerId': workerId,
      'farmId': farmId,
      'date': Timestamp.fromDate(date),
      'amount': amount,
      'type': type.value,
      if (notes != null) 'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  /// Crea una copia del modelo
  PaymentModel copyWith({
    String? id,
    String? workerId,
    String? farmId,
    DateTime? date,
    double? amount,
    PaymentType? type,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      workerId: workerId ?? this.workerId,
      farmId: farmId ?? this.farmId,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}








