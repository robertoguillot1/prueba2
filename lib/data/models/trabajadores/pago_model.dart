import '../../../domain/entities/trabajadores/pago.dart';

/// Modelo de datos para Pago
class PagoModel extends Pago {
  const PagoModel({
    required super.id,
    required super.trabajadorId,
    required super.farmId,
    required super.date,
    required super.amount,
    required super.tipoPago,
    super.concepto,
    super.observaciones,
    super.createdAt,
    super.updatedAt,
  });

  /// Crea un modelo desde JSON
  factory PagoModel.fromJson(Map<String, dynamic> json) {
    return PagoModel(
      id: json['id'] as String,
      trabajadorId: json['trabajadorId'] as String,
      farmId: json['farmId'] as String,
      date: DateTime.parse(json['date'] as String),
      amount: (json['amount'] as num).toDouble(),
      tipoPago: TipoPago.values.firstWhere(
        (e) => e.name == json['tipoPago'],
        orElse: () => TipoPago.salario,
      ),
      concepto: json['concepto'] as String?,
      observaciones: json['observaciones'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Convierte el modelo a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trabajadorId': trabajadorId,
      'farmId': farmId,
      'date': date.toIso8601String(),
      'amount': amount,
      'tipoPago': tipoPago.name,
      'concepto': concepto,
      'observaciones': observaciones,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Crea una copia del modelo con campos modificados
  PagoModel copyWith({
    String? id,
    String? trabajadorId,
    String? farmId,
    DateTime? date,
    double? amount,
    TipoPago? tipoPago,
    String? concepto,
    String? observaciones,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PagoModel(
      id: id ?? this.id,
      trabajadorId: trabajadorId ?? this.trabajadorId,
      farmId: farmId ?? this.farmId,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      tipoPago: tipoPago ?? this.tipoPago,
      concepto: concepto ?? this.concepto,
      observaciones: observaciones ?? this.observaciones,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convierte la entidad a modelo
  factory PagoModel.fromEntity(Pago entity) {
    return PagoModel(
      id: entity.id,
      trabajadorId: entity.trabajadorId,
      farmId: entity.farmId,
      date: entity.date,
      amount: entity.amount,
      tipoPago: entity.tipoPago,
      concepto: entity.concepto,
      observaciones: entity.observaciones,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

