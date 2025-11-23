import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

/// Widget para cambiar entre temas (light/dark/system)
class ThemeSwitcher extends StatelessWidget {
  const ThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return PopupMenuButton<String>(
      icon: Icon(
        themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
      ),
      tooltip: 'Cambiar tema',
      onSelected: (value) {
        switch (value) {
          case 'light':
            themeProvider.setLightMode();
            break;
          case 'dark':
            themeProvider.setDarkMode();
            break;
          case 'system':
            themeProvider.setSystemMode();
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'light',
          child: Row(
            children: [
              const Icon(Icons.light_mode),
              const SizedBox(width: 8),
              const Text('Modo claro'),
              if (!themeProvider.isDarkMode && !themeProvider.isSystemMode)
                const Spacer(),
              if (!themeProvider.isDarkMode && !themeProvider.isSystemMode)
                const Icon(Icons.check, size: 20),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'dark',
          child: Row(
            children: [
              const Icon(Icons.dark_mode),
              const SizedBox(width: 8),
              const Text('Modo oscuro'),
              if (themeProvider.isDarkMode && !themeProvider.isSystemMode)
                const Spacer(),
              if (themeProvider.isDarkMode && !themeProvider.isSystemMode)
                const Icon(Icons.check, size: 20),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'system',
          child: Row(
            children: [
              const Icon(Icons.brightness_auto),
              const SizedBox(width: 8),
              const Text('Seguir sistema'),
              if (themeProvider.isSystemMode)
                const Spacer(),
              if (themeProvider.isSystemMode)
                const Icon(Icons.check, size: 20),
            ],
          ),
        ),
      ],
    );
  }
}


