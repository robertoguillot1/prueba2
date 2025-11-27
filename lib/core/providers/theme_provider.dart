import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' show Brightness;

/// Provider para manejo del tema (light/dark mode)
class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  
  bool _isDarkMode = false; // Por defecto modo claro
  bool _isSystemMode = false; // Por defecto NO seguir el sistema (usar modo claro)

  ThemeProvider() {
    loadTheme();
  }

  bool get isDarkMode => _isDarkMode;
  bool get isSystemMode => _isSystemMode;

  /// Carga el tema guardado (método público para inicialización)
  Future<void> loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeString = prefs.getString(_themeKey);
      
      if (themeModeString != null) {
        if (themeModeString == 'system') {
          _isSystemMode = true;
          _isDarkMode = _getSystemBrightness() == Brightness.dark;
        } else {
          _isSystemMode = false;
          _isDarkMode = themeModeString == 'dark';
        }
      } else {
        // Por defecto usar modo claro (no seguir el sistema)
        _isSystemMode = false;
        _isDarkMode = false;
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading theme: $e');
    }
  }

  /// Guarda la preferencia de tema
  Future<void> _saveTheme(String mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, mode);
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }

  /// Obtiene el brightness del sistema
  Brightness _getSystemBrightness() {
    return WidgetsBinding.instance.platformDispatcher.platformBrightness;
  }

  /// Cambia al modo claro
  Future<void> setLightMode() async {
    _isDarkMode = false;
    _isSystemMode = false;
    await _saveTheme('light');
    notifyListeners();
  }

  /// Cambia al modo oscuro
  Future<void> setDarkMode() async {
    _isDarkMode = true;
    _isSystemMode = false;
    await _saveTheme('dark');
    notifyListeners();
  }

  /// Sigue el modo del sistema
  Future<void> setSystemMode() async {
    _isSystemMode = true;
    _isDarkMode = _getSystemBrightness() == Brightness.dark;
    await _saveTheme('system');
    notifyListeners();
  }

  /// Alterna entre modo claro y oscuro
  Future<void> toggleTheme() async {
    if (_isSystemMode) {
      // Si está en modo sistema, cambiar a modo manual
      _isSystemMode = false;
      _isDarkMode = !_isDarkMode;
      await _saveTheme(_isDarkMode ? 'dark' : 'light');
    } else {
      // Si está en modo manual, alternar
      _isDarkMode = !_isDarkMode;
      await _saveTheme(_isDarkMode ? 'dark' : 'light');
    }
    notifyListeners();
  }

  /// Actualiza el tema si está en modo sistema
  void updateSystemTheme() {
    if (_isSystemMode) {
      final newDarkMode = _getSystemBrightness() == Brightness.dark;
      if (_isDarkMode != newDarkMode) {
        _isDarkMode = newDarkMode;
        notifyListeners();
      }
    }
  }
}

