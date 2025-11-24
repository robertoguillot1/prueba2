/// Entidad de dominio para Trabajador
class Trabajador {
  final String id;
  final String farmId;
  final String fullName;
  final String identification;
  final String position;
  final double salary;
  final DateTime startDate;
  final bool isActive;
  final WorkerType workerType;
  final String? laborDescription;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Trabajador({
    required this.id,
    required this.farmId,
    required this.fullName,
    required this.identification,
    required this.position,
    required this.salary,
    required this.startDate,
    this.isActive = true,
    required this.workerType,
    this.laborDescription,
    this.createdAt,
    this.updatedAt,
  });

  /// Valida que la entidad sea válida
  bool get isValid {
    if (id.isEmpty || farmId.isEmpty) return false;
    if (fullName.trim().isEmpty) return false;
    if (position.trim().isEmpty) return false;
    if (salary <= 0) return false;
    if (startDate.isAfter(DateTime.now())) return false;
    if (workerType == WorkerType.porLabor && 
        (laborDescription == null || laborDescription!.trim().isEmpty)) {
      return false;
    }
    return true;
  }
}

/// Tipo de trabajador
enum WorkerType {
  fijo,
  porLabor,
}



