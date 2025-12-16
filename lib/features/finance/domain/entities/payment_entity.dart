import 'package:equatable/equatable.dart';

/// Tipo de pago
enum PaymentType {
  full,
  advance,
}

extension PaymentTypeExtension on PaymentType {
  String get displayName {
    switch (this) {
      case PaymentType.full:
        return 'Completo';
      case PaymentType.advance:
        return 'Anticipo';
    }
  }

  String get value {
    switch (this) {
      case PaymentType.full:
        return 'complete';
      case PaymentType.advance:
        return 'advance';
    }
  }

  static PaymentType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'complete':
      case 'full':
        return PaymentType.full;
      case 'advance':
      case 'partial':
        return PaymentType.advance;
      default:
        return PaymentType.full;
    }
  }
}

/// Entidad de dominio para Pagos
class PaymentEntity extends Equatable {
  final String id;
  final String workerId;
  final String farmId;
  final DateTime date;
  final double amount;
  final PaymentType type;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PaymentEntity({
    required this.id,
    required this.workerId,
    required this.farmId,
    required this.date,
    required this.amount,
    required this.type,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        workerId,
        farmId,
        date,
        amount,
        type,
        notes,
        createdAt,
        updatedAt,
      ];

  PaymentEntity copyWith({
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
    return PaymentEntity(
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


