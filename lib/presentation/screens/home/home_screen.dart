import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/di/dependency_injection.dart';
import '../../modules/ovinos/list/ovejas_list_screen.dart';
import '../../modules/bovinos/list/bovinos_list_screen.dart';
import '../../modules/porcinos/list/cerdos_list_screen.dart';
import '../../modules/avicultura/list/gallinas_list_screen.dart';
import '../../modules/trabajadores/list/trabajadores_list_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../dashboard/viewmodels/dashboard_viewmodel.dart';

/// Pantalla principal con navegación inferior
class HomeScreen extends StatefulWidget {
  final String farmId;

  const HomeScreen({
    super.key,
    required this.farmId,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _screens.addAll([
      DashboardScreen(farmId: widget.farmId),
      OvejasListScreen(farmId: widget.farmId),
      BovinosListScreen(farmId: widget.farmId),
      CerdosListScreen(farmId: widget.farmId),
      GallinasListScreen(farmId: widget.farmId),
      TrabajadoresListScreen(farmId: widget.farmId),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DependencyInjection.createDashboardViewModel(),
        ),
      ],
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          const NavigationDestination(
            icon: Icon(Icons.pets_outlined),
            selectedIcon: Icon(Icons.pets),
            label: 'Ovinos',
          ),
          const NavigationDestination(
            icon: Icon(Icons.agriculture_outlined),
            selectedIcon: Icon(Icons.agriculture),
            label: 'Bovinos',
          ),
          const NavigationDestination(
            icon: Icon(Icons.pets_outlined),
            selectedIcon: Icon(Icons.pets),
            label: 'Porcinos',
          ),
          const NavigationDestination(
            icon: Icon(Icons.egg_outlined),
            selectedIcon: Icon(Icons.egg),
            label: 'Avicultura',
          ),
          const NavigationDestination(
            icon: Icon(Icons.people_outlined),
            selectedIcon: Icon(Icons.people),
            label: 'Trabajadores',
          ),
        ],
      ),
      ),
    );
  }
}

