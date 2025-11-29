import 'package:equatable/equatable.dart';

/// Entidad de dominio para Evento Reproductivo
class ReproductiveEventEntity extends Equatable {
  final String id;
  final String bovineId; // ID del bovino (hembra)
  final String farmId;
  final ReproductiveEventType type;
  final DateTime eventDate;
  final Map<String, dynamic> details; // Detalles específicos del evento
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ReproductiveEventEntity({
    required this.id,
    required this.bovineId,
    required this.farmId,
    required this.type,
    required this.eventDate,
    required this.details,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  /// Obtiene el ID del toro si está en los detalles
  String? get fatherId => details['fatherId'] as String?;

  /// Obtiene el código de pajilla si está en los detalles
  String? get semenCode => details['semenCode'] as String?;

  /// Obtiene el resultado de palpación si está en los detalles
  String? get palpationResult => details['palpationResult'] as String?;

  /// Obtiene si nació cría en un parto
  bool? get calfBorn => details['calfBorn'] as bool?;

  /// Obtiene el ID de la cría creada si existe
  String? get calfId => details['calfId'] as String?;

  /// Obtiene el género de la cría si existe
  String? get calfGender => details['calfGender'] as String?;

  /// Obtiene el peso de la cría si existe
  double? get calfWeight => details['calfWeight'] != null 
      ? (details['calfWeight'] as num).toDouble() 
      : null;

  /// Crea una copia de la entidad con los valores actualizados
  ReproductiveEventEntity copyWith({
    String? id,
    String? bovineId,
    String? farmId,
    ReproductiveEventType? type,
    DateTime? eventDate,
    Map<String, dynamic>? details,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReproductiveEventEntity(
      id: id ?? this.id,
      bovineId: bovineId ?? this.bovineId,
      farmId: farmId ?? this.farmId,
      type: type ?? this.type,
      eventDate: eventDate ?? this.eventDate,
      details: details ?? this.details,
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
        eventDate.isBefore(DateTime.now().add(const Duration(days: 1)));
  }

  @override
  List<Object?> get props => [
        id,
        bovineId,
        farmId,
        type,
        eventDate,
        details,
        notes,
        createdAt,
        updatedAt,
      ];
}

/// Tipos de eventos reproductivos
enum ReproductiveEventType {
  heat, // Celo
  insemination, // Monta/Inseminación
  palpation, // Palpación/Tacto
  calving, // Parto
  abortion, // Aborto
  drying, // Secado
}

/// Extensión para obtener propiedades visuales
extension ReproductiveEventTypeExtension on ReproductiveEventType {
  String get displayName {
    switch (this) {
      case ReproductiveEventType.heat:
        return 'Celo';
      case ReproductiveEventType.insemination:
        return 'Monta/Inseminación';
      case ReproductiveEventType.palpation:
        return 'Palpación/Tacto';
      case ReproductiveEventType.calving:
        return 'Parto';
      case ReproductiveEventType.abortion:
        return 'Aborto';
      case ReproductiveEventType.drying:
        return 'Secado';
    }
  }

  /// Obtiene el nombre del icono de Material Icons
  String get iconName {
    switch (this) {
      case ReproductiveEventType.heat:
        return 'favorite';
      case ReproductiveEventType.insemination:
        return 'pets';
      case ReproductiveEventType.palpation:
        return 'medical_services';
      case ReproductiveEventType.calving:
        return 'child_care';
      case ReproductiveEventType.abortion:
        return 'cancel';
      case ReproductiveEventType.drying:
        return 'water_drop';
    }
  }

  /// Obtiene el color asociado al tipo de evento
  String get colorName {
    switch (this) {
      case ReproductiveEventType.heat:
        return 'pink';
      case ReproductiveEventType.insemination:
        return 'blue';
      case ReproductiveEventType.palpation:
        return 'purple';
      case ReproductiveEventType.calving:
        return 'green';
      case ReproductiveEventType.abortion:
        return 'red';
      case ReproductiveEventType.drying:
        return 'orange';
    }
  }
}

