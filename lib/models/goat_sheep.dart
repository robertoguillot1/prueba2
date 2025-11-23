enum GoatSheepType {
  chivo,
  oveja,
}

enum GoatSheepGender {
  male,
  female,
}

enum EstadoReproductivo {
  vacia,
  gestante,
  lactante,
}

// Helper para parsear tipos antiguos
GoatSheepType _parseGoatSheepType(String value) {
  switch (value) {
    case 'ovino':
      return GoatSheepType.oveja;
    case 'caprino':
      return GoatSheepType.chivo;
    case 'chivo':
      return GoatSheepType.chivo;
    case 'oveja':
      return GoatSheepType.oveja;
    default:
      return GoatSheepType.values.firstWhere(
        (e) => e.name == value,
        orElse: () => GoatSheepType.oveja,
      );
  }
}

class GoatSheep {
  final String id;
  final String farmId;
  final GoatSheepType type;
  final GoatSheepGender gender;
  final String? identification;
  final String? name;
  final DateTime birthDate;
  final double? currentWeight;
  final EstadoReproductivo? estadoReproductivo;
  final DateTime? fechaMonta;
  final DateTime? fechaProbableParto;
  final int? partosPrevios;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  GoatSheep({
    required this.id,
    required this.farmId,
    required this.type,
    required this.gender,
    this.identification,
    this.name,
    required this.birthDate,
    this.currentWeight,
    this.estadoReproductivo,
    this.fechaMonta,
    this.fechaProbableParto,
    this.partosPrevios,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  String get typeString {
    switch (type) {
      case GoatSheepType.chivo:
        return 'Chivo';
      case GoatSheepType.oveja:
        return 'Oveja';
    }
  }

  String get genderString {
    switch (gender) {
      case GoatSheepGender.male:
        return 'Macho';
      case GoatSheepGender.female:
        return 'Hembra';
    }
  }

  String get estadoReproductivoString {
    if (estadoReproductivo == null) return 'N/A';
    switch (estadoReproductivo!) {
      case EstadoReproductivo.vacia:
        return 'Vacía';
      case EstadoReproductivo.gestante:
        return 'Gestante';
      case EstadoReproductivo.lactante:
        return 'Lactante';
    }
  }

  // Calcular días restantes hasta el parto
  int? get diasRestantesParto {
    if (fechaProbableParto == null) return null;
    final now = DateTime.now();
    return fechaProbableParto!.difference(now).inDays;
  }

  // Indica si está cerca del parto (menos de 10 días)
  bool get isNearParto {
    final dias = diasRestantesParto;
    return dias != null && dias >= 0 && dias <= 10;
  }

  // Indica si ya pasó la fecha probable de parto
  bool get isPastParto {
    if (fechaProbableParto == null) return false;
    final now = DateTime.now();
    return fechaProbableParto!.isBefore(now);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmId': farmId,
      'type': type.name,
      'gender': gender.name,
      'identification': identification,
      'name': name,
      'birthDate': birthDate.toIso8601String(),
      'currentWeight': currentWeight,
      'estadoReproductivo': estadoReproductivo?.name,
      'fechaMonta': fechaMonta?.toIso8601String(),
      'fechaProbableParto': fechaProbableParto?.toIso8601String(),
      'partosPrevios': partosPrevios,
      'notes': notes,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory GoatSheep.fromJson(Map<String, dynamic> json) {
    return GoatSheep(
      id: json['id'] as String,
      farmId: json['farmId'] as String,
      type: _parseGoatSheepType(json['type'] as String),
      gender: GoatSheepGender.values.firstWhere(
        (e) => e.name == json['gender'],
        orElse: () => GoatSheepGender.female,
      ),
      identification: json['identification'] as String?,
      name: json['name'] as String?,
      birthDate: DateTime.parse(json['birthDate'] as String),
      currentWeight: json['currentWeight'] != null
          ? (json['currentWeight'] as num).toDouble()
          : null,
      estadoReproductivo: json['estadoReproductivo'] != null
          ? (() {
              final value = json['estadoReproductivo'] as String;
              // Compatibilidad con datos antiguos que puedan tener "seca"
              if (value == 'seca') {
                return EstadoReproductivo.vacia;
              }
              return EstadoReproductivo.values.firstWhere(
                (e) => e.name == value,
                orElse: () => EstadoReproductivo.vacia,
              );
            })()
          : null,
      fechaMonta: json['fechaMonta'] != null
          ? DateTime.parse(json['fechaMonta'] as String)
          : null,
      fechaProbableParto: json['fechaProbableParto'] != null
          ? DateTime.parse(json['fechaProbableParto'] as String)
          : null,
      partosPrevios: json['partosPrevios'] as int?,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  GoatSheep copyWith({
    String? id,
    String? farmId,
    GoatSheepType? type,
    GoatSheepGender? gender,
    String? identification,
    String? name,
    DateTime? birthDate,
    double? currentWeight,
    EstadoReproductivo? estadoReproductivo,
    DateTime? fechaMonta,
    DateTime? fechaProbableParto,
    int? partosPrevios,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GoatSheep(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      type: type ?? this.type,
      gender: gender ?? this.gender,
      identification: identification ?? this.identification,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      currentWeight: currentWeight ?? this.currentWeight,
      estadoReproductivo: estadoReproductivo ?? this.estadoReproductivo,
      fechaMonta: fechaMonta ?? this.fechaMonta,
      fechaProbableParto: fechaProbableParto ?? this.fechaProbableParto,
      partosPrevios: partosPrevios ?? this.partosPrevios,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

