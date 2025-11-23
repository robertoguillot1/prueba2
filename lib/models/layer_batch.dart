import 'poultry_batch.dart';
import 'layer_production_record.dart';

class LayerBatch extends PoultryBatch {
  final DateTime fechaNacimiento;
  final int cantidadGallinas;
  final double? precioPorCarton; // Precio configurado actual

  LayerBatch({
    required super.id,
    required super.farmId,
    required super.nombreLote,
    required super.fechaIngreso,
    required this.fechaNacimiento,
    required this.cantidadGallinas,
    this.precioPorCarton,
    required super.createdAt,
    required super.updatedAt,
  });

  // Getter para calcular semanas de vida
  int get semanasVida {
    final hoy = DateTime.now();
    final diferencia = hoy.difference(fechaNacimiento).inDays;
    return (diferencia / 7).floor();
  }

  // Getter para verificar si está en pico de producción (18-30 semanas)
  bool get estaEnPicoProduccion {
    return semanasVida >= 18 && semanasVida <= 30;
  }

  // Getter para verificar si debe descartarse (> 100 semanas)
  bool get debeDescartarse {
    return semanasVida > 100;
  }

  // Función para calcular porcentaje de postura basado en registros
  double calcularPorcentajePostura(List<LayerProductionRecord> registros) {
    if (cantidadGallinas == 0 || registros.isEmpty) return 0.0;
    
    // Calcular promedio de los últimos 7 días
    final hoy = DateTime.now();
    final ultimos7Dias = registros.where((r) {
      final diferencia = hoy.difference(r.fecha).inDays;
      return diferencia <= 7;
    }).toList();

    if (ultimos7Dias.isEmpty) return 0.0;

    final promedioHuevos = ultimos7Dias
        .map((r) => r.cantidadHuevos)
        .reduce((a, b) => a + b) /
        ultimos7Dias.length;

    return (promedioHuevos / cantidadGallinas) * 100;
  }

  // Getter para obtener el estado de producción (color/indicador)
  String getEstadoProduccion(List<LayerProductionRecord> registros) {
    final porcentaje = calcularPorcentajePostura(registros);
    if (porcentaje >= 90) {
      return 'Excelente';
    } else if (porcentaje >= 70) {
      return 'Bueno';
    } else {
      return 'Alerta';
    }
  }

  // Getter para obtener el color según el estado
  int getColorEstado(List<LayerProductionRecord> registros) {
    final porcentaje = calcularPorcentajePostura(registros);
    if (porcentaje >= 90) {
      return 0xFF4CAF50; // Verde
    } else if (porcentaje >= 70) {
      return 0xFFFFC107; // Amarillo
    } else {
      return 0xFFF44336; // Rojo
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmId': farmId,
      'type': 'layer',
      'nombreLote': nombreLote,
      'fechaIngreso': fechaIngreso.toIso8601String(),
      'fechaNacimiento': fechaNacimiento.toIso8601String(),
      'cantidadGallinas': cantidadGallinas,
      'precioPorCarton': precioPorCarton,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory LayerBatch.fromJson(Map<String, dynamic> json) {
    return LayerBatch(
      id: json['id'] as String,
      farmId: json['farmId'] as String,
      nombreLote: json['nombreLote'] as String,
      fechaIngreso: DateTime.parse(json['fechaIngreso'] as String),
      fechaNacimiento: DateTime.parse(json['fechaNacimiento'] as String),
      cantidadGallinas: json['cantidadGallinas'] as int,
      precioPorCarton: json['precioPorCarton'] != null
          ? (json['precioPorCarton'] as num).toDouble()
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  LayerBatch copyWith({
    String? id,
    String? farmId,
    String? nombreLote,
    DateTime? fechaIngreso,
    DateTime? fechaNacimiento,
    int? cantidadGallinas,
    double? precioPorCarton,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LayerBatch(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      nombreLote: nombreLote ?? this.nombreLote,
      fechaIngreso: fechaIngreso ?? this.fechaIngreso,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      cantidadGallinas: cantidadGallinas ?? this.cantidadGallinas,
      precioPorCarton: precioPorCarton ?? this.precioPorCarton,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

