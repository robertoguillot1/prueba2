import 'package:flutter/material.dart';

/// Pantalla de menú para el módulo de Avicultura
class AviculturaMenuScreen extends StatelessWidget {
  final String farmId;

  const AviculturaMenuScreen({
    super.key,
    required this.farmId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avicultura'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLargeMenuCard(
                context: context,
                icon: Icons.pets,
                title: 'Pollos de Engorde',
                color: Colors.orange.shade300,
                onTap: () {
                  // Ruta futura: /avicultura/engorde/list
                  debugPrint('Navegar a /avicultura/engorde/list');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Funcionalidad en desarrollo: /avicultura/engorde/list'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              _buildLargeMenuCard(
                context: context,
                icon: Icons.egg,
                title: 'Gallinas Ponedoras',
                color: Colors.amber.shade300,
                onTap: () {
                  // Ruta futura: /avicultura/ponedoras/list
                  debugPrint('Navegar a /avicultura/ponedoras/list');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Funcionalidad en desarrollo: /avicultura/ponedoras/list'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLargeMenuCard({
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
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            color: color.withOpacity(0.1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 80,
                color: color,
              ),
              const SizedBox(width: 24),
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

