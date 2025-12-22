import 'package:equatable/equatable.dart';

/// Categorías de gastos
enum ExpenseCategory {
  insumos,
  alimentacion,
  medicamentos,
  mantenimiento,
  servicios,
  otros,
}

extension ExpenseCategoryExtension on ExpenseCategory {
  String get displayName {
    switch (this) {
      case ExpenseCategory.insumos:
        return 'Insumos';
      case ExpenseCategory.alimentacion:
        return 'Alimentación';
      case ExpenseCategory.medicamentos:
        return 'Medicamentos';
      case ExpenseCategory.mantenimiento:
        return 'Mantenimiento';
      case ExpenseCategory.servicios:
        return 'Servicios';
      case ExpenseCategory.otros:
        return 'Otros';
    }
  }

  static ExpenseCategory fromString(String value) {
    return ExpenseCategory.values.firstWhere(
      (e) => e.displayName == value || e.name == value,
      orElse: () => ExpenseCategory.otros,
    );
  }
}

/// Entidad de dominio para Gastos
class ExpenseEntity extends Equatable {
  final String id;
  final String farmId;
  final DateTime date;
  final double amount;
  final String description;
  final ExpenseCategory category;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ExpenseEntity({
    required this.id,
    required this.farmId,
    required this.date,
    required this.amount,
    required this.description,
    required this.category,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        farmId,
        date,
        amount,
        description,
        category,
        notes,
        createdAt,
        updatedAt,
      ];

  ExpenseEntity copyWith({
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
    return ExpenseEntity(
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






