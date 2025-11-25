enum LoanStatus {
  pending,
  paid,
}

extension LoanStatusExtension on LoanStatus {
  String get displayName {
    switch (this) {
      case LoanStatus.pending:
        return 'Pendiente';
      case LoanStatus.paid:
        return 'Pagado';
    }
  }
}

class Loan {
  final String id;
  final String workerId;
  final String farmId;
  final DateTime date;
  final double amount;
  final String description;
  final LoanStatus status;
  final DateTime? paymentDate;
  final String? notes;

  Loan({
    required this.id,
    required this.workerId,
    required this.farmId,
    required this.date,
    required this.amount,
    required this.description,
    required this.status,
    this.paymentDate,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workerId': workerId,
      'farmId': farmId,
      'date': date.toIso8601String(),
      'amount': amount,
      'description': description,
      'status': status.name,
      'paymentDate': paymentDate?.toIso8601String(),
      'notes': notes,
    };
  }

  factory Loan.fromJson(Map<String, dynamic> json) {
    return Loan(
      id: json['id'] as String,
      workerId: json['workerId'] as String,
      farmId: json['farmId'] as String,
      date: DateTime.parse(json['date'] as String),
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      status: LoanStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => LoanStatus.pending,
      ),
      paymentDate: json['paymentDate'] != null
          ? DateTime.parse(json['paymentDate'] as String)
          : null,
      notes: json['notes'] as String?,
    );
  }

  // Getters para compatibilidad con código existente
  DateTime get loanDate => date;
  DateTime? get paidDate => paymentDate;

  // Getter para obtener el nombre de visualización del estado
  String get statusDisplayName => status.displayName;

  Loan copyWith({
    String? id,
    String? workerId,
    String? farmId,
    DateTime? date,
    double? amount,
    String? description,
    LoanStatus? status,
    DateTime? paymentDate,
    String? notes,
  }) {
    return Loan(
      id: id ?? this.id,
      workerId: workerId ?? this.workerId,
      farmId: farmId ?? this.farmId,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      status: status ?? this.status,
      paymentDate: paymentDate ?? this.paymentDate,
      notes: notes ?? this.notes,
    );
  }
}




