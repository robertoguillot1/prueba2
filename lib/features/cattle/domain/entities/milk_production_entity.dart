import 'package:equatable/equatable.dart';

/// Entidad de dominio para Producción de Leche
class MilkProductionEntity extends Equatable {
  final String id;
  final String bovineId; // ID del bovino
  final String farmId;
  final DateTime recordDate; // Fecha del registro
  final double litersProduced; // Litros producidos
  final String? notes; // Notas adicionales
  final DateTime createdAt;
  final DateTime? updatedAt;

  const MilkProductionEntity({
    required this.id,
    required this.bovineId,
    required this.farmId,
    required this.recordDate,
    required this.litersProduced,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  /// Crea una copia de la entidad con los valores actualizados
  MilkProductionEntity copyWith({
    String? id,
    String? bovineId,
    String? farmId,
    DateTime? recordDate,
    double? litersProduced,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MilkProductionEntity(
      id: id ?? this.id,
      bovineId: bovineId ?? this.bovineId,
      farmId: farmId ?? this.farmId,
      recordDate: recordDate ?? this.recordDate,
      litersProduced: litersProduced ?? this.litersProduced,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Valida que la entidad sea válida
  /// Nota: No validamos el ID porque se genera automáticamente en Firestore
  bool get isValid {
    return bovineId.isNotEmpty &&
        farmId.isNotEmpty &&
        litersProduced >= 0 &&
        recordDate.isBefore(DateTime.now().add(const Duration(days: 1)));
  }

  @override
  List<Object?> get props => [
        id,
        bovineId,
        farmId,
        recordDate,
        litersProduced,
        notes,
        createdAt,
        updatedAt,
      ];
}

