/// Entidad de dominio para Asistencia
class Asistencia {
  final String id;
  final String trabajadorId;
  final String farmId;
  final DateTime fecha;
  final DateTime? horaEntrada;
  final DateTime? horaSalida;
  final int? horasTrabajadas;
  final bool presente;
  final String? motivoAusencia;
  final String? observaciones;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Asistencia({
    required this.id,
    required this.trabajadorId,
    required this.farmId,
    required this.fecha,
    this.horaEntrada,
    this.horaSalida,
    this.horasTrabajadas,
    required this.presente,
    this.motivoAusencia,
    this.observaciones,
    this.createdAt,
    this.updatedAt,
  });

  /// Calcula las horas trabajadas si hay entrada y salida
  int? calcularHorasTrabajadas() {
    if (horaEntrada == null || horaSalida == null) return null;
    if (horaSalida!.isBefore(horaEntrada!)) return null;
    return horaSalida!.difference(horaEntrada!).inHours;
  }

  /// Valida que la entidad sea válida
  bool get isValid {
    if (id.isEmpty || trabajadorId.isEmpty || farmId.isEmpty) return false;
    if (fecha.isAfter(DateTime.now())) return false;
    if (!presente && motivoAusencia == null) return false;
    if (horaEntrada != null && horaSalida != null) {
      if (horaSalida!.isBefore(horaEntrada!)) return false;
    }
    if (horasTrabajadas != null && horasTrabajadas! < 0) return false;
    return true;
  }
}


