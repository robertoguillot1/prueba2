import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/reproductive_event_entity.dart';

/// Modelo de datos para ReproductiveEvent
/// Extiende ReproductiveEventEntity y agrega métodos de serialización para Firestore
class ReproductiveEventModel extends ReproductiveEventEntity {
  const ReproductiveEventModel({
    required String id,
    required String bovineId,
    required String farmId,
    required ReproductiveEventType type,
    required DateTime eventDate,
    required Map<String, dynamic> details,
    String? notes,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) : super(
          id: id,
          bovineId: bovineId,
          farmId: farmId,
          type: type,
          eventDate: eventDate,
          details: details,
          notes: notes,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  /// Crea un modelo desde JSON de Firestore
  factory ReproductiveEventModel.fromJson(Map<String, dynamic> json) {
    return ReproductiveEventModel(
      id: json['id'] as String,
      bovineId: json['bovineId'] as String,
      farmId: json['farmId'] as String,
      type: _parseEventType(json['type'] as String),
      eventDate: (json['eventDate'] as Timestamp).toDate(),
      details: json['details'] as Map<String, dynamic>? ?? {},
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Convierte el modelo a JSON para Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bovineId': bovineId,
      'farmId': farmId,
      'type': _eventTypeToString(type),
      'eventDate': Timestamp.fromDate(eventDate),
      'details': details,
      if (notes != null) 'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  /// Convierte una entidad a modelo
  factory ReproductiveEventModel.fromEntity(ReproductiveEventEntity entity) {
    return ReproductiveEventModel(
      id: entity.id,
      bovineId: entity.bovineId,
      farmId: entity.farmId,
      type: entity.type,
      eventDate: entity.eventDate,
      details: entity.details,
      notes: entity.notes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Crea una copia del modelo
  ReproductiveEventModel copyWith({
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
    return ReproductiveEventModel(
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

  /// Parsea el tipo de evento desde string
  static ReproductiveEventType _parseEventType(String value) {
    switch (value) {
      case 'heat':
        return ReproductiveEventType.heat;
      case 'insemination':
        return ReproductiveEventType.insemination;
      case 'palpation':
        return ReproductiveEventType.palpation;
      case 'calving':
        return ReproductiveEventType.calving;
      case 'abortion':
        return ReproductiveEventType.abortion;
      case 'drying':
        return ReproductiveEventType.drying;
      default:
        return ReproductiveEventType.heat;
    }
  }

  /// Convierte el tipo de evento a string
  static String _eventTypeToString(ReproductiveEventType type) {
    switch (type) {
      case ReproductiveEventType.heat:
        return 'heat';
      case ReproductiveEventType.insemination:
        return 'insemination';
      case ReproductiveEventType.palpation:
        return 'palpation';
      case ReproductiveEventType.calving:
        return 'calving';
      case ReproductiveEventType.abortion:
        return 'abortion';
      case ReproductiveEventType.drying:
        return 'drying';
    }
  }
}



