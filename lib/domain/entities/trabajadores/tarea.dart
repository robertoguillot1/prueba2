/// Entidad de dominio para Tarea
class Tarea {
  final String id;
  final String trabajadorId;
  final String farmId;
  final String titulo;
  final String descripcion;
  final DateTime fechaAsignacion;
  final DateTime? fechaCompletada;
  final TareaEstado estado;
  final String? observaciones;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Tarea({
    required this.id,
    required this.trabajadorId,
    required this.farmId,
    required this.titulo,
    required this.descripcion,
    required this.fechaAsignacion,
    this.fechaCompletada,
    required this.estado,
    this.observaciones,
    this.createdAt,
    this.updatedAt,
  });

  /// Indica si la tarea está completada
  bool get isCompletada => estado == TareaEstado.completada;

  /// Indica si la tarea está pendiente
  bool get isPendiente => estado == TareaEstado.pendiente;

  /// Indica si la tarea está en progreso
  bool get isEnProgreso => estado == TareaEstado.enProgreso;

  /// Valida que la entidad sea válida
  bool get isValid {
    if (id.isEmpty || trabajadorId.isEmpty || farmId.isEmpty) return false;
    if (titulo.trim().isEmpty) return false;
    if (descripcion.trim().isEmpty) return false;
    if (fechaAsignacion.isAfter(DateTime.now())) return false;
    if (fechaCompletada != null && 
        fechaCompletada!.isBefore(fechaAsignacion)) return false;
    if (estado == TareaEstado.completada && fechaCompletada == null) {
      return false;
    }
    return true;
  }
}

/// Estado de la tarea
enum TareaEstado {
  pendiente,
  enProgreso,
  completada,
  cancelada,
}


