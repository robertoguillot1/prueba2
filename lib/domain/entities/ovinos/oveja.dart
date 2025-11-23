/// Entidad de dominio para Oveja
class Oveja {
  final String id;
  final String farmId;
  final String? identification;
  final String? name;
  final DateTime birthDate;
  final double? currentWeight;
  final OvejaGender gender;
  final EstadoReproductivoOveja? estadoReproductivo;
  final DateTime? fechaMonta;
  final DateTime? fechaProbableParto;
  final int? partosPrevios;
  final String? notes;
  final String? photoUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Oveja({
    required this.id,
    required this.farmId,
    this.identification,
    this.name,
    required this.birthDate,
    this.currentWeight,
    required this.gender,
    this.estadoReproductivo,
    this.fechaMonta,
    this.fechaProbableParto,
    this.partosPrevios,
    this.notes,
    this.photoUrl,
    this.createdAt,
    this.updatedAt,
  });

  /// Crea una copia de la entidad con los valores actualizados
  Oveja copyWith({
    String? id,
    String? farmId,
    String? identification,
    String? name,
    DateTime? birthDate,
    double? currentWeight,
    OvejaGender? gender,
    EstadoReproductivoOveja? estadoReproductivo,
    DateTime? fechaMonta,
    DateTime? fechaProbableParto,
    int? partosPrevios,
    String? notes,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Oveja(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      identification: identification ?? this.identification,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      currentWeight: currentWeight ?? this.currentWeight,
      gender: gender ?? this.gender,
      estadoReproductivo: estadoReproductivo ?? this.estadoReproductivo,
      fechaMonta: fechaMonta ?? this.fechaMonta,
      fechaProbableParto: fechaProbableParto ?? this.fechaProbableParto,
      partosPrevios: partosPrevios ?? this.partosPrevios,
      notes: notes ?? this.notes,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Calcula la edad en años
  int get ageInYears {
    final now = DateTime.now();
    int years = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      years--;
    }
    return years;
  }

  /// Calcula días restantes hasta el parto
  int? get diasRestantesParto {
    if (fechaProbableParto == null) return null;
    final now = DateTime.now();
    return fechaProbableParto!.difference(now).inDays;
  }

  /// Indica si está cerca del parto (menos de 10 días)
  bool get isNearParto {
    final dias = diasRestantesParto;
    return dias != null && dias >= 0 && dias <= 10;
  }

  /// Valida que la entidad sea válida
  bool get isValid {
    if (id.isEmpty || farmId.isEmpty) return false;
    if (birthDate.isAfter(DateTime.now())) return false;
    if (currentWeight != null && currentWeight! < 0) return false;
    if (partosPrevios != null && partosPrevios! < 0) return false;
    return true;
  }
}

/// Género de la oveja
enum OvejaGender {
  male,
  female,
}

/// Estado reproductivo de la oveja
enum EstadoReproductivoOveja {
  vacia,
  gestante,
  lactante,
}

