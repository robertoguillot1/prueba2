class FoodPurchase {
  final String id;
  final String farmId;
  final DateTime date;
  final double amount;
  final double quantity;
  final String unit;
  final String? supplier;
  final String? notes;

  FoodPurchase({
    required this.id,
    required this.farmId,
    required this.date,
    required this.amount,
    required this.quantity,
    required this.unit,
    this.supplier,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmId': farmId,
      'date': date.toIso8601String(),
      'amount': amount,
      'quantity': quantity,
      'unit': unit,
      'supplier': supplier,
      'notes': notes,
    };
  }

  factory FoodPurchase.fromJson(Map<String, dynamic> json) {
    return FoodPurchase(
      id: json['id'] as String,
      farmId: json['farmId'] as String,
      date: DateTime.parse(json['date'] as String),
      amount: (json['amount'] as num).toDouble(),
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      supplier: json['supplier'] as String?,
      notes: json['notes'] as String?,
    );
  }

  // Getters para compatibilidad con código existente
  DateTime get purchaseDate => date;
  double get totalCost => amount;
  String get foodType => unit; // Usando unit como tipo de alimento
}





