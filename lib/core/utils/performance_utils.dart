import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Utilidades para optimización de rendimiento
class PerformanceUtils {
  /// Crea un widget que solo se reconstruye cuando cambia el valor específico
  static Widget buildSelector<T>(
    BuildContext context,
    T Function() selector,
    Widget Function(BuildContext, T) builder,
  ) {
    return Selector<dynamic, T>(
      selector: (_, __) => selector(),
      builder: (context, value, child) => builder(context, value),
    );
  }

  /// Verifica si un widget debe reconstruirse basado en cambios específicos
  static bool shouldRebuild<T>(T oldValue, T newValue) {
    return oldValue != newValue;
  }
}

