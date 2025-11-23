import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';
import '../models/worker.dart';
import '../widgets/worker_card.dart';
import 'worker_form_screen.dart';
import 'worker_profile_screen.dart';

class WorkersListScreen extends StatelessWidget {
  final Farm farm;

  const WorkersListScreen({super.key, required this.farm});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trabajadores - ${farm.name}'),
        centerTitle: true,
        backgroundColor: farm.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<FarmProvider>(
        builder: (context, farmProvider, _child) {
          // Get the updated farm from provider to ensure we see the latest workers
          final updatedFarm = farmProvider.farms.firstWhere(
            (f) => f.id == farm.id,
            orElse: () => farm,
          );
          final workers = updatedFarm.activeWorkers;
          
          if (workers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay trabajadores registrados',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '¡Agrega el primer trabajador para empezar!',
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
                          builder: (context) => WorkerFormScreen(farm: farm),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar Trabajador'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: farm.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar trabajadores...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onChanged: (value) {
                    // Search functionality will be implemented with a stateful widget
                  },
                ),
              ),
              
              // Workers list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: workers.length,
                  itemBuilder: (context, index) {
                    final worker = workers[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: WorkerCard(
                        worker: worker,
                        farm: farm,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WorkerProfileScreen(
                                worker: worker,
                                farm: farm,
                              ),
                            ),
                          );
                        },
                        onEdit: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WorkerFormScreen(
                                farm: farm,
                                workerToEdit: worker,
                              ),
                            ),
                          );
                        },
                        onDelete: () => _confirmDelete(context, farmProvider, worker),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WorkerFormScreen(farm: farm),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Agregar Trabajador'),
        backgroundColor: farm.primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _confirmDelete(BuildContext context, FarmProvider farmProvider, Worker worker) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Trabajador'),
        content: Text(
          '¿Estás seguro de que quieres eliminar a "${worker.fullName}"?\n\n'
          'Esta acción eliminará todos los datos asociados:\n'
          '• Historial de pagos\n'
          '• Historial de préstamos\n\n'
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await farmProvider.deleteWorker(worker.id, farmId: farm.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Trabajador "${worker.fullName}" eliminado'),
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
