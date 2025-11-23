import 'package:flutter/material.dart';

enum BatchExpenseType {
  alimento,
  medicina,
  vacunas,
  insumos,
  manoObra,
  otros,
}

extension BatchExpenseTypeExtension on BatchExpenseType {
  String get displayName {
    switch (this) {
      case BatchExpenseType.alimento:
        return 'Alimento';
      case BatchExpenseType.medicina:
        return 'Medicina';
      case BatchExpenseType.vacunas:
        return 'Vacunas';
      case BatchExpenseType.insumos:
        return 'Insumos';
      case BatchExpenseType.manoObra:
        return 'Mano de Obra';
      case BatchExpenseType.otros:
        return 'Otros';
    }
  }

  IconData get icon {
    switch (this) {
      case BatchExpenseType.alimento:
        return Icons.restaurant;
      case BatchExpenseType.medicina:
        return Icons.medical_services;
      case BatchExpenseType.vacunas:
        return Icons.vaccines;
      case BatchExpenseType.insumos:
        return Icons.inventory_2;
      case BatchExpenseType.manoObra:
        return Icons.people;
      case BatchExpenseType.otros:
        return Icons.more_horiz;
    }
  }

  Color get color {
    switch (this) {
      case BatchExpenseType.alimento:
        return Colors.orange;
      case BatchExpenseType.medicina:
        return Colors.red;
      case BatchExpenseType.vacunas:
        return Colors.blue;
      case BatchExpenseType.insumos:
        return Colors.purple;
      case BatchExpenseType.manoObra:
        return Colors.green;
      case BatchExpenseType.otros:
        return Colors.grey;
    }
  }

  static BatchExpenseType? fromString(String value) {
    switch (value) {
      case 'alimento':
        return BatchExpenseType.alimento;
      case 'medicina':
        return BatchExpenseType.medicina;
      case 'vacunas':
        return BatchExpenseType.vacunas;
      case 'insumos':
        return BatchExpenseType.insumos;
      case 'manoObra':
        return BatchExpenseType.manoObra;
      case 'otros':
        return BatchExpenseType.otros;
      default:
        return BatchExpenseType.otros;
    }
  }
}

class BatchExpense {
  final String id;
  final String batchId;
  final String farmId;
  final BatchExpenseType tipo;
  final DateTime fecha;
  final String concepto; // Cambiado de descripcion a concepto
  final double monto; // Cambiado de costoTotal a monto
  final double? cantidad; // Opcional, solo para alimento
  final double? stockAgregadoKg; // Para actualizar inventario cuando es alimento
  final DateTime createdAt;
  final DateTime updatedAt;

  BatchExpense({
    required this.id,
    required this.batchId,
    required this.farmId,
    required this.tipo,
    required this.fecha,
    required this.concepto,
    required this.monto,
    this.cantidad,
    this.stockAgregadoKg,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'batchId': batchId,
      'farmId': farmId,
      'tipo': tipo.name,
      'fecha': fecha.toIso8601String(),
      'concepto': concepto,
      'monto': monto,
      'cantidad': cantidad,
      'stockAgregadoKg': stockAgregadoKg,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory BatchExpense.fromJson(Map<String, dynamic> json) {
    return BatchExpense(
      id: json['id'] as String,
      batchId: json['batchId'] as String,
      farmId: json['farmId'] as String,
      tipo: BatchExpenseTypeExtension.fromString(json['tipo'] as String) ?? BatchExpenseType.otros,
      fecha: DateTime.parse(json['fecha'] as String),
      concepto: json['concepto'] as String? ?? json['descripcion'] as String? ?? '', // Compatibilidad con datos antiguos
      monto: (json['monto'] as num?)?.toDouble() ?? (json['costoTotal'] as num).toDouble(), // Compatibilidad
      cantidad: json['cantidad'] != null ? (json['cantidad'] as num).toDouble() : null,
      stockAgregadoKg: json['stockAgregadoKg'] != null ? (json['stockAgregadoKg'] as num).toDouble() : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  BatchExpense copyWith({
    String? id,
    String? batchId,
    String? farmId,
    BatchExpenseType? tipo,
    DateTime? fecha,
    String? concepto,
    double? monto,
    double? cantidad,
    double? stockAgregadoKg,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BatchExpense(
      id: id ?? this.id,
      batchId: batchId ?? this.batchId,
      farmId: farmId ?? this.farmId,
      tipo: tipo ?? this.tipo,
      fecha: fecha ?? this.fecha,
      concepto: concepto ?? this.concepto,
      monto: monto ?? this.monto,
      cantidad: cantidad ?? this.cantidad,
      stockAgregadoKg: stockAgregadoKg ?? this.stockAgregadoKg,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

