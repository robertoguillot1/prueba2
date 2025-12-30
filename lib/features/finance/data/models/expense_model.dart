import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/expense_entity.dart';

/// Modelo de datos para Gastos (capa de datos)
class ExpenseModel extends ExpenseEntity {
  const ExpenseModel({
    required super.id,
    required super.farmId,
    required super.date,
    required super.amount,
    required super.description,
    required super.category,
    super.notes,
    required super.createdAt,
    super.updatedAt,
  });

  /// Crea un ExpenseModel desde una entidad
  factory ExpenseModel.fromEntity(ExpenseEntity entity) {
    return ExpenseModel(
      id: entity.id,
      farmId: entity.farmId,
      date: entity.date,
      amount: entity.amount,
      description: entity.description,
      category: entity.category,
      notes: entity.notes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Crea un ExpenseModel desde JSON de Firestore
  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as String,
      farmId: json['farmId'] as String,
      date: (json['date'] as Timestamp).toDate(),
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      category: ExpenseCategoryExtension.fromString(json['category'] as String),
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
      'farmId': farmId,
      'date': Timestamp.fromDate(date),
      'amount': amount,
      'description': description,
      'category': category.displayName,
      if (notes != null) 'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  /// Crea una copia del modelo
  ExpenseModel copyWith({
    String? id,
    String? farmId,
    DateTime? date,
    double? amount,
    String? description,
    ExpenseCategory? category,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}








