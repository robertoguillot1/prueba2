import '../../../domain/entities/bovinos/evento_reproductivo.dart';

/// Modelo de datos para Evento Reproductivo
class EventoReproductivoModel extends EventoReproductivo {
  const EventoReproductivoModel({
    required String id,
    required String farmId,
    required String idAnimal,
    required TipoEventoReproductivo tipo,
    required DateTime fecha,
    required Map<String, dynamic> detalles,
    String? notas,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super(
          id: id,
          farmId: farmId,
          idAnimal: idAnimal,
          tipo: tipo,
          fecha: fecha,
          detalles: detalles,
          notas: notas,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  /// Crea un modelo desde JSON
  factory EventoReproductivoModel.fromJson(Map<String, dynamic> json) {
    return EventoReproductivoModel(
      id: json['id'] as String,
      farmId: json['farmId'] as String,
      idAnimal: json['idAnimal'] as String,
      tipo: TipoEventoReproductivo.values.firstWhere(
        (e) => e.name == json['tipo'],
        orElse: () => TipoEventoReproductivo.celo,
      ),
      fecha: DateTime.parse(json['fecha'] as String),
      detalles: json['detalles'] as Map<String, dynamic>? ?? {},
      notas: json['notas'] as String?,
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
      'farmId': farmId,
      'idAnimal': idAnimal,
      'tipo': tipo.name,
      'fecha': fecha.toIso8601String(),
      'detalles': detalles,
      'notas': notas,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Crea una copia del modelo con campos modificados
  EventoReproductivoModel copyWith({
    String? id,
    String? farmId,
    String? idAnimal,
    TipoEventoReproductivo? tipo,
    DateTime? fecha,
    Map<String, dynamic>? detalles,
    String? notas,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EventoReproductivoModel(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      idAnimal: idAnimal ?? this.idAnimal,
      tipo: tipo ?? this.tipo,
      fecha: fecha ?? this.fecha,
      detalles: detalles ?? this.detalles,
      notas: notas ?? this.notas,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convierte la entidad a modelo
  factory EventoReproductivoModel.fromEntity(EventoReproductivo entity) {
    return EventoReproductivoModel(
      id: entity.id,
      farmId: entity.farmId,
      idAnimal: entity.idAnimal,
      tipo: entity.tipo,
      fecha: entity.fecha,
      detalles: entity.detalles,
      notas: entity.notas,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

