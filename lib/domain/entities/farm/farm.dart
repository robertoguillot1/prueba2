/// Entidad de dominio para Finca
class Farm {
  final String id;
  final String ownerId; // ID del usuario propietario
  final String name;
  final String? location;
  final String? description;
  final String? imageUrl;
  final int primaryColor; // Color almacenado como int (value)
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Farm({
    required this.id,
    required this.ownerId,
    required this.name,
    this.location,
    this.description,
    this.imageUrl,
    required this.primaryColor,
    required this.createdAt,
    this.updatedAt,
  });

  /// Crea una copia de la entidad con los valores actualizados
  Farm copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? location,
    String? description,
    String? imageUrl,
    int? primaryColor,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Farm(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      location: location ?? this.location,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      primaryColor: primaryColor ?? this.primaryColor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Valida que la entidad sea válida
  bool get isValid {
    return id.isNotEmpty && 
           ownerId.isNotEmpty && 
           name.isNotEmpty &&
           name.length >= 2;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Farm && 
           other.id == id && 
           other.ownerId == ownerId;
  }

  @override
  int get hashCode => id.hashCode ^ ownerId.hashCode;

  @override
  String toString() => 'Farm(id: $id, name: $name, ownerId: $ownerId)';
}








