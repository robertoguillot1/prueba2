import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/entities/farm/farm.dart';

/// Modelo de datos para Farm
class FarmModel extends Farm {
  const FarmModel({
    required String id,
    required String ownerId,
    required String name,
    String? location,
    String? description,
    String? imageUrl,
    required int primaryColor,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) : super(
          id: id,
          ownerId: ownerId,
          name: name,
          location: location,
          description: description,
          imageUrl: imageUrl,
          primaryColor: primaryColor,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  /// Crea un modelo desde JSON de Firestore
  factory FarmModel.fromJson(Map<String, dynamic> json) {
    return FarmModel(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      name: json['name'] as String,
      location: json['location'] as String?,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      primaryColor: json['primaryColor'] as int? ?? 0xFF4CAF50, // Verde por defecto
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
      'ownerId': ownerId,
      'name': name,
      'location': location,
      'description': description,
      'imageUrl': imageUrl,
      'primaryColor': primaryColor,
      'createdAt': Timestamp.fromDate(createdAt),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  /// Crea una copia del modelo
  FarmModel copyWith({
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
    return FarmModel(
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
}

