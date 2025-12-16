import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';
import '../models/pig.dart';
import '../models/weight_record.dart';
import 'weight_record_form_screen.dart';

class WeightHistoryScreen extends StatelessWidget {
  final Farm farm;

  const WeightHistoryScreen({super.key, required this.farm});

  @override
  Widget build(BuildContext context) {
    return Consumer<FarmProvider>(
      builder: (context, farmProvider, _child) {
        final updatedFarm = farmProvider.farms.firstWhere(
          (f) => f.id == farm.id,
          orElse: () => farm,
        );

        return Scaffold(
          appBar: AppBar(
            title: const Text('📊 Historial de Pesos'),
            centerTitle: true,
            backgroundColor: updatedFarm.primaryColor,
            foregroundColor: Colors.white,
          ),
          body: updatedFarm.pigs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.monitor_weight, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text(
                        'No hay cerdos registrados',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Agrega cerdos para registrar pesos',
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
                        'Selecciona un cerdo para ver su historial de pesos',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: updatedFarm.pigs.length,
                        itemBuilder: (context, index) {
                          final pig = updatedFarm.pigs[index];
                          final pigRecords = updatedFarm.weightRecords
                              .where((r) => r.pigId == pig.id)
                              .toList()
                            ..sort((a, b) => a.recordDate.compareTo(b.recordDate));

                          return _buildPigWeightCard(
                            context,
                            pig,
                            pigRecords,
                            updatedFarm,
                          );
                        },
                      ),
                    ),
                  ],
                ),
          floatingActionButton: updatedFarm.pigs.isEmpty
              ? null
              : FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WeightRecordFormScreen(farm: updatedFarm),
                      ),
                    );
                  },
                  backgroundColor: updatedFarm.primaryColor,
                  icon: const Icon(Icons.add),
                  label: const Text('Registrar Peso'),
                ),
        );
      },
    );
  }

  Widget _buildPigWeightCard(
    BuildContext context,
    Pig pig,
    List<WeightRecord> records,
    Farm farm,
  ) {
    final sortedRecords = records.toList()
      ..sort((a, b) => b.recordDate.compareTo(a.recordDate));

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: farm.primaryColor.withValues(alpha: 0.1),
          child: Text(
            pig.identification?.substring(0, 1).toUpperCase() ?? '🐷',
            style: TextStyle(color: farm.primaryColor),
          ),
        ),
        title: Text(
          pig.identification ?? 'Sin ID',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Peso actual: ${pig.currentWeight.toStringAsFixed(1)} kg'),
            Text(
              '${records.length} registro(s)',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        children: [
          if (records.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'No hay registros de peso para este cerdo',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ...sortedRecords.map((record) {
              final previousRecord = records
                  .where((r) => r.recordDate.isBefore(record.recordDate))
                  .toList();
              final previousWeight = previousRecord.isNotEmpty
                  ? previousRecord.last.weight
                  : null;
              final gain = previousWeight != null
                  ? record.weight - previousWeight
                  : null;
              final daysDiff = previousRecord.isNotEmpty
                  ? record.recordDate.difference(previousRecord.last.recordDate).inDays
                  : null;
              final dailyGain = gain != null && daysDiff != null && daysDiff > 0
                  ? gain / daysDiff
                  : null;

              return ListTile(
                leading: const Icon(Icons.monitor_weight, color: Colors.blue),
                title: Text(
                  '${record.weight.toStringAsFixed(1)} kg',
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
                          'Ganancia diaria promedio: ${dailyGain.toStringAsFixed(2)} kg/día',
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
                      final farmProvider = Provider.of<FarmProvider>(context, listen: false);
                      await farmProvider.deleteWeightRecord(record.id);
                    }
                  },
                ),
              );
            }),
        ],
      ),
    );
  }
}


