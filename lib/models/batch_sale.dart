class BatchSale {
  final String id;
  final String batchId;
  final String farmId;
  final double pesoTotalVendido; // En kg
  final double precioPorKilo;
  final int cantidadPollosVendidos;
  final DateTime fechaVenta;
  final String? observaciones;
  final DateTime createdAt;
  final DateTime updatedAt;

  BatchSale({
    required this.id,
    required this.batchId,
    required this.farmId,
    required this.pesoTotalVendido,
    required this.precioPorKilo,
    required this.cantidadPollosVendidos,
    required this.fechaVenta,
    this.observaciones,
    required this.createdAt,
    required this.updatedAt,
  });

  // Getter para calcular el total de venta
  double get totalVenta => pesoTotalVendido * precioPorKilo;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'batchId': batchId,
      'farmId': farmId,
      'pesoTotalVendido': pesoTotalVendido,
      'precioPorKilo': precioPorKilo,
      'cantidadPollosVendidos': cantidadPollosVendidos,
      'fechaVenta': fechaVenta.toIso8601String(),
      'observaciones': observaciones,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory BatchSale.fromJson(Map<String, dynamic> json) {
    return BatchSale(
      id: json['id'] as String,
      batchId: json['batchId'] as String,
      farmId: json['farmId'] as String,
      pesoTotalVendido: (json['pesoTotalVendido'] as num).toDouble(),
      precioPorKilo: (json['precioPorKilo'] as num).toDouble(),
      cantidadPollosVendidos: json['cantidadPollosVendidos'] as int,
      fechaVenta: DateTime.parse(json['fechaVenta'] as String),
      observaciones: json['observaciones'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  BatchSale copyWith({
    String? id,
    String? batchId,
    String? farmId,
    double? pesoTotalVendido,
    double? precioPorKilo,
    int? cantidadPollosVendidos,
    DateTime? fechaVenta,
    String? observaciones,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BatchSale(
      id: id ?? this.id,
      batchId: batchId ?? this.batchId,
      farmId: farmId ?? this.farmId,
      pesoTotalVendido: pesoTotalVendido ?? this.pesoTotalVendido,
      precioPorKilo: precioPorKilo ?? this.precioPorKilo,
      cantidadPollosVendidos: cantidadPollosVendidos ?? this.cantidadPollosVendidos,
      fechaVenta: fechaVenta ?? this.fechaVenta,
      observaciones: observaciones ?? this.observaciones,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

