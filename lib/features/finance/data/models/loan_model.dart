import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/loan_entity.dart';

/// Modelo de datos para Préstamos (capa de datos)
class LoanModel extends LoanEntity {
  const LoanModel({
    required super.id,
    required super.workerId,
    required super.farmId,
    required super.date,
    required super.amount,
    required super.description,
    required super.status,
    super.paymentDate,
    super.notes,
    required super.createdAt,
    super.updatedAt,
  });

  /// Crea un LoanModel desde una entidad
  factory LoanModel.fromEntity(LoanEntity entity) {
    return LoanModel(
      id: entity.id,
      workerId: entity.workerId,
      farmId: entity.farmId,
      date: entity.date,
      amount: entity.amount,
      description: entity.description,
      status: entity.status,
      paymentDate: entity.paymentDate,
      notes: entity.notes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Crea un LoanModel desde JSON de Firestore
  factory LoanModel.fromJson(Map<String, dynamic> json) {
    return LoanModel(
      id: json['id'] as String,
      workerId: json['workerId'] as String,
      farmId: json['farmId'] as String,
      date: (json['date'] as Timestamp).toDate(),
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      status: LoanStatusExtension.fromString(json['status'] as String),
      paymentDate: json['paymentDate'] != null
          ? (json['paymentDate'] as Timestamp).toDate()
          : null,
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
      'description': description,
      'status': status.name,
      if (paymentDate != null) 'paymentDate': Timestamp.fromDate(paymentDate!),
      if (notes != null) 'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  /// Crea una copia del modelo
  LoanModel copyWith({
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
    return LoanModel(
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






