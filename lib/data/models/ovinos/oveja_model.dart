import '../../../domain/entities/ovinos/oveja.dart';

/// Modelo de datos para Oveja
class OvejaModel extends Oveja {
  const OvejaModel({
    required String id,
    required String farmId,
    String? identification,
    String? name,
    required DateTime birthDate,
    double? currentWeight,
    required OvejaGender gender,
    EstadoReproductivoOveja? estadoReproductivo,
    DateTime? fechaMonta,
    DateTime? fechaProbableParto,
    int? partosPrevios,
    String? notes,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super(
          id: id,
          farmId: farmId,
          identification: identification,
          name: name,
          birthDate: birthDate,
          currentWeight: currentWeight,
          gender: gender,
          estadoReproductivo: estadoReproductivo,
          fechaMonta: fechaMonta,
          fechaProbableParto: fechaProbableParto,
          partosPrevios: partosPrevios,
          notes: notes,
          photoUrl: photoUrl,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  /// Crea un modelo desde JSON
  factory OvejaModel.fromJson(Map<String, dynamic> json) {
    return OvejaModel(
      id: json['id'] as String,
      farmId: json['farmId'] as String,
      identification: json['identification'] as String?,
      name: json['name'] as String?,
      birthDate: DateTime.parse(json['birthDate'] as String),
      currentWeight: json['currentWeight'] != null
          ? (json['currentWeight'] as num).toDouble()
          : null,
      gender: OvejaGender.values.firstWhere(
        (e) => e.name == json['gender'],
        orElse: () => OvejaGender.female,
      ),
      estadoReproductivo: json['estadoReproductivo'] != null
          ? EstadoReproductivoOveja.values.firstWhere(
              (e) => e.name == json['estadoReproductivo'],
              orElse: () => EstadoReproductivoOveja.vacia,
            )
          : null,
      fechaMonta: json['fechaMonta'] != null
          ? DateTime.parse(json['fechaMonta'] as String)
          : null,
      fechaProbableParto: json['fechaProbableParto'] != null
          ? DateTime.parse(json['fechaProbableParto'] as String)
          : null,
      partosPrevios: json['partosPrevios'] as int?,
      notes: json['notes'] as String?,
      photoUrl: json['photoUrl'] as String?,
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
      'identification': identification,
      'name': name,
      'birthDate': birthDate.toIso8601String(),
      'currentWeight': currentWeight,
      'gender': gender.name,
      'estadoReproductivo': estadoReproductivo?.name,
      'fechaMonta': fechaMonta?.toIso8601String(),
      'fechaProbableParto': fechaProbableParto?.toIso8601String(),
      'partosPrevios': partosPrevios,
      'notes': notes,
      'photoUrl': photoUrl,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Crea una copia del modelo con campos modificados
  OvejaModel copyWith({
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
    return OvejaModel(
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

  /// Convierte la entidad a modelo
  factory OvejaModel.fromEntity(Oveja entity) {
    return OvejaModel(
      id: entity.id,
      farmId: entity.farmId,
      identification: entity.identification,
      name: entity.name,
      birthDate: entity.birthDate,
      currentWeight: entity.currentWeight,
      gender: entity.gender,
      estadoReproductivo: entity.estadoReproductivo,
      fechaMonta: entity.fechaMonta,
      fechaProbableParto: entity.fechaProbableParto,
      partosPrevios: entity.partosPrevios,
      notes: entity.notes,
      photoUrl: entity.photoUrl,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

