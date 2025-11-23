import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/farm_provider.dart';
import '../providers/auth_provider.dart';
import 'farms_list_screen.dart';
import 'settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const FarmsListScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Cargar fincas al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final farmProvider = Provider.of<FarmProvider>(context, listen: false);
      farmProvider.loadFarms();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Si el usuario no está autenticado, no debería llegar aquí
        // pero por seguridad verificamos
        if (!authProvider.isAuthenticated) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _currentIndex = index;
              });
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.agriculture_outlined),
                selectedIcon: Icon(Icons.agriculture),
                label: 'Fincas',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: 'Configuración',
              ),
            ],
          ),
        );
      },
    );
  }
}









