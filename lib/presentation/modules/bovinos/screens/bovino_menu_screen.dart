import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/farm_provider.dart';
import '../../../../screens/cattle_vaccines_screen.dart';
import '../../../../screens/cattle_weight_form_screen.dart';
import '../../../../screens/cattle_transfers_screen.dart';
import '../../../../screens/milk_production_form_screen.dart';
import '../list/bovinos_list_screen.dart';
import '../create/bovino_create_screen.dart';
import '../../../../core/di/dependency_injection.dart';
import '../viewmodels/bovinos_viewmodel.dart';

/// Pantalla de menú de Bovinos que centraliza todas las funcionalidades
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
                // Opción 1: Inventario / Lista
                _buildMenuCard(
                  context,
                  icon: Icons.pets,
                  title: 'Inventario / Lista',
                  subtitle: 'Ver y gestionar la lista completa de bovinos',
                  color: Colors.brown,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BovinosListScreen(farmId: farmId),
                      ),
                    );
                  },
                ),

                // Opción 2: Vacunación / Sanidad
                _buildMenuCard(
                  context,
                  icon: Icons.medical_services,
                  title: 'Vacunación / Sanidad',
                  subtitle: 'Registrar y gestionar vacunas y tratamientos',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CattleVaccinesScreen(farm: farm),
                      ),
                    );
                  },
                ),

                // Opción 3: Control de Peso
                _buildMenuCard(
                  context,
                  icon: Icons.monitor_weight,
                  title: 'Control de Peso',
                  subtitle: 'Registrar y monitorear el peso de los animales',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CattleWeightFormScreen(farm: farm),
                      ),
                    );
                  },
                ),

                // Opción 4: Transporte / Movilización
                _buildMenuCard(
                  context,
                  icon: Icons.local_shipping,
                  title: 'Transporte / Movilización',
                  subtitle: 'Gestionar guías de transporte y movilización',
                  color: Colors.purple,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CattleTransfersScreen(farm: farm),
                      ),
                    );
                  },
                ),

                // Opción 5: Producción de Leche
                _buildMenuCard(
                  context,
                  icon: Icons.water_drop,
                  title: 'Producción de Leche',
                  subtitle: 'Registrar y monitorear la producción de leche',
                  color: Colors.cyan,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MilkProductionFormScreen(farm: farm),
                      ),
                    );
                  },
                ),

                // Opción 6: Nuevo Animal
                _buildMenuCard(
                  context,
                  icon: Icons.add_circle,
                  title: 'Nuevo Animal',
                  subtitle: 'Registrar un nuevo bovino en el sistema',
                  color: Colors.green,
                  onTap: () {
                    final viewModel = DependencyInjection.createBovinosViewModel();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider.value(
                          value: viewModel,
                          child: BovinoCreateScreen(farmId: farmId),
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

