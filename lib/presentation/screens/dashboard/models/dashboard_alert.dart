/// Modelo para alertas del dashboard
class DashboardAlert {
  final AlertType tipo;
  final String titulo;
  final String mensaje;
  final AlertSeverity severidad;
  final DateTime fecha;

  const DashboardAlert({
    required this.tipo,
    required this.titulo,
    required this.mensaje,
    required this.severidad,
    required this.fecha,
  });
}

/// Tipos de alertas
enum AlertType {
  partoBovino,
  secadoBovino,
  partoOvino,
  partoCerdo,
  stockAlimento,
  contratoVencimiento,
}

/// Severidad de la alerta
enum AlertSeverity {
  baja,
  media,
  critica,
}

/// Extensión para obtener el color según la severidad
extension AlertSeverityExtension on AlertSeverity {
  int get index {
    switch (this) {
      case AlertSeverity.baja:
        return 0;
      case AlertSeverity.media:
        return 1;
      case AlertSeverity.critica:
        return 2;
    }
  }
}

