import 'package:equatable/equatable.dart';

/// Entidad de dominio para Bovino
class BovineEntity extends Equatable {
  final String id;
  final String farmId;
  final String identifier; // Arete/número de identificación
  final String? name;
  final String breed; // Raza
  final BovineGender gender;
  final DateTime birthDate;
  final double weight;
  final BovinePurpose purpose; // carne/leche/doble
  final BovineStatus status; // activo/vendido/muerto
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? motherId; // ID de la madre (genealogía)
  final String? fatherId; // ID del padre (genealogía)

  const BovineEntity({
    required this.id,
    required this.farmId,
    required this.identifier,
    this.name,
    required this.breed,
    required this.gender,
    required this.birthDate,
    required this.weight,
    required this.purpose,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.motherId,
    this.fatherId,
  });

  /// Calcula la edad del bovino en años basada en birthDate
  int get age {
    final now = DateTime.now();
    int years = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      years--;
    }
    return years;
  }

  /// Crea una copia de la entidad con los valores actualizados
  BovineEntity copyWith({
    String? id,
    String? farmId,
    String? identifier,
    String? name,
    String? breed,
    BovineGender? gender,
    DateTime? birthDate,
    double? weight,
    BovinePurpose? purpose,
    BovineStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? motherId,
    String? fatherId,
  }) {
    return BovineEntity(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      identifier: identifier ?? this.identifier,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      weight: weight ?? this.weight,
      purpose: purpose ?? this.purpose,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      motherId: motherId ?? this.motherId,
      fatherId: fatherId ?? this.fatherId,
    );
  }

  /// Valida que la entidad sea válida
  bool get isValid {
    return id.isNotEmpty &&
        farmId.isNotEmpty &&
        identifier.isNotEmpty &&
        breed.isNotEmpty &&
        weight > 0 &&
        birthDate.isBefore(DateTime.now());
  }

  @override
  List<Object?> get props => [
        id,
        farmId,
        identifier,
        name,
        breed,
        gender,
        birthDate,
        weight,
        purpose,
        status,
        createdAt,
        updatedAt,
        motherId,
        fatherId,
      ];
}

/// Género del bovino
enum BovineGender {
  male, // Macho
  female, // Hembra
}

/// Propósito del bovino
enum BovinePurpose {
  meat, // Carne
  milk, // Leche
  dual, // Doble propósito
}

/// Estado del bovino
enum BovineStatus {
  active, // Activo
  sold, // Vendido
  dead, // Muerto
}

