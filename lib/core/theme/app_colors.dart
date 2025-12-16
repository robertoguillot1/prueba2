import 'package:flutter/material.dart';

/// Colores de la aplicación - Premium Palette
class AppColors {
  // === Premium Brand Colors ===
  static const Color emerald = Color(0xFF00695C); // Primary Deep Teal/Green
  static const Color emeraldLight = Color(0xFF4DB6AC);
  static const Color emeraldDark = Color(0xFF004D40);
  
  static const Color gold = Color(0xFFFFD700); // Secondary Luxury
  static const Color goldDark = Color(0xFFC7A500);
  
  // === Legacy & Dynamic Support ===
  static const Color primaryGreen = Color(0xFF2E7D32); // More professional green
  static const Color primaryBlue = Color(0xFF1565C0); // Deeper blue
  static const Color primaryBrown = Color(0xFF5D4037); // Richer brown
  static const Color primaryOrange = Color(0xFFEF6C00); // Burnt orange
  
  // === Semantic Colors ===
  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFC62828);
  static const Color warning = Color(0xFFEF6C00);
  static const Color info = Color(0xFF0277BD);
  
  // === Premium Surfaces ===
  // Light Mode
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF5F7FA); // Cold gray-white for modern feel
  static const Color cardLight = Color(0xFFFFFFFF);
  
  // Dark Mode
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color cardDark = Color(0xFF1E1E1E);
  
  // === Typography ===
  static const Color textPrimary = Color(0xFF263238); // Blue-grey for softer contrast
  static const Color textSecondary = Color(0xFF546E7A);
  static const Color textPrimaryDark = Color(0xFFECEFF1);
  static const Color textSecondaryDark = Color(0xFFB0BEC5);
  
  // === Borders & Dividers ===
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFF37474F);

  // === Gradients ===
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [emerald, emeraldLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // ... Helpers ...
  static Color getTextColor(Brightness brightness) {
    return brightness == Brightness.dark ? textPrimaryDark : textPrimary;
  }
  
  static Color getSecondaryTextColor(Brightness brightness) {
    return brightness == Brightness.dark ? textSecondaryDark : textSecondary;
  }
  
  static Color getBackgroundColor(Brightness brightness) {
    return brightness == Brightness.dark ? backgroundDark : backgroundLight;
  }
}

