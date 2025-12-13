import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Tipos de alerta en el dashboard
enum AlertType {
  critical, // Rojo - Requiere atención inmediata
  warning,  // Amarillo - Requiere atención pronto
  info,     // Azul - Informativo
}

/// Modelo para las alertas del dashboard
class DashboardAlert extends Equatable {
  final String title;
  final String message;
  final AlertType type;
  final String? route; // Ruta para navegar y solucionar el problema
  final Map<String, dynamic>? routeArguments; // Argumentos para la navegación

  const DashboardAlert({
    required this.title,
    required this.message,
    required this.type,
    this.route,
    this.routeArguments,
  });

  /// Color asociado al tipo de alerta
  Color get color {
    switch (type) {
      case AlertType.critical:
        return Colors.red;
      case AlertType.warning:
        return Colors.orange;
      case AlertType.info:
        return Colors.blue;
    }
  }

  /// Icono asociado al tipo de alerta
  IconData get icon {
    switch (type) {
      case AlertType.critical:
        return Icons.error;
      case AlertType.warning:
        return Icons.warning;
      case AlertType.info:
        return Icons.info;
    }
  }

  /// Etiqueta del tipo de alerta
  String get typeLabel {
    switch (type) {
      case AlertType.critical:
        return 'Crítico';
      case AlertType.warning:
        return 'Advertencia';
      case AlertType.info:
        return 'Información';
    }
  }

  @override
  List<Object?> get props => [title, message, type, route, routeArguments];
}







