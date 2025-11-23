import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

/// Botón simple para alternar entre modo claro y oscuro
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return IconButton(
      icon: Icon(
        themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
      ),
      tooltip: themeProvider.isDarkMode ? 'Modo claro' : 'Modo oscuro',
      onPressed: () => themeProvider.toggleTheme(),
    );
  }
}


