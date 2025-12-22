import 'package:equatable/equatable.dart';

/// Estado del préstamo
enum LoanStatus {
  pending,
  paid,
  cancelled,
}

extension LoanStatusExtension on LoanStatus {
  String get displayName {
    switch (this) {
      case LoanStatus.pending:
        return 'Pendiente';
      case LoanStatus.paid:
        return 'Pagado';
      case LoanStatus.cancelled:
        return 'Cancelado';
    }
  }

  static LoanStatus fromString(String value) {
    return LoanStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => LoanStatus.pending,
    );
  }
}

/// Entidad de dominio para Préstamos
class LoanEntity extends Equatable {
  final String id;
  final String workerId;
  final String farmId;
  final DateTime date;
  final double amount;
  final String description;
  final LoanStatus status;
  final DateTime? paymentDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const LoanEntity({
    required this.id,
    required this.workerId,
    required this.farmId,
    required this.date,
    required this.amount,
    required this.description,
    required this.status,
    this.paymentDate,
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
        description,
        status,
        paymentDate,
        notes,
        createdAt,
        updatedAt,
      ];

  LoanEntity copyWith({
    String? id,
    String? workerId,
    String? farmId,
    DateTime? date,
    double? amount,
    String? description,
    LoanStatus? status,
    DateTime? paymentDate,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LoanEntity(
      id: id ?? this.id,
      workerId: workerId ?? this.workerId,
      farmId: farmId ?? this.farmId,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      status: status ?? this.status,
      paymentDate: paymentDate ?? this.paymentDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}






