import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';
import 'cattle_weight_form_screen.dart';

class CattleWeightsScreen extends StatelessWidget {
  final Farm farm;

  const CattleWeightsScreen({super.key, required this.farm});

  @override
  Widget build(BuildContext context) {
    return Consumer<FarmProvider>(
      builder: (context, farmProvider, _child) {
        final updatedFarm = farmProvider.farms.firstWhere(
          (f) => f.id == farm.id,
          orElse: () => farm,
        );

        final records = updatedFarm.cattleWeightRecords.toList()
          ..sort((a, b) => b.recordDate.compareTo(a.recordDate));

        return Scaffold(
          appBar: AppBar(
            title: const Text('📊 Control de Pesos'),
            centerTitle: true,
            backgroundColor: farm.primaryColor,
            foregroundColor: Colors.white,
          ),
          body: updatedFarm.cattle.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.trending_up, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text(
                        'No hay animales registrados',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Agrega animales para registrar pesos',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Selecciona un animal para ver su historial de pesos',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: updatedFarm.cattle.length,
                        itemBuilder: (context, index) {
                          final cattle = updatedFarm.cattle[index];
                          final cattleRecords = records
                              .where((r) => r.cattleId == cattle.id)
                              .toList()
                            ..sort((a, b) => a.recordDate.compareTo(b.recordDate));

                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                backgroundColor: farm.primaryColor.withValues(alpha: 0.1),
                                child: Text(
                                  cattle.name?.substring(0, 1).toUpperCase() ?? 
                                  cattle.identification?.substring(0, 1).toUpperCase() ?? 
                                  '🐄',
                                  style: TextStyle(color: farm.primaryColor),
                                ),
                              ),
                              title: Text(
                                cattle.name ?? cattle.identification ?? 'Sin ID',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Peso actual: ${cattle.currentWeight.toStringAsFixed(0)} kg'),
                                  Text(
                                    '${cattleRecords.length} registro(s)',
                                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                  ),
                                ],
                              ),
                              children: [
                                if (cattleRecords.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Text(
                                      'No hay registros de peso para este animal',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  )
                                else
                                  ...cattleRecords.reversed.map((record) {
                                    final previousRecords = cattleRecords
                                        .where((r) => r.recordDate.isBefore(record.recordDate))
                                        .toList();
                                    final previousWeight = previousRecords.isNotEmpty
                                        ? previousRecords.last.weight
                                        : null;
                                    final gain = previousWeight != null
                                        ? record.weight - previousWeight
                                        : null;
                                    final daysDiff = previousRecords.isNotEmpty
                                        ? record.recordDate.difference(previousRecords.last.recordDate).inDays
                                        : null;
                                    final dailyGain = gain != null && daysDiff != null && daysDiff > 0
                                        ? gain / daysDiff
                                        : null;

                                    return ListTile(
                                      leading: const Icon(Icons.monitor_weight, color: Colors.blue),
                                      title: Text(
                                        '${record.weight.toStringAsFixed(0)} kg',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(DateFormat('dd/MM/yyyy').format(record.recordDate)),
                                          if (gain != null && daysDiff != null) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              'Ganancia: ${gain > 0 ? '+' : ''}${gain.toStringAsFixed(1)} kg en $daysDiff días',
                                              style: TextStyle(
                                                color: gain > 0 ? Colors.green : Colors.red,
                                                fontSize: 12,
                                              ),
                                            ),
                                            if (dailyGain != null)
                                              Text(
                                                'Promedio diario: ${dailyGain.toStringAsFixed(2)} kg/día',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 11,
                                                ),
                                              ),
                                          ],
                                        ],
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Eliminar registro'),
                                              content: const Text('¿Eliminar este registro de peso?'),
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
                                            await farmProvider.deleteCattleWeightRecord(record.id);
                                          }
                                        },
                                      ),
                                    );
                                  }),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
          floatingActionButton: updatedFarm.cattle.isEmpty
              ? null
              : FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CattleWeightFormScreen(farm: updatedFarm),
                      ),
                    );
                  },
                  backgroundColor: farm.primaryColor,
                  icon: const Icon(Icons.add),
                  label: const Text('Registrar Peso'),
                ),
        );
      },
    );
  }
}
