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
        title: const Text('Gestión Caprina/Ovina'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
          children: [
            // Opción 1: Inventario General
            _buildMenuCard(
              context,
              icon: Icons.pets,
              title: 'Inventario General',
              subtitle: 'Ver y gestionar la lista completa de ovejas',
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

            // Opción 2: Nueva Oveja
            _buildMenuCard(
              context,
              icon: Icons.add_circle,
              title: 'Nueva Oveja',
              subtitle: 'Registrar una nueva oveja en el sistema',
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
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono grande
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              // Título
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Subtítulo
              Expanded(
                child: Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}








