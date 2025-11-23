import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';
import '../widgets/farm_card.dart';
import 'farm_form_screen.dart';
import 'farm_profile_screen.dart';

class FarmsListScreen extends StatelessWidget {
  const FarmsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Fincas'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FarmFormScreen(),
                ),
              );
            },
            tooltip: 'Agregar finca',
          ),
        ],
      ),
      body: Consumer<FarmProvider>(
        builder: (context, farmProvider, _child) {
          if (farmProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (farmProvider.farms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.agriculture,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay fincas registradas',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '¡Agrega tu primera finca para empezar a gestionar!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FarmFormScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar Nueva Finca'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: farmProvider.loadFarms,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gestiona tus fincas',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: farmProvider.farms.length,
                      itemBuilder: (context, index) {
                        final farm = farmProvider.farms[index];
                        final isCurrentFarm = farmProvider.currentFarm?.id == farm.id;
                        
                        return FarmCard(
                          farm: farm,
                          isCurrentFarm: isCurrentFarm,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FarmProfileScreen(farm: farm),
                              ),
                            );
                          },
                          onEdit: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FarmFormScreen(farmToEdit: farm),
                              ),
                            );
                          },
                          onSetCurrent: () async {
                            await farmProvider.setCurrentFarm(farm.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Finca "${farm.name}" establecida como actual'),
                              ),
                            );
                          },
                          onDelete: () => _confirmDelete(context, farmProvider, farm),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FarmFormScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Agregar Finca'),
      ),
    );
  }

  void _confirmDelete(BuildContext context, FarmProvider farmProvider, Farm farm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Finca'),
        content: Text(
          '¿Estás seguro de que quieres eliminar la finca "${farm.name}"?\n\n'
          'Esta acción eliminará todos los datos asociados:\n'
          '• ${farm.workers.length} trabajadores\n'
          '• ${farm.payments.length} pagos\n'
          '• ${farm.loans.length} préstamos\n\n'
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await farmProvider.deleteFarm(farm.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Finca "${farm.name}" eliminada'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}