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

  static PaymentType? fromString(String value) {
    switch (value) {
      case 'complete':
      case 'full':
        return PaymentType.full;
      case 'advance':
      case 'partial': // Compatibilidad con datos antiguos
        return PaymentType.advance;
      default:
        return PaymentType.values.firstWhere(
          (e) => e.value == value,
          orElse: () => PaymentType.full,
        );
    }
  }
}

class Payment {
  final String id;
  final String workerId;
  final String farmId;
  final DateTime date;
  final double amount;
  final String type; // 'complete', 'advance'
  final String? notes;

  Payment({
    required this.id,
    required this.workerId,
    required this.farmId,
    required this.date,
    required this.amount,
    required this.type,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workerId': workerId,
      'farmId': farmId,
      'date': date.toIso8601String(),
      'amount': amount,
      'type': type,
      'notes': notes,
    };
  }

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String,
      workerId: json['workerId'] as String,
      farmId: json['farmId'] as String,
      date: DateTime.parse(json['date'] as String),
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      notes: json['notes'] as String?,
    );
  }

  // Getters para compatibilidad con código existente
  DateTime get paymentDate => date;
  String? get observations => notes;
  
  // Getter para obtener el tipo como enum
  PaymentType get typeEnum => PaymentTypeExtension.fromString(type) ?? PaymentType.full;
  
  // Getter para obtener el nombre de visualización del tipo
  String get typeDisplayName => typeEnum.displayName;

  Payment copyWith({
    String? id,
    String? workerId,
    String? farmId,
    DateTime? date,
    double? amount,
    String? type,
    String? notes,
  }) {
    return Payment(
      id: id ?? this.id,
      workerId: workerId ?? this.workerId,
      farmId: farmId ?? this.farmId,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      notes: notes ?? this.notes,
    );
  }
}




