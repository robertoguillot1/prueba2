import 'package:flutter/material.dart';
import '../list/bovinos_list_screen.dart';
import '../create/bovino_create_screen.dart';

/// Pantalla de menú para el módulo de Bovinos
class BovinoMenuScreen extends StatelessWidget {
  final String farmId;

  const BovinoMenuScreen({
    super.key,
    required this.farmId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión Bovina'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: [
            _buildMenuCard(
              context: context,
              icon: Icons.list_alt,
              title: 'Inventario',
              color: Colors.brown.shade300,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BovinosListScreen(farmId: farmId),
                  ),
                );
              },
            ),
            _buildMenuCard(
              context: context,
              icon: Icons.medical_services,
              title: 'Sanidad',
              color: Colors.red.shade300,
              onTap: () {
                debugPrint('Ir a sanidad');
              },
            ),
            _buildMenuCard(
              context: context,
              icon: Icons.water_drop,
              title: 'Producción',
              color: Colors.blue.shade300,
              onTap: () {
                debugPrint('Ir a producción');
              },
            ),
            _buildMenuCard(
              context: context,
              icon: Icons.local_shipping,
              title: 'Movilización',
              color: Colors.orange.shade300,
              onTap: () {
                debugPrint('Ir a movilización');
              },
            ),
            _buildMenuCard(
              context: context,
              icon: Icons.add_circle,
              title: 'Nuevo Animal',
              color: Colors.green.shade300,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BovinoCreateScreen(farmId: farmId),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            color: color.withOpacity(0.1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 64,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

