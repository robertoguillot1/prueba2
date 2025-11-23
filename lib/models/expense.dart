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

  static List<String> getAll() {
    return ExpenseCategory.values.map((e) => e.displayName).toList();
  }

  static ExpenseCategory? fromString(String value) {
    return ExpenseCategory.values.firstWhere(
      (e) => e.displayName == value,
      orElse: () => ExpenseCategory.otros,
    );
  }
}

class Expense {
  final String id;
  final String farmId;
  final DateTime date;
  final double amount;
  final String description;
  final String category;
  final String? notes;

  Expense({
    required this.id,
    required this.farmId,
    required this.date,
    required this.amount,
    required this.description,
    required this.category,
    this.notes,
  });

  // Getters para compatibilidad
  DateTime get expenseDate => date;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmId': farmId,
      'date': date.toIso8601String(),
      'amount': amount,
      'description': description,
      'category': category,
      'notes': notes,
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      farmId: json['farmId'] as String,
      date: DateTime.parse(json['date'] as String),
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      category: json['category'] as String,
      notes: json['notes'] as String?,
    );
  }

  Expense copyWith({
    String? id,
    String? farmId,
    DateTime? date,
    double? amount,
    String? description,
    String? category,
    String? notes,
  }) {
    return Expense(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      category: category ?? this.category,
      notes: notes ?? this.notes,
    );
  }
}





