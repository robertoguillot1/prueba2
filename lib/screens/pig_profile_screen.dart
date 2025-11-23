import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';
import '../models/pig.dart';
import '../models/weight_record.dart';
import '../models/pig_vaccine.dart';
import 'pig_form_screen.dart';
import 'weight_record_form_screen.dart';
import 'pig_vaccine_form_screen.dart';

class PigProfileScreen extends StatelessWidget {
  final Farm farm;
  final Pig pig;

  const PigProfileScreen({
    super.key,
    required this.farm,
    required this.pig,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<FarmProvider>(
      builder: (context, farmProvider, _child) {
        final updatedFarm = farmProvider.farms.firstWhere(
          (f) => f.id == farm.id,
          orElse: () => farm,
        );

        final updatedPig = updatedFarm.pigs.firstWhere(
          (p) => p.id == pig.id,
          orElse: () => pig,
        );

        final weightRecords = farmProvider.getWeightRecordsForPig(updatedPig.id, farmId: updatedFarm.id);
        final vaccines = farmProvider.getPigVaccines(updatedPig.id, farmId: updatedFarm.id);

        return Scaffold(
          appBar: AppBar(
            title: Text(updatedPig.identification ?? 'Perfil'),
            centerTitle: true,
            backgroundColor: farm.primaryColor,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PigFormScreen(
                        farm: updatedFarm,
                        pigToEdit: updatedPig,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Header
                Container(
                  decoration: BoxDecoration(
                    color: farm.primaryColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: Text(
                          (updatedPig.identification ?? '?')[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        updatedPig.identification ?? 'Sin ID',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // Información
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Acciones rápidas
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildActionButton(
                                context,
                                icon: Icons.monitor_weight,
                                label: 'Registrar Peso',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WeightRecordFormScreen(
                                        farm: updatedFarm,
                                        selectedPig: updatedPig,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              _buildActionButton(
                                context,
                                icon: Icons.medical_services,
                                label: 'Registrar Vacuna',
                                onTap: () async {
                                  final result = await Navigator.push<bool>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PigVaccineFormScreen(
                                        farm: updatedFarm,
                                        selectedPig: updatedPig,
                                      ),
                                    ),
                                  );
                                  if (result == true && context.mounted) {
                                    // Refrescar datos
                                  }
                                },
                              ),
                              _buildActionButton(
                                context,
                                icon: Icons.edit,
                                label: 'Editar',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PigFormScreen(
                                        farm: updatedFarm,
                                        pigToEdit: updatedPig,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Información básica
                      _buildSection(
                        context,
                        'Información Básica',
                        [
                          _buildInfoTile('Género', updatedPig.genderString),
                          _buildInfoTile('Peso Actual', '${updatedPig.currentWeight.toStringAsFixed(1)} kg'),
                          _buildInfoTile(
                            'Etapa de Alimentación',
                            updatedPig.feedingStageString,
                            color: _getStageColor(updatedPig.feedingStage),
                          ),
                          _buildInfoTile(
                            'Consumo Diario Estimado',
                            '${updatedPig.estimatedDailyConsumption.toStringAsFixed(2)} kg/día',
                          ),
                          _buildInfoTile(
                            'Edad',
                            '${updatedPig.ageInDays} días',
                          ),
                          _buildInfoTile(
                            'Fecha de Nacimiento',
                            DateFormat('dd/MM/yyyy').format(updatedPig.birthDate),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Historial de pesos
                      _buildSection(
                        context,
                        'Historial de Pesos',
                        weightRecords.isEmpty
                            ? [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Center(
                                    child: Text(
                                      'No hay registros de peso',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ),
                                ),
                              ]
                            : weightRecords.take(10).map((record) {
                                return ListTile(
                                  leading: const Icon(Icons.monitor_weight),
                                  title: Text('${record.weight.toStringAsFixed(1)} kg'),
                                  subtitle: Text(DateFormat('dd/MM/yyyy').format(record.recordDate)),
                                  trailing: record.notes != null
                                      ? Icon(Icons.note, size: 20, color: Colors.grey[600])
                                      : null,
                                );
                              }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Historial de vacunas
                      _buildSection(
                        context,
                        'Historial de Vacunación',
                        vaccines.isEmpty
                            ? [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Icon(Icons.medical_services_outlined, size: 48, color: Colors.grey[400]),
                                        const SizedBox(height: 8),
                                        Text(
                                          'No hay vacunas registradas',
                                          style: TextStyle(color: Colors.grey[600]),
                                        ),
                                        const SizedBox(height: 8),
                                        ElevatedButton.icon(
                                          onPressed: () async {
                                            final result = await Navigator.push<bool>(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => PigVaccineFormScreen(
                                                  farm: updatedFarm,
                                                  selectedPig: updatedPig,
                                                ),
                                              ),
                                            );
                                            if (result == true && context.mounted) {
                                              // Refrescar datos
                                            }
                                          },
                                          icon: const Icon(Icons.add),
                                          label: const Text('Registrar Primera Vacuna'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: farm.primaryColor,
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ]
                            : [
                                ...vaccines.map((vaccine) {
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      leading: const Icon(Icons.medical_services, color: Colors.green),
                                      title: Text(
                                        vaccine.vaccineName,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(DateFormat('dd/MM/yyyy').format(vaccine.date)),
                                          if (vaccine.batchNumber != null)
                                            Text('Lote: ${vaccine.batchNumber}'),
                                          if (vaccine.nextDoseDate != null)
                                            Text(
                                              'Próxima dosis: ${DateFormat('dd/MM/yyyy').format(vaccine.nextDoseDate!)}',
                                              style: TextStyle(color: Colors.blue[700]),
                                            ),
                                          if (vaccine.observations != null && vaccine.observations!.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Icon(Icons.note, size: 14, color: Colors.blue[700]),
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: Text(
                                                      vaccine.observations!,
                                                      style: TextStyle(fontSize: 11, color: Colors.grey[800]),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, size: 18),
                                            onPressed: () async {
                                              final result = await Navigator.push<bool>(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => PigVaccineFormScreen(
                                                    farm: updatedFarm,
                                                    selectedPig: updatedPig,
                                                    vaccineToEdit: vaccine,
                                                  ),
                                                ),
                                              );
                                              if (result == true && context.mounted) {
                                                // Refrescar datos
                                              }
                                            },
                                            tooltip: 'Editar',
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                                            onPressed: () => _confirmDeleteVaccine(context, vaccine, updatedFarm, updatedPig),
                                            tooltip: 'Eliminar',
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ],
                      ),
                      const SizedBox(height: 16),

                      // Notas
                      if (updatedPig.notes != null && updatedPig.notes!.isNotEmpty) ...[
                        _buildSection(
                          context,
                          'Notas',
                          [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                updatedPig.notes!,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color ?? Colors.black87,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: farm.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: farm.primaryColor.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: farm.primaryColor, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: farm.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStageColor(FeedingStage stage) {
    switch (stage) {
      case FeedingStage.inicio:
        return Colors.green;
      case FeedingStage.levante:
        return Colors.orange;
      case FeedingStage.engorde:
        return Colors.red;
    }
  }

  void _confirmDeleteVaccine(BuildContext context, PigVaccine vaccine, Farm farm, Pig pig) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Vacuna'),
        content: Text('¿Está seguro de que desea eliminar el registro de vacuna "${vaccine.vaccineName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final provider = Provider.of<FarmProvider>(context, listen: false);
              await provider.deletePigVaccine(vaccine.id, farmId: farm.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Vacuna eliminada')),
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

