import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';
import '../models/pig_vaccine.dart';
import '../models/pig.dart';
import 'pig_vaccine_form_screen.dart';
import 'pig_profile_screen.dart';

class PigVaccinesScreen extends StatelessWidget {
  final Farm farm;

  const PigVaccinesScreen({super.key, required this.farm});

  @override
  Widget build(BuildContext context) {
    return Consumer<FarmProvider>(
      builder: (context, farmProvider, _child) {
        final updatedFarm = farmProvider.farms.firstWhere(
          (f) => f.id == farm.id,
          orElse: () => farm,
        );

        final vaccines = updatedFarm.pigVaccines.toList()
          ..sort((a, b) => b.date.compareTo(a.date));

        // Obtener vacunas próximas a vencer
        final upcomingVaccines = vaccines
            .where((v) => v.nextDoseDate != null && v.nextDoseDate!.isAfter(DateTime.now()))
            .toList()
          ..sort((a, b) => a.nextDoseDate!.compareTo(b.nextDoseDate!));

        return Scaffold(
          appBar: AppBar(
            title: const Text('💉 Control de Vacunación'),
            centerTitle: true,
            backgroundColor: farm.primaryColor,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PigVaccineFormScreen(
                        farm: updatedFarm,
                      ),
                    ),
                  );
                },
                tooltip: 'Registrar Vacuna',
              ),
            ],
          ),
          body: Column(
            children: [
              // Alertas de próximas vacunas
              if (upcomingVaccines.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.orange.withOpacity(0.1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.schedule, color: Colors.orange[700]),
                          const SizedBox(width: 8),
                          Text(
                            'Próximas Vacunas',
                            style: TextStyle(
                              color: Colors.orange[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...upcomingVaccines.take(3).map((vaccine) {
                        final pig = updatedFarm.pigs.firstWhere(
                          (p) => p.id == vaccine.pigId,
                          orElse: () => Pig(
                            id: '',
                            identification: 'Desconocido',
                            birthDate: DateTime.now(),
                            gender: PigGender.male,
                            feedingStage: FeedingStage.inicio,
                            currentWeight: 0,
                            farmId: '',
                            updatedAt: DateTime.now(),
                          ),
                        );
                        final daysUntil = vaccine.nextDoseDate!.difference(DateTime.now()).inDays;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${pig.identification ?? "Sin ID"} - ${vaccine.vaccineName}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              Text(
                                daysUntil <= 7
                                    ? '⚠️ En ${daysUntil} días'
                                    : 'En ${daysUntil} días',
                                style: TextStyle(
                                  color: daysUntil <= 7 ? Colors.red : Colors.orange[700],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),

              // Lista de vacunas
              Expanded(
                child: vaccines.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.medical_services_outlined, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No hay vacunas registradas',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Toca el botón + para registrar una vacuna',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[500],
                                  ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: vaccines.length,
                        itemBuilder: (context, index) {
                          final vaccine = vaccines[index];
                          final pig = updatedFarm.pigs.firstWhere(
                            (p) => p.id == vaccine.pigId,
                            orElse: () => Pig(
                              id: '',
                              identification: 'Desconocido',
                              birthDate: DateTime.now(),
                              gender: PigGender.male,
                              feedingStage: FeedingStage.inicio,
                              currentWeight: 0,
                              farmId: '',
                              updatedAt: DateTime.now(),
                            ),
                          );
                          return _buildVaccineCard(context, vaccine, pig, updatedFarm);
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PigVaccineFormScreen(
                    farm: updatedFarm,
                  ),
                ),
              );
            },
            backgroundColor: farm.primaryColor,
            icon: const Icon(Icons.add),
            label: const Text('Registrar Vacuna'),
          ),
        );
      },
    );
  }

  Widget _buildVaccineCard(BuildContext context, PigVaccine vaccine, Pig pig, Farm farm) {
    final isUpcoming = vaccine.nextDoseDate != null &&
        vaccine.nextDoseDate!.isAfter(DateTime.now()) &&
        vaccine.nextDoseDate!.difference(DateTime.now()).inDays <= 30;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PigProfileScreen(
                farm: farm,
                pig: pig,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.medical_services, color: Colors.green, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vaccine.vaccineName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.pets, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              pig.identification ?? 'Sin ID',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (isUpcoming)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.schedule, size: 14, color: Colors.orange[700]),
                          const SizedBox(width: 4),
                          Text(
                            'Próxima: ${DateFormat('dd/MM/yyyy').format(vaccine.nextDoseDate!)}',
                            style: TextStyle(
                              color: Colors.orange[700],
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Aplicada: ${DateFormat('dd/MM/yyyy').format(vaccine.date)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                  if (vaccine.batchNumber != null) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.numbers, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Lote: ${vaccine.batchNumber}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
              if (vaccine.observations != null && vaccine.observations!.isNotEmpty) ...[
                const SizedBox(height: 8),
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
                          style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PigVaccineFormScreen(
                            farm: farm,
                            selectedPig: pig,
                            vaccineToEdit: vaccine,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Editar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

