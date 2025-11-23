import '../../../domain/entities/trabajadores/trabajador.dart';

/// Modelo de datos para Trabajador
class TrabajadorModel extends Trabajador {
  const TrabajadorModel({
    required String id,
    required String farmId,
    required String fullName,
    required String identification,
    required String position,
    required double salary,
    required DateTime startDate,
    bool isActive = true,
    required WorkerType workerType,
    String? laborDescription,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super(
          id: id,
          farmId: farmId,
          fullName: fullName,
          identification: identification,
          position: position,
          salary: salary,
          startDate: startDate,
          isActive: isActive,
          workerType: workerType,
          laborDescription: laborDescription,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  /// Crea un modelo desde JSON
  factory TrabajadorModel.fromJson(Map<String, dynamic> json) {
    return TrabajadorModel(
      id: json['id'] as String,
      farmId: json['farmId'] as String,
      fullName: json['fullName'] as String,
      identification: json['identification'] as String,
      position: json['position'] as String,
      salary: (json['salary'] as num).toDouble(),
      startDate: DateTime.parse(json['startDate'] as String),
      isActive: json['isActive'] as bool? ?? true,
      workerType: WorkerType.values.firstWhere(
        (e) => e.name == json['workerType'],
        orElse: () => WorkerType.fijo,
      ),
      laborDescription: json['laborDescription'] as String?,
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
      'fullName': fullName,
      'identification': identification,
      'position': position,
      'salary': salary,
      'startDate': startDate.toIso8601String(),
      'isActive': isActive,
      'workerType': workerType.name,
      'laborDescription': laborDescription,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Crea una copia del modelo con campos modificados
  TrabajadorModel copyWith({
    String? id,
    String? farmId,
    String? fullName,
    String? identification,
    String? position,
    double? salary,
    DateTime? startDate,
    bool? isActive,
    WorkerType? workerType,
    String? laborDescription,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TrabajadorModel(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      fullName: fullName ?? this.fullName,
      identification: identification ?? this.identification,
      position: position ?? this.position,
      salary: salary ?? this.salary,
      startDate: startDate ?? this.startDate,
      isActive: isActive ?? this.isActive,
      workerType: workerType ?? this.workerType,
      laborDescription: laborDescription ?? this.laborDescription,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convierte la entidad a modelo
  factory TrabajadorModel.fromEntity(Trabajador entity) {
    return TrabajadorModel(
      id: entity.id,
      farmId: entity.farmId,
      fullName: entity.fullName,
      identification: entity.identification,
      position: entity.position,
      salary: entity.salary,
      startDate: entity.startDate,
      isActive: entity.isActive,
      workerType: entity.workerType,
      laborDescription: entity.laborDescription,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

