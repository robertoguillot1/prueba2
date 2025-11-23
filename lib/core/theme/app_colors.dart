import 'package:flutter/material.dart';

/// Colores de la aplicación
class AppColors {
  // Colores primarios comunes para fincas
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color primaryBrown = Color(0xFF795548);
  static const Color primaryOrange = Color(0xFFFF9800);
  
  // Colores de estado
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  
  // Colores de fondo
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);
  
  // Colores de texto
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  
  // Colores de borde
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFF424242);
  
  /// Obtiene un color según el brightness
  static Color getTextColor(Brightness brightness) {
    return brightness == Brightness.dark 
        ? textPrimaryDark 
        : textPrimary;
  }
  
  /// Obtiene un color secundario según el brightness
  static Color getSecondaryTextColor(Brightness brightness) {
    return brightness == Brightness.dark 
        ? textSecondaryDark 
        : textSecondary;
  }
  
  /// Obtiene un color de fondo según el brightness
  static Color getBackgroundColor(Brightness brightness) {
    return brightness == Brightness.dark 
        ? backgroundDark 
        : backgroundLight;
  }
}


