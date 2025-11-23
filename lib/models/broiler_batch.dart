import 'poultry_batch.dart';

enum BatchStatus {
  activo,
  cerrado,
}

enum EtapaAlimentacion {
  preinicio,
  inicio,
  engorde,
  finalizador,
}

extension BatchStatusExtension on BatchStatus {
  String get displayName {
    switch (this) {
      case BatchStatus.activo:
        return 'Activo';
      case BatchStatus.cerrado:
        return 'Cerrado/Vendido';
    }
  }

  static BatchStatus? fromString(String value) {
    switch (value) {
      case 'activo':
        return BatchStatus.activo;
      case 'cerrado':
        return BatchStatus.cerrado;
      default:
        return BatchStatus.activo;
    }
  }
}

class BroilerBatch extends PoultryBatch {
  final int cantidadInicial;
  final int cantidadActual;
  final int edadInicialDias;
  final double pesoPromedioActual; // En gramos
  final double metaPesoGramos; // Meta de peso en gramos (por defecto 3000g = 3kg)
  final int metaSacrificioDias;
  final double stockAlimentoKg;
  final double costoCompraLote;
  final BatchStatus estado;
  final DateTime? ultimaActualizacionStock; // Para rastrear cuándo se actualizó el stock por última vez

  BroilerBatch({
    required super.id,
    required super.farmId,
    required super.nombreLote,
    required super.fechaIngreso,
    required this.cantidadInicial,
    required this.cantidadActual,
    required this.edadInicialDias,
    required this.pesoPromedioActual,
    required this.metaPesoGramos,
    required this.metaSacrificioDias,
    required this.stockAlimentoKg,
    required this.costoCompraLote,
    this.estado = BatchStatus.activo,
    this.ultimaActualizacionStock,
    required super.createdAt,
    required super.updatedAt,
  });

  // Getter para determinar la etapa actual
  EtapaAlimentacion get etapaActual {
    final edad = edadActualDias;
    if (edad >= 2 && edad <= 11) return EtapaAlimentacion.preinicio;
    if (edad >= 12 && edad <= 21) return EtapaAlimentacion.inicio;
    if (edad >= 22 && edad <= 34) return EtapaAlimentacion.engorde;
    if (edad >= 35) return EtapaAlimentacion.finalizador;
    return EtapaAlimentacion.preinicio; // Por defecto
  }

  // Getter para obtener el nombre de la etapa
  String get etapaActualNombre {
    switch (etapaActual) {
      case EtapaAlimentacion.preinicio:
        return 'Preinicio';
      case EtapaAlimentacion.inicio:
        return 'Inicio';
      case EtapaAlimentacion.engorde:
        return 'Engorde';
      case EtapaAlimentacion.finalizador:
        return 'Finalizador';
    }
  }

  // Getter para obtener el tipo de alimento recomendado
  String get tipoAlimentoRecomendado {
    switch (etapaActual) {
      case EtapaAlimentacion.preinicio:
        return 'Alimento Preinicio';
      case EtapaAlimentacion.inicio:
        return 'Alimento Inicio';
      case EtapaAlimentacion.engorde:
        return 'Alimento Engorde';
      case EtapaAlimentacion.finalizador:
        return 'Alimento Finalizador';
    }
  }

  // Getter para calcular la edad actual
  int get edadActualDias {
    final hoy = DateTime.now();
    final diasTranscurridos = hoy.difference(fechaIngreso).inDays;
    return edadInicialDias + diasTranscurridos;
  }

  // Getter para calcular días restantes hasta sacrificio
  int get diasParaSacrificio {
    final diasRestantes = metaSacrificioDias - edadActualDias;
    return diasRestantes > 0 ? diasRestantes : 0;
  }

  // Getter para calcular porcentaje de progreso
  double get progresoPorcentaje {
    if (metaSacrificioDias == 0) return 0;
    final progreso = (edadActualDias / metaSacrificioDias) * 100;
    return progreso > 100 ? 100 : progreso;
  }

  // Tabla de consumo diario por etapa (en gramos por ave) - Basada en estándares
  static double _getConsumoDiarioPorEtapa(EtapaAlimentacion etapa) {
    switch (etapa) {
      case EtapaAlimentacion.preinicio:
        return 26.4; // Días 2-11
      case EtapaAlimentacion.inicio:
        return 62.7; // Días 12-21
      case EtapaAlimentacion.engorde:
        return 154.2; // Días 22-34
      case EtapaAlimentacion.finalizador:
        return 161.4; // Días 35-42
    }
  }

  // Tabla de consumo diario por día de vida (en gramos por ave) - Interpolación por etapa
  static double _getConsumoDiarioPorDia(int diaVida) {
    if (diaVida <= 0) return 0.0;
    if (diaVida == 1) return 12.0;
    
    // Determinar etapa
    EtapaAlimentacion etapa;
    if (diaVida >= 2 && diaVida <= 11) {
      etapa = EtapaAlimentacion.preinicio;
    } else if (diaVida >= 12 && diaVida <= 21) {
      etapa = EtapaAlimentacion.inicio;
    } else if (diaVida >= 22 && diaVida <= 34) {
      etapa = EtapaAlimentacion.engorde;
    } else {
      etapa = EtapaAlimentacion.finalizador;
    }
    
    // Usar consumo promedio de la etapa
    return _getConsumoDiarioPorEtapa(etapa);
  }

  // Getter para obtener consumo actual por ave en gramos (automático)
  double get consumoActualPorAveGramos {
    return _getConsumoDiarioPorDia(edadActualDias);
  }

  // Función para calcular consumo diario estimado (en kg)
  double get consumoDiarioEstimadoKg {
    // Usar tabla automática basada en días de vida
    final gramosPorAve = consumoActualPorAveGramos;
    return (cantidadActual * gramosPorAve) / 1000;
  }

  // Getter para calcular stock actualizado (disminuye automáticamente)
  double get stockAlimentoActualKg {
    if (ultimaActualizacionStock == null) return stockAlimentoKg;
    
    final hoy = DateTime.now();
    final diasTranscurridos = hoy.difference(ultimaActualizacionStock!).inDays;
    
    if (diasTranscurridos <= 0) return stockAlimentoKg;
    
    // Calcular consumo total desde la última actualización
    // Usar el consumo promedio de la etapa actual para simplificar
    final consumoPorAve = consumoActualPorAveGramos;
    final consumoDiarioKg = (cantidadActual * consumoPorAve) / 1000;
    final consumoTotal = consumoDiarioKg * diasTranscurridos;
    
    final nuevoStock = stockAlimentoKg - consumoTotal;
    return nuevoStock > 0 ? nuevoStock : 0.0;
  }

  // Calcular bultos necesarios para una etapa completa (40kg por bulto)
  double calcularBultosNecesariosEtapa(EtapaAlimentacion etapa) {
    int diasInicio, diasFin;
    switch (etapa) {
      case EtapaAlimentacion.preinicio:
        diasInicio = 2;
        diasFin = 11;
        break;
      case EtapaAlimentacion.inicio:
        diasInicio = 12;
        diasFin = 21;
        break;
      case EtapaAlimentacion.engorde:
        diasInicio = 22;
        diasFin = 34;
        break;
      case EtapaAlimentacion.finalizador:
        diasInicio = 35;
        diasFin = 42;
        break;
    }
    
    final consumoPorAve = _getConsumoDiarioPorEtapa(etapa);
    final diasEtapa = diasFin - diasInicio + 1;
    final consumoTotalKg = (cantidadActual * consumoPorAve * diasEtapa) / 1000;
    final bultosNecesarios = consumoTotalKg / 40.0; // 40kg por bulto
    
    return bultosNecesarios;
  }

  // Getter para obtener bultos necesarios en la etapa actual
  double get bultosNecesariosEtapaActual {
    return calcularBultosNecesariosEtapa(etapaActual);
  }

  // Getter para verificar si necesita comprar alimento
  bool get necesitaComprarAlimento {
    final diasReserva = 3;
    final alimentoNecesario = consumoDiarioEstimadoKg * diasReserva;
    return stockAlimentoKg < alimentoNecesario;
  }

  // Peso esperado según edad (tabla de referencia) - en gramos
  double get pesoEsperadoGramos {
    final semanas = (edadActualDias / 7).ceil();
    
    if (semanas <= 1) {
      return 150; // 0.15 kg = 150g
    } else if (semanas == 2) {
      return 350; // 0.35 kg = 350g
    } else if (semanas == 3) {
      return 650; // 0.65 kg = 650g
    } else if (semanas == 4) {
      return 1000; // 1.0 kg = 1000g
    } else if (semanas == 5) {
      return 1500; // 1.5 kg = 1500g
    } else {
      return 2200; // 2.2 kg = 2200g (Semana 6+)
    }
  }

  // Peso esperado en kg (para compatibilidad)
  double get pesoEsperadoKg => pesoEsperadoGramos / 1000;

  // Peso promedio actual en kg (para compatibilidad)
  double get pesoPromedioActualKg => pesoPromedioActual / 1000;

  // Meta de peso en kg (para compatibilidad)
  double get metaPesoKg => metaPesoGramos / 1000;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmId': farmId,
      'type': 'broiler',
      'nombreLote': nombreLote,
      'fechaIngreso': fechaIngreso.toIso8601String(),
      'cantidadInicial': cantidadInicial,
      'cantidadActual': cantidadActual,
      'edadInicialDias': edadInicialDias,
      'pesoPromedioActual': pesoPromedioActual,
      'metaPesoGramos': metaPesoGramos,
      'metaSacrificioDias': metaSacrificioDias,
      'stockAlimentoKg': stockAlimentoKg,
      'costoCompraLote': costoCompraLote,
      'estado': estado.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory BroilerBatch.fromJson(Map<String, dynamic> json) {
    return BroilerBatch(
      id: json['id'] as String,
      farmId: json['farmId'] as String,
      nombreLote: json['nombreLote'] as String,
      fechaIngreso: DateTime.parse(json['fechaIngreso'] as String),
      cantidadInicial: json['cantidadInicial'] as int,
      cantidadActual: json['cantidadActual'] as int,
      edadInicialDias: json['edadInicialDias'] as int,
      pesoPromedioActual: (json['pesoPromedioActual'] as num).toDouble(),
      metaPesoGramos: (json['metaPesoGramos'] as num?)?.toDouble() ?? 3000.0, // Por defecto 3kg = 3000g
      metaSacrificioDias: json['metaSacrificioDias'] as int,
      stockAlimentoKg: (json['stockAlimentoKg'] as num?)?.toDouble() ?? 0.0,
      costoCompraLote: (json['costoCompraLote'] as num?)?.toDouble() ?? 0.0,
      estado: BatchStatusExtension.fromString(json['estado'] as String? ?? 'activo') ?? BatchStatus.activo,
      ultimaActualizacionStock: json['ultimaActualizacionStock'] != null
          ? DateTime.parse(json['ultimaActualizacionStock'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  BroilerBatch copyWith({
    String? id,
    String? farmId,
    String? nombreLote,
    DateTime? fechaIngreso,
    int? cantidadInicial,
    int? cantidadActual,
    int? edadInicialDias,
    double? pesoPromedioActual,
    double? metaPesoGramos,
    int? metaSacrificioDias,
    double? stockAlimentoKg,
    double? costoCompraLote,
    BatchStatus? estado,
    DateTime? ultimaActualizacionStock,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BroilerBatch(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      nombreLote: nombreLote ?? this.nombreLote,
      fechaIngreso: fechaIngreso ?? this.fechaIngreso,
      cantidadInicial: cantidadInicial ?? this.cantidadInicial,
      cantidadActual: cantidadActual ?? this.cantidadActual,
      edadInicialDias: edadInicialDias ?? this.edadInicialDias,
      pesoPromedioActual: pesoPromedioActual ?? this.pesoPromedioActual,
      metaPesoGramos: metaPesoGramos ?? this.metaPesoGramos,
      metaSacrificioDias: metaSacrificioDias ?? this.metaSacrificioDias,
      stockAlimentoKg: stockAlimentoKg ?? this.stockAlimentoKg,
      costoCompraLote: costoCompraLote ?? this.costoCompraLote,
      estado: estado ?? this.estado,
      ultimaActualizacionStock: ultimaActualizacionStock ?? this.ultimaActualizacionStock,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

