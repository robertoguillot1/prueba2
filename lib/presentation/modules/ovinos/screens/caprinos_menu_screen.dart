import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../list/ovejas_list_screen.dart';
import '../create/oveja_create_screen.dart';
import '../../../../core/di/dependency_injection.dart';
import '../viewmodels/ovejas_viewmodel.dart';

/// Pantalla de menú de Caprinos/Ovinos que centraliza todas las funcionalidades
class CaprinosMenuScreen extends StatelessWidget {
  final String farmId;

  const CaprinosMenuScreen({
    super.key,
    required this.farmId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Control Ovino/Caprino'),
        centerTitle: true,
      ),
      body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Título descriptivo
              Text(
                'Selecciona una opción',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
              const SizedBox(height: 24),

              // Opción 1: Inventario del Rebaño
              _buildMenuCard(
                context,
                icon: Icons.pets,
                title: 'Inventario del Rebaño',
                subtitle: 'Ver y gestionar la lista completa de chivos y ovejas',
                color: Colors.grey,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OvejasListScreen(farmId: farmId),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Opción 2: Control Sanitario
              _buildMenuCard(
                context,
                icon: Icons.medical_services,
                title: 'Control Sanitario',
                subtitle: 'Registrar y gestionar vacunas y tratamientos sanitarios',
                color: Colors.blue,
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (_) => GoatSheepVaccinesScreen(farm: farm),
                  //   ),
                  // );
                  debugPrint('Funcionalidad pendiente: Control Sanitario');
                },
              ),
              const SizedBox(height: 16),

              // Opción 3: Reproducción/Partos
              _buildMenuCard(
                context,
                icon: Icons.favorite,
                title: 'Reproducción/Partos',
                subtitle: 'Gestionar el estado reproductivo y partos del rebaño',
                color: Colors.pink,
                onTap: () {
                  // Navegar a la lista donde se puede gestionar la reproducción desde cada animal
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OvejasListScreen(farmId: farmId),
                    ),
                  ).then((_) {
                    // Mostrar mensaje informativo
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'La reproducción se gestiona desde el perfil de cada animal',
                        ),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  });
                },
              ),
              const SizedBox(height: 16),

              // Opción 4: Registrar Nuevo Animal
              _buildMenuCard(
                context,
                icon: Icons.add_circle,
                title: 'Registrar Nuevo Animal',
                subtitle: 'Agregar un nuevo chivo o oveja al sistema',
                color: Colors.green,
                onTap: () {
                  final viewModel = DependencyInjection.createOvejasViewModel();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider.value(
                        value: viewModel,
                        child: OvejaCreateScreen(farmId: farmId),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Icono
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              // Texto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],
                ),
              ),
              // Flecha
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade400,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

