class LayerProductionRecord {
  final String id;
  final String layerBatchId;
  final String farmId;
  final DateTime fecha;
  final int cantidadHuevos;
  final int cantidadHuevosRotos;
  final double alimentoConsumidoKg;
  final double? precioPorCarton; // Precio configurado para ese día
  final String? observaciones;

  LayerProductionRecord({
    required this.id,
    required this.layerBatchId,
    required this.farmId,
    required this.fecha,
    required this.cantidadHuevos,
    required this.cantidadHuevosRotos,
    required this.alimentoConsumidoKg,
    this.precioPorCarton,
    this.observaciones,
  });

  // Getter para calcular cartones (30 huevos por cartón)
  int get cartones {
    return cantidadHuevos ~/ 30;
  }

  // Getter para calcular huevos sueltos
  int get huevosSueltos {
    return cantidadHuevos % 30;
  }

  // Getter para calcular ganancia estimada del día
  double get gananciaEstimada {
    if (precioPorCarton == null) return 0.0;
    return cartones * precioPorCarton!;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'layerBatchId': layerBatchId,
      'farmId': farmId,
      'fecha': fecha.toIso8601String(),
      'cantidadHuevos': cantidadHuevos,
      'cantidadHuevosRotos': cantidadHuevosRotos,
      'alimentoConsumidoKg': alimentoConsumidoKg,
      'precioPorCarton': precioPorCarton,
      'observaciones': observaciones,
    };
  }

  factory LayerProductionRecord.fromJson(Map<String, dynamic> json) {
    return LayerProductionRecord(
      id: json['id'] as String,
      layerBatchId: json['layerBatchId'] as String,
      farmId: json['farmId'] as String,
      fecha: DateTime.parse(json['fecha'] as String),
      cantidadHuevos: json['cantidadHuevos'] as int,
      cantidadHuevosRotos: json['cantidadHuevosRotos'] as int,
      alimentoConsumidoKg: (json['alimentoConsumidoKg'] as num).toDouble(),
      precioPorCarton: json['precioPorCarton'] != null
          ? (json['precioPorCarton'] as num).toDouble()
          : null,
      observaciones: json['observaciones'] as String?,
    );
  }

  LayerProductionRecord copyWith({
    String? id,
    String? layerBatchId,
    String? farmId,
    DateTime? fecha,
    int? cantidadHuevos,
    int? cantidadHuevosRotos,
    double? alimentoConsumidoKg,
    double? precioPorCarton,
    String? observaciones,
  }) {
    return LayerProductionRecord(
      id: id ?? this.id,
      layerBatchId: layerBatchId ?? this.layerBatchId,
      farmId: farmId ?? this.farmId,
      fecha: fecha ?? this.fecha,
      cantidadHuevos: cantidadHuevos ?? this.cantidadHuevos,
      cantidadHuevosRotos: cantidadHuevosRotos ?? this.cantidadHuevosRotos,
      alimentoConsumidoKg: alimentoConsumidoKg ?? this.alimentoConsumidoKg,
      precioPorCarton: precioPorCarton ?? this.precioPorCarton,
      observaciones: observaciones ?? this.observaciones,
    );
  }
}

