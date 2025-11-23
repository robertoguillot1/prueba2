/// Entidad de dominio para Evento Reproductivo
class EventoReproductivo {
  final String id;
  final String farmId;
  final String idAnimal; // ID de la hembra
  final TipoEventoReproductivo tipo;
  final DateTime fecha;
  final Map<String, dynamic> detalles;
  final String? notas;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const EventoReproductivo({
    required this.id,
    required this.farmId,
    required this.idAnimal,
    required this.tipo,
    required this.fecha,
    required this.detalles,
    this.notas,
    this.createdAt,
    this.updatedAt,
  });

  /// Valida que la entidad sea válida
  bool get isValid {
    if (id.isEmpty || farmId.isEmpty || idAnimal.isEmpty) return false;
    if (fecha.isAfter(DateTime.now().add(const Duration(days: 1)))) return false;
    return true;
  }

  /// Obtiene el ID del toro si está en los detalles
  String? get idToro => detalles['idToro'] as String?;

  /// Obtiene el código de pajilla si está en los detalles
  String? get codigoPajilla => detalles['codigoPajilla'] as String?;

  /// Obtiene el resultado de palpación si está en los detalles
  String? get resultadoPalpacion => detalles['resultadoPalpacion'] as String?;

  /// Obtiene si nació cría en un parto
  bool? get nacioCria => detalles['nacioCria'] as bool?;

  /// Obtiene el ID de la cría creada si existe
  String? get idCriaCreada => detalles['idCriaCreada'] as String?;
}

/// Tipos de eventos reproductivos
enum TipoEventoReproductivo {
  celo,
  montaInseminacion,
  palpacionTacto,
  parto,
  aborto,
  secado,
}

/// Extensión para obtener el nombre en español
extension TipoEventoReproductivoExtension on TipoEventoReproductivo {
  String get displayName {
    switch (this) {
      case TipoEventoReproductivo.celo:
        return 'Celo';
      case TipoEventoReproductivo.montaInseminacion:
        return 'Monta/Inseminación';
      case TipoEventoReproductivo.palpacionTacto:
        return 'Palpación/Tacto';
      case TipoEventoReproductivo.parto:
        return 'Parto';
      case TipoEventoReproductivo.aborto:
        return 'Aborto';
      case TipoEventoReproductivo.secado:
        return 'Secado';
    }
  }

  /// Obtiene el icono asociado
  String get iconName {
    switch (this) {
      case TipoEventoReproductivo.celo:
        return 'favorite';
      case TipoEventoReproductivo.montaInseminacion:
        return 'pets';
      case TipoEventoReproductivo.palpacionTacto:
        return 'medical_services';
      case TipoEventoReproductivo.parto:
        return 'child_care';
      case TipoEventoReproductivo.aborto:
        return 'cancel';
      case TipoEventoReproductivo.secado:
        return 'water_drop';
    }
  }
}

