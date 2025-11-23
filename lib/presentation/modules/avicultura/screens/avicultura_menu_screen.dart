import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/farm_provider.dart';
import '../../../../screens/poultry_home_screen.dart';

/// Pantalla de menú de Avicultura para seleccionar entre Engorde y Ponedoras
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
        centerTitle: true,
      ),
      body: Consumer<FarmProvider>(
        builder: (context, farmProvider, child) {
          // Obtener la finca actual
          final farm = farmProvider.farms.firstWhere(
            (f) => f.id == farmId,
            orElse: () => farmProvider.currentFarm!,
          );

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Título
                  Text(
                    'Selecciona el tipo de avicultura',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Botón: Pollos de Engorde
                  _buildMenuCard(
                    context,
                    title: 'Pollos de Engorde',
                    subtitle: 'Gestión de lotes de pollos para producción de carne',
                    icon: Icons.trending_up,
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PoultryHomeScreen(
                            farm: farm,
                            initialTabIndex: 0, // Tab de Engorde
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Botón: Gallinas Ponedoras
                  _buildMenuCard(
                    context,
                    title: 'Gallinas Ponedoras',
                    subtitle: 'Gestión de lotes de gallinas para producción de huevos',
                    icon: Icons.egg,
                    color: Colors.amber,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PoultryHomeScreen(
                            farm: farm,
                            initialTabIndex: 1, // Tab de Ponedoras
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(24),
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
          child: Row(
            children: [
              // Icono
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 48,
                  color: color,
                ),
              ),
              const SizedBox(width: 20),
              // Texto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],
                ),
              ),
              // Flecha
              Icon(
                Icons.arrow_forward_ios,
                color: color,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

