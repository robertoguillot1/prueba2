import 'package:equatable/equatable.dart';

/// Entidad de dominio para Vacuna/Tratamiento de Bovino
class VacunaBovinoEntity extends Equatable {
  final String id;
  final String bovinoId; // ID del bovino al que pertenece
  final String farmId; // ID de la finca
  final DateTime fechaAplicacion; // Fecha en que se aplicó
  final String nombreVacuna; // Nombre de la vacuna o tratamiento
  final String? lote; // Número de lote (opcional)
  final DateTime? proximaDosis; // Fecha de próximo refuerzo (opcional)
  final String? notas; // Observaciones adicionales
  final DateTime createdAt;
  final DateTime? updatedAt;

  const VacunaBovinoEntity({
    required this.id,
    required this.bovinoId,
    required this.farmId,
    required this.fechaAplicacion,
    required this.nombreVacuna,
    this.lote,
    this.proximaDosis,
    this.notas,
    required this.createdAt,
    this.updatedAt,
  });

  /// Verifica si la vacuna requiere un refuerzo próximo
  bool get requiereRefuerzo {
    if (proximaDosis == null) return false;
    final now = DateTime.now();
    return proximaDosis!.isAfter(now);
  }

  /// Días hasta el próximo refuerzo (negativo si ya pasó)
  int? get diasHastaRefuerzo {
    if (proximaDosis == null) return null;
    final now = DateTime.now();
    return proximaDosis!.difference(now).inDays;
  }

  /// Verifica si el refuerzo está atrasado
  bool get refuerzoAtrasado {
    if (proximaDosis == null) return false;
    return proximaDosis!.isBefore(DateTime.now());
  }

  /// Crea una copia de la entidad con los valores actualizados
  VacunaBovinoEntity copyWith({
    String? id,
    String? bovinoId,
    String? farmId,
    DateTime? fechaAplicacion,
    String? nombreVacuna,
    String? lote,
    DateTime? proximaDosis,
    String? notas,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VacunaBovinoEntity(
      id: id ?? this.id,
      bovinoId: bovinoId ?? this.bovinoId,
      farmId: farmId ?? this.farmId,
      fechaAplicacion: fechaAplicacion ?? this.fechaAplicacion,
      nombreVacuna: nombreVacuna ?? this.nombreVacuna,
      lote: lote ?? this.lote,
      proximaDosis: proximaDosis ?? this.proximaDosis,
      notas: notas ?? this.notas,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Valida que la entidad sea válida
  /// Nota: No validamos el ID porque se genera automáticamente en Firestore
  bool get isValid {
    return bovinoId.isNotEmpty &&
        farmId.isNotEmpty &&
        nombreVacuna.trim().isNotEmpty &&
        fechaAplicacion.isBefore(DateTime.now().add(const Duration(days: 1)));
  }

  @override
  List<Object?> get props => [
        id,
        bovinoId,
        farmId,
        fechaAplicacion,
        nombreVacuna,
        lote,
        proximaDosis,
        notas,
        createdAt,
        updatedAt,
      ];
}



