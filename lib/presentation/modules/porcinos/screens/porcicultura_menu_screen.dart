import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/farm_provider.dart';
import '../../../../screens/food_management_screen.dart';
import '../../../../screens/pig_vaccines_screen.dart';
import '../../../../screens/weight_history_screen.dart';
import '../list/cerdos_list_screen.dart';
import '../create/cerdo_create_screen.dart';
import '../../../../core/di/dependency_injection.dart';
import '../viewmodels/cerdos_viewmodel.dart';

/// Pantalla de menú de Porcicultura que centraliza todas las funcionalidades
class PorciculturaMenuScreen extends StatelessWidget {
  final String farmId;

  const PorciculturaMenuScreen({
    super.key,
    required this.farmId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión Porcina'),
        centerTitle: true,
      ),
      body: Consumer<FarmProvider>(
        builder: (context, farmProvider, child) {
          // Obtener la finca actual
          final farm = farmProvider.farms.firstWhere(
            (f) => f.id == farmId,
            orElse: () => farmProvider.currentFarm!,
          );

          return Padding(
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
                  subtitle: 'Ver y gestionar la lista completa de cerdos',
                  color: Colors.pink,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CerdosListScreen(farmId: farmId),
                      ),
                    );
                  },
                ),

                // Opción 2: Nutrición / Alimento
                _buildMenuCard(
                  context,
                  icon: Icons.restaurant,
                  title: 'Nutrición / Alimento',
                  subtitle: 'Gestionar alimentación e inventario de comida',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FoodManagementScreen(farm: farm),
                      ),
                    );
                  },
                ),

                // Opción 3: Sanidad / Vacunas
                _buildMenuCard(
                  context,
                  icon: Icons.medical_services,
                  title: 'Sanidad / Vacunas',
                  subtitle: 'Registrar y gestionar vacunas y tratamientos',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PigVaccinesScreen(farm: farm),
                      ),
                    );
                  },
                ),

                // Opción 4: Control de Peso
                _buildMenuCard(
                  context,
                  icon: Icons.monitor_weight,
                  title: 'Control de Peso',
                  subtitle: 'Registrar y monitorear el peso de los cerdos',
                  color: Colors.purple,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WeightHistoryScreen(farm: farm),
                      ),
                    );
                  },
                ),

                // Opción 5: Nuevo Cerdo/Lote
                _buildMenuCard(
                  context,
                  icon: Icons.add_circle,
                  title: 'Nuevo Cerdo/Lote',
                  subtitle: 'Registrar un nuevo cerdo o lote en el sistema',
                  color: Colors.green,
                  onTap: () {
                    final viewModel = DependencyInjection.createCerdosViewModel();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider.value(
                          value: viewModel,
                          child: CerdoCreateScreen(farmId: farmId),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
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

