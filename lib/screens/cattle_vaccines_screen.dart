import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';
import 'cattle_vaccine_form_screen.dart';

class CattleVaccinesScreen extends StatelessWidget {
  final Farm farm;

  const CattleVaccinesScreen({super.key, required this.farm});

  @override
  Widget build(BuildContext context) {
    return Consumer<FarmProvider>(
      builder: (context, farmProvider, _child) {
        final updatedFarm = farmProvider.farms.firstWhere(
          (f) => f.id == farm.id,
          orElse: () => farm,
        );

        final vaccines = updatedFarm.cattleVaccines.toList()
          ..sort((a, b) => b.applicationDate.compareTo(a.applicationDate));

        // Obtener vacunas próximas a vencer
        final upcomingVaccines = vaccines
            .where((v) => v.nextDoseDate != null && v.nextDoseDate!.isAfter(DateTime.now()))
            .toList()
          ..sort((a, b) => a.nextDoseDate!.compareTo(b.nextDoseDate!));

        return Scaffold(
          appBar: AppBar(
            title: const Text('💉 Historial de Vacunas'),
            centerTitle: true,
            backgroundColor: farm.primaryColor,
            foregroundColor: Colors.white,
          ),
          body: vaccines.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.medical_services, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text(
                        'No hay vacunas registradas',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Agrega vacunas para tu ganado',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Próximas vacunas
                    if (upcomingVaccines.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: Colors.orange[50],
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.warning, color: Colors.orange[700]),
                                const SizedBox(width: 8),
                                Text(
                                  'Próximas vacunas (${upcomingVaccines.length})',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange[700],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...upcomingVaccines.take(3).map((vaccine) {
                              final animal = updatedFarm.cattle
                                  .firstWhere((c) => c.id == vaccine.cattleId, orElse: () => updatedFarm.cattle.first);
                              
                              return ListTile(
                                dense: true,
                                leading: const Icon(Icons.warning_amber, color: Colors.orange),
                                title: Text(
                                  vaccine.vaccineName,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  '${animal.name ?? animal.identification ?? "Animal"} - ${DateFormat('dd/MM/yyyy').format(vaccine.nextDoseDate!)}',
                                ),
                              );
                            }),
                            if (upcomingVaccines.length > 3)
                              Text(
                                'Y ${upcomingVaccines.length - 3} más...',
                                style: TextStyle(color: Colors.orange[700]),
                              ),
                          ],
                        ),
                      ),
                    
                    // Historial completo
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: vaccines.length,
                        itemBuilder: (context, index) {
                          final vaccine = vaccines[index];
                          final animal = updatedFarm.cattle
                              .firstWhere(
                                (c) => c.id == vaccine.cattleId,
                                orElse: () => updatedFarm.cattle.first,
                              );
                          
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: CircleAvatar(
                                backgroundColor: farm.primaryColor.withValues(alpha: 0.1),
                                child: Icon(Icons.medical_services, color: farm.primaryColor),
                              ),
                              title: Text(
                                vaccine.vaccineName,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    'Animal: ${animal.name ?? animal.identification ?? "Sin ID"}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Fecha: ${DateFormat('dd/MM/yyyy').format(vaccine.applicationDate)}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  ),
                                  if (vaccine.nextDoseDate != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Próxima: ${DateFormat('dd/MM/yyyy').format(vaccine.nextDoseDate!)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: vaccine.nextDoseDate!.isAfter(DateTime.now())
                                            ? Colors.orange
                                            : Colors.red,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              trailing: PopupMenuButton(
                                icon: const Icon(Icons.more_vert),
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Eliminar', style: TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ],
                                onSelected: (value) async {
                                  if (value == 'delete') {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Eliminar vacuna'),
                                        content: const Text('¿Eliminar este registro de vacuna?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('Cancelar'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      await farmProvider.deleteCattleVaccine(vaccine.id);
                                    }
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: updatedFarm.cattle.isEmpty
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CattleVaccineFormScreen(farm: updatedFarm),
                      ),
                    );
                  },
            backgroundColor: farm.primaryColor,
            icon: const Icon(Icons.add),
            label: const Text('Nueva Vacuna'),
          ),
        );
      },
    );
  }
}
