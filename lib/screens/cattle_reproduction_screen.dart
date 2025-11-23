import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';
import '../models/cattle.dart';
import 'cattle_reproduction_form_screen.dart';

class CattleReproductionScreen extends StatelessWidget {
  final Farm farm;

  const CattleReproductionScreen({super.key, required this.farm});

  @override
  Widget build(BuildContext context) {
    return Consumer<FarmProvider>(
      builder: (context, farmProvider, _child) {
        final updatedFarm = farmProvider.farms.firstWhere(
          (f) => f.id == farm.id,
          orElse: () => farm,
        );

        final females = updatedFarm.cattle
            .where((c) => c.gender == CattleGender.female)
            .toList();

        // Hembras en gestación
        final pregnantCows = females
            .where((c) => c.breedingStatus == BreedingStatus.prenada)
            .toList();

        // Hembras próximas a parir (menos de 30 días)
        final upcomingCalvings = females
            .where((c) =>
                c.expectedCalvingDate != null &&
                c.expectedCalvingDate!.difference(DateTime.now()).inDays <= 30 &&
                c.expectedCalvingDate!.difference(DateTime.now()).inDays >= 0)
            .toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('🔴 Control Reproductivo'),
            centerTitle: true,
            backgroundColor: farm.primaryColor,
            foregroundColor: Colors.white,
          ),
          body: females.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.child_care, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text(
                        'No hay hembras registradas',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Registra hembras para control reproductivo',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: farmProvider.loadFarms,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Próximos partos
                        if (upcomingCalvings.isNotEmpty) ...[
                          Card(
                            color: Colors.orange[50],
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.warning, color: Colors.orange[700]),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Próximos Partos (${upcomingCalvings.length})',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  ...upcomingCalvings.map((cow) {
                                    final daysLeft = cow.expectedCalvingDate!.difference(DateTime.now()).inDays;
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.orange[200]!),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  cow.name ?? cow.identification ?? 'Sin ID',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  cow.expectedCalvingDate != null
                                                      ? DateFormat('dd/MM/yyyy').format(cow.expectedCalvingDate!)
                                                      : 'No especificada',
                                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: daysLeft <= 7 ? Colors.red[100] : Colors.orange[100],
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              '$daysLeft días',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: daysLeft <= 7 ? Colors.red : Colors.orange,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Hembras en gestación
                        Text(
                          'Hembras en Gestación (${pregnantCows.length})',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        ...pregnantCows.map((cow) => _buildCowCard(context, cow)),

                        const SizedBox(height: 24),

                        // Todas las hembras
                        Text(
                          'Todas las Hembras (${females.length})',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        ...females.map((cow) => _buildCowCard(context, cow)),
                      ],
                    ),
                  ),
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: females.isEmpty
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CattleReproductionFormScreen(farm: updatedFarm),
                      ),
                    );
                  },
            backgroundColor: farm.primaryColor,
            icon: const Icon(Icons.edit),
            label: const Text('Actualizar Estado'),
          ),
        );
      },
    );
  }

  Widget _buildCowCard(BuildContext context, Cattle cow) {
    final statusColor = cow.breedingStatus == BreedingStatus.prenada
        ? Colors.green
        : cow.breedingStatus == BreedingStatus.vacia
            ? Colors.purple
            : cow.breedingStatus == BreedingStatus.lactante
                ? Colors.blue
                : Colors.grey;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(
            cow.breedingStatus == BreedingStatus.prenada
                ? Icons.pregnant_woman
                : cow.breedingStatus == BreedingStatus.vacia
                    ? Icons.favorite
                    : cow.breedingStatus == BreedingStatus.lactante
                        ? Icons.child_care
                                            : Icons.pets,
            color: statusColor,
          ),
        ),
        title: Text(
          cow.name ?? cow.identification ?? 'Sin ID',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Estado: ${cow.breedingStatusString}'),
            if (cow.expectedCalvingDate != null)
              Text(
                'Parto estimado: ${DateFormat('dd/MM/yyyy').format(cow.expectedCalvingDate!)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            if (cow.previousCalvings != null)
              Text(
                'Partos anteriores: ${cow.previousCalvings}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
          ],
        ),
      ),
    );
  }
}
