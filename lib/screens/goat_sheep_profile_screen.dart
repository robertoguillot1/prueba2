import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';
import '../models/goat_sheep.dart';
import '../models/goat_sheep_vaccine.dart';
import 'goat_sheep_form_screen.dart';
import 'goat_sheep_vaccine_form_screen.dart';

class GoatSheepProfileScreen extends StatelessWidget {
  final Farm farm;
  final GoatSheep animal;

  const GoatSheepProfileScreen({
    super.key,
    required this.farm,
    required this.animal,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<FarmProvider>(
      builder: (context, farmProvider, _child) {
        final updatedFarm = farmProvider.farms.firstWhere(
          (f) => f.id == farm.id,
          orElse: () => farm,
        );

        final updatedAnimal = updatedFarm.goatSheep.firstWhere(
          (a) => a.id == animal.id,
          orElse: () => animal,
        );

        final vaccines = farmProvider.getGoatSheepVaccines(updatedAnimal.id, farmId: updatedFarm.id);

        return Scaffold(
          appBar: AppBar(
            title: Text(updatedAnimal.name ?? updatedAnimal.identification ?? 'Perfil'),
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
                      builder: (context) => GoatSheepFormScreen(
                        farm: updatedFarm,
                        animalToEdit: updatedAnimal,
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
                          (updatedAnimal.name ?? updatedAnimal.identification ?? '?')[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        updatedAnimal.name ?? 'Sin nombre',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (updatedAnimal.identification != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${updatedAnimal.identification}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
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
                                icon: Icons.medical_services,
                                label: 'Registrar Vacuna',
                                onTap: () async {
                                  final result = await Navigator.push<bool>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => GoatSheepVaccineFormScreen(
                                        farm: updatedFarm,
                                        selectedAnimal: updatedAnimal,
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
                                      builder: (context) => GoatSheepFormScreen(
                                        farm: updatedFarm,
                                        animalToEdit: updatedAnimal,
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
                          _buildInfoTile('Tipo', updatedAnimal.typeString),
                          _buildInfoTile('Género', updatedAnimal.genderString),
                          if (updatedAnimal.currentWeight != null)
                            _buildInfoTile('Peso', '${updatedAnimal.currentWeight!.toStringAsFixed(1)} kg'),
                          _buildInfoTile(
                            'Edad',
                            '${DateTime.now().difference(updatedAnimal.birthDate).inDays} días',
                          ),
                          _buildInfoTile(
                            'Fecha de Nacimiento',
                            DateFormat('dd/MM/yyyy').format(updatedAnimal.birthDate),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Información reproductiva (solo para hembras)
                      if (updatedAnimal.gender == GoatSheepGender.female) ...[
                        _buildSection(
                          context,
                          'Información Reproductiva',
                          [
                            if (updatedAnimal.estadoReproductivo != null)
                              _buildInfoTile(
                                'Estado',
                                updatedAnimal.estadoReproductivoString,
                                color: updatedAnimal.estadoReproductivo == EstadoReproductivo.gestante
                                    ? (updatedAnimal.isNearParto
                                        ? Colors.orange
                                        : updatedAnimal.isPastParto
                                            ? Colors.red
                                            : Colors.green)
                                    : null,
                              ),
                            if (updatedAnimal.fechaMonta != null)
                              _buildInfoTile(
                                'Fecha de Monta',
                                DateFormat('dd/MM/yyyy').format(updatedAnimal.fechaMonta!),
                              ),
                            if (updatedAnimal.fechaProbableParto != null) ...[
                              _buildInfoTile(
                                'Fecha Probable de Parto',
                                DateFormat('dd/MM/yyyy').format(updatedAnimal.fechaProbableParto!),
                              ),
                              if (updatedAnimal.diasRestantesParto != null)
                                _buildInfoTile(
                                  'Días Restantes',
                                  updatedAnimal.diasRestantesParto! >= 0
                                      ? '${updatedAnimal.diasRestantesParto} días'
                                      : 'Pasado',
                                  color: updatedAnimal.diasRestantesParto! >= 0 &&
                                          updatedAnimal.diasRestantesParto! <= 10
                                      ? Colors.orange
                                      : updatedAnimal.diasRestantesParto! < 0
                                          ? Colors.red
                                          : Colors.green,
                                ),
                            ],
                            if (updatedAnimal.partosPrevios != null)
                              _buildInfoTile('Partos Previos', '${updatedAnimal.partosPrevios}'),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],

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
                                                builder: (context) => GoatSheepVaccineFormScreen(
                                                  farm: updatedFarm,
                                                  selectedAnimal: updatedAnimal,
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
                                                  builder: (context) => GoatSheepVaccineFormScreen(
                                                    farm: updatedFarm,
                                                    selectedAnimal: updatedAnimal,
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
                                            onPressed: () => _confirmDeleteVaccine(context, vaccine, updatedFarm, updatedAnimal),
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

                      // Observaciones
                      if (updatedAnimal.notes != null && updatedAnimal.notes!.isNotEmpty) ...[
                        _buildSection(
                          context,
                          'Observaciones',
                          [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                updatedAnimal.notes!,
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

  void _confirmDeleteVaccine(BuildContext context, GoatSheepVaccine vaccine, Farm farm, GoatSheep animal) {
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
              await provider.deleteGoatSheepVaccine(vaccine.id, farmId: farm.id);
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

