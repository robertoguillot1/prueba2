enum WorkerType {
  fijo,
  porLabor,
}

extension WorkerTypeExtension on WorkerType {
  String get displayName {
    switch (this) {
      case WorkerType.fijo:
        return 'Trabajador Fijo (Nómina)';
      case WorkerType.porLabor:
        return 'Trabajador Por Labor/Obra';
    }
  }
  
  String get value {
    switch (this) {
      case WorkerType.fijo:
        return 'fijo';
      case WorkerType.porLabor:
        return 'porLabor';
    }
  }
  
  static WorkerType fromString(String value) {
    switch (value) {
      case 'fijo':
        return WorkerType.fijo;
      case 'porLabor':
        return WorkerType.porLabor;
      default:
        return WorkerType.fijo;
    }
  }
}

class Worker {
  final String id;
  final String fullName;
  final String identification;
  final String position;
  final double salary;
  final DateTime startDate;
  final bool isActive;
  final WorkerType workerType;
  final String? laborDescription;

  Worker({
    required this.id,
    required this.fullName,
    required this.identification,
    required this.position,
    required this.salary,
    required this.startDate,
    this.isActive = true,
    this.workerType = WorkerType.fijo,
    this.laborDescription,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'identification': identification,
      'position': position,
      'salary': salary,
      'startDate': startDate.toIso8601String(),
      'isActive': isActive,
      'workerType': workerType.value,
      'laborDescription': laborDescription,
    };
  }

  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      identification: json['identification'] as String,
      position: json['position'] as String,
      salary: (json['salary'] as num).toDouble(),
      startDate: DateTime.parse(json['startDate'] as String),
      isActive: json['isActive'] as bool? ?? true,
      workerType: json['workerType'] != null
          ? WorkerTypeExtension.fromString(json['workerType'] as String)
          : WorkerType.fijo,
      laborDescription: json['laborDescription'] as String?,
    );
  }

  Worker copyWith({
    String? id,
    String? fullName,
    String? identification,
    String? position,
    double? salary,
    DateTime? startDate,
    bool? isActive,
    WorkerType? workerType,
    String? laborDescription,
  }) {
    return Worker(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      identification: identification ?? this.identification,
      position: position ?? this.position,
      salary: salary ?? this.salary,
      startDate: startDate ?? this.startDate,
      isActive: isActive ?? this.isActive,
      workerType: workerType ?? this.workerType,
      laborDescription: laborDescription ?? this.laborDescription,
    );
  }
}





