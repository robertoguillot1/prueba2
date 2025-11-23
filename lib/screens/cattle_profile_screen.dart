import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';
import '../models/cattle.dart';
import '../models/milk_production.dart';
import '../models/reproduction_event.dart';
import '../utils/constants.dart';
import 'cattle_form_screen.dart';
import 'cattle_vaccine_form_screen.dart';
import 'cattle_weight_form_screen.dart';
import 'milk_production_form_screen.dart';
import 'reproductive_checkup_screen.dart';
import 'cattle_weight_production_screen.dart';

class CattleProfileScreen extends StatelessWidget {
  final Farm farm;
  final Cattle cattle;

  const CattleProfileScreen({
    super.key,
    required this.farm,
    required this.cattle,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<FarmProvider>(
      builder: (context, farmProvider, _child) {
        final updatedFarm = farmProvider.farms.firstWhere(
          (f) => f.id == farm.id,
          orElse: () => farm,
        );

        final cattleVaccines = updatedFarm.cattleVaccines
            .where((v) => v.cattleId == cattle.id)
            .toList()
          ..sort((a, b) => b.applicationDate.compareTo(a.applicationDate));

        final weightRecords = updatedFarm.cattleWeightRecords
            .where((r) => r.cattleId == cattle.id)
            .toList()
          ..sort((a, b) => b.recordDate.compareTo(a.recordDate));

        final transfers = updatedFarm.cattleTransfers
            .where((t) => t.cattleId == cattle.id)
            .toList()
          ..sort((a, b) => b.transferDate.compareTo(a.transferDate));

        // Producción de leche (solo para hembras)
        final milkRecords = cattle.gender == CattleGender.female
            ? farmProvider.getMilkProductionRecords(cattle.id, farmId: updatedFarm.id)
            : <MilkProduction>[];

        // Obtener hijos de la vaca (solo para hembras)
        final children = cattle.gender == CattleGender.female
            ? _getChildren(cattle, updatedFarm, farmProvider)
            : <Cattle>[];

        return Scaffold(
          appBar: AppBar(
            title: Text(cattle.name ?? cattle.identification ?? 'Perfil'),
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
                      builder: (context) => CattleFormScreen(
                        farm: updatedFarm,
                        cattleToEdit: cattle,
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
                // Información básica
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
                          (cattle.name ?? cattle.identification ?? '?')[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        cattle.name ?? 'Sin nombre',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (cattle.identification != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${cattle.identification}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Sección de información
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Datos básicos
                      _buildSection(
                        context,
                        'Información Básica',
                        [
                          _buildInfoTile('Categoría', cattle.categoryString),
                          _buildInfoTile('Género', cattle.genderString),
                          _buildInfoTile('Etapa', cattle.productionStageString),
                          _buildInfoTile('Peso', '${cattle.currentWeight.toStringAsFixed(1)} kg'),
                          _buildInfoTile(
                            'Edad',
                            '${cattle.ageInYears} años',
                          ),
                          _buildInfoTile('Salud', cattle.healthStatusString),
                          if (cattle.breedingStatus != null)
                            _buildInfoTile('Estado reproductivo', cattle.breedingStatusString),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Información de gestación (solo para hembras gestantes)
                      if (cattle.gender == CattleGender.female && 
                          cattle.breedingStatus == BreedingStatus.prenada) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cattle.needsSpecialCare
                                ? (cattle.isVeryCloseToCalving 
                                    ? Colors.red.shade50 
                                    : Colors.orange.shade50)
                                : Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: cattle.needsSpecialCare
                                  ? (cattle.isVeryCloseToCalving 
                                      ? Colors.red.shade300 
                                      : Colors.orange.shade300)
                                  : Colors.blue.shade300,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    cattle.needsSpecialCare 
                                        ? Icons.warning_amber_rounded 
                                        : Icons.pregnant_woman,
                                    color: cattle.needsSpecialCare
                                        ? (cattle.isVeryCloseToCalving 
                                            ? Colors.red.shade700 
                                            : Colors.orange.shade700)
                                        : Colors.blue.shade700,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Estado de Gestación',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: cattle.needsSpecialCare
                                                ? (cattle.isVeryCloseToCalving 
                                                    ? Colors.red.shade700 
                                                    : Colors.orange.shade700)
                                                : Colors.blue.shade700,
                                          ),
                                        ),
                                        Text(
                                          cattle.gestationMonthString,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (cattle.needsSpecialCare) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.warning_amber_rounded,
                                        color: cattle.isVeryCloseToCalving 
                                            ? Colors.red 
                                            : Colors.orange,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              cattle.isVeryCloseToCalving
                                                  ? '⚠️ MUY PRÓXIMA A PARIR'
                                                  : '⚠️ REQUIERE CUIDADO ESPECIAL',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: cattle.isVeryCloseToCalving 
                                                    ? Colors.red.shade700 
                                                    : Colors.orange.shade700,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Esta vaca necesita atención especial debido a su proximidad al parto.',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              if (cattle.expectedCalvingDate != null) ...[
                                const SizedBox(height: 12),
                                _buildInfoTile(
                                  'Fecha estimada de parto',
                                  DateFormat('dd/MM/yyyy').format(cattle.expectedCalvingDate!),
                                ),
                                if (cattle.daysUntilCalving != null)
                                  _buildInfoTile(
                                    'Días hasta el parto',
                                    '${cattle.daysUntilCalving} días',
                                  ),
                                if (cattle.inseminationDate != null)
                                  _buildInfoTile(
                                    'Fecha de inseminación',
                                    DateFormat('dd/MM/yyyy').format(cattle.inseminationDate!),
                                  ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Acciones rápidas (solo para hembras)
                      if (cattle.gender == CattleGender.female) ...[
                        Row(
                          children: [
                            Expanded(
                              child: _buildActionCard(
                                context,
                                'Reproducción',
                                Icons.favorite,
                                Colors.pink,
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ReproductiveCheckupScreen(
                                        farm: updatedFarm,
                                        cattle: cattle,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildActionCard(
                                context,
                                'Producción',
                                Icons.trending_up,
                                Colors.blue,
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CattleWeightProductionScreen(
                                        farm: updatedFarm,
                                        cattle: cattle,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Vacunas
                      _buildSection(
                        context,
                        'Vacunas (${cattleVaccines.length})',
                        cattleVaccines.isEmpty
                            ? [
                                const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                    'No hay vacunas registradas',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ]
                            : cattleVaccines.take(3).map((vaccine) {
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Icon(
                                    Icons.medical_services,
                                    color: farm.primaryColor,
                                  ),
                                  title: Text(vaccine.vaccineName),
                                  subtitle: Text(
                                    'Aplicada: ${DateFormat('dd/MM/yyyy').format(vaccine.applicationDate)}',
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                );
                              }).toList(),
                        actionIcon: Icons.add,
                        onAction: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CattleVaccineFormScreen(
                                farm: updatedFarm,
                                selectedCattle: cattle,
                              ),
                            ),
                          ).then((_) {
                            // Opcional: refrescar si es necesario
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // Historial de peso
                      _buildSection(
                        context,
                        'Historial de Peso (${weightRecords.length})',
                        weightRecords.isEmpty
                            ? [
                                const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                    'No hay registros de peso',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ]
                            : weightRecords.take(3).map((record) {
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Icon(
                                    Icons.trending_up,
                                    color: farm.primaryColor,
                                  ),
                                  title: Text('${record.weight.toStringAsFixed(1)} kg'),
                                  subtitle: Text(
                                    DateFormat('dd/MM/yyyy').format(record.recordDate),
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                );
                              }).toList(),
                        actionIcon: Icons.add,
                        onAction: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CattleWeightFormScreen(
                                farm: updatedFarm,
                                selectedCattle: cattle,
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // Transferencias
                      _buildSection(
                        context,
                        'Transferencias (${transfers.length})',
                        transfers.isEmpty
                            ? [
                                const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                    'No hay transferencias',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ]
                            : transfers.take(3).map((transfer) {
                                final destFarm = farmProvider.farms.firstWhere(
                                  (f) => f.id == transfer.toFarmId,
                                  orElse: () => farm,
                                );
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Icon(
                                    Icons.swap_horiz,
                                    color: farm.primaryColor,
                                  ),
                                  title: Text(transfer.reasonString),
                                  subtitle: Text(
                                    '${DateFormat('dd/MM/yyyy').format(transfer.transferDate)} → ${destFarm.name}',
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                );
                              }).toList(),
                      ),

                      const SizedBox(height: 16),

                      // Producción de leche (solo para hembras)
                      if (cattle.gender == CattleGender.female) ...[
                        _buildSection(
                          context,
                          'Producción de Leche (${milkRecords.length})',
                          milkRecords.isEmpty
                              ? [
                                  const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Text(
                                      'No hay registros de producción de leche',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ]
                              : milkRecords.take(5).map((record) {
                                  // Calcular promedio
                                  final avgProduction = milkRecords.isNotEmpty
                                      ? milkRecords.fold(0.0, (sum, r) => sum + r.litersProduced) / milkRecords.length
                                      : 0.0;
                                  
                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MilkProductionFormScreen(
                                            farm: updatedFarm,
                                            selectedCattle: cattle,
                                            recordToEdit: record,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Column(
                                      children: [
                                        ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          leading: Icon(
                                            Icons.water_drop,
                                            color: farm.primaryColor,
                                          ),
                                          title: Text('${record.litersProduced.toStringAsFixed(1)} litros'),
                                          subtitle: Text(
                                            DateFormat('dd/MM/yyyy').format(record.recordDate),
                                          ),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              record.litersProduced >= avgProduction
                                                  ? Icon(Icons.trending_up, color: Colors.green)
                                                  : Icon(Icons.trending_down, color: Colors.orange),
                                              const SizedBox(width: 8),
                                              Icon(Icons.edit, size: 18, color: Colors.grey),
                                            ],
                                          ),
                                        ),
                                      if (record == milkRecords.first && milkRecords.length > 1)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Icon(Icons.analytics, size: 16, color: Colors.grey[600]),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Promedio: ${avgProduction.toStringAsFixed(1)} L',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                          actionIcon: Icons.add,
                          onAction: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MilkProductionFormScreen(
                                  farm: updatedFarm,
                                  selectedCattle: cattle,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Hijos (solo para hembras)
                      if (cattle.gender == CattleGender.female) ...[
                        _buildSection(
                          context,
                          'Hijos (${children.length})',
                          children.isEmpty
                              ? [
                                  const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Text(
                                      'No hay hijos registrados',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ]
                              : children.map((child) {
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: CircleAvatar(
                                      backgroundColor: farm.primaryColor.withOpacity(0.2),
                                      child: Icon(
                                        child.gender == CattleGender.male
                                            ? Icons.male
                                            : Icons.female,
                                        color: farm.primaryColor,
                                      ),
                                    ),
                                    title: Text(
                                      child.name ?? child.identification ?? 'Sin identificar',
                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(child.genderString),
                                        Text(
                                          'Nació: ${DateFormat('dd/MM/yyyy').format(child.birthDate)}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        if (child.currentWeight > 0)
                                          Text(
                                            'Peso: ${child.currentWeight.toStringAsFixed(1)} kg',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                      ],
                                    ),
                                    trailing: const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CattleProfileScreen(
                                            farm: updatedFarm,
                                            cattle: child,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Notas
                      if (cattle.notes != null && cattle.notes!.isNotEmpty)
                        _buildSection(
                          context,
                          'Notas',
                          [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(cattle.notes!),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CattleFormScreen(
                    farm: updatedFarm,
                    cattleToEdit: cattle,
                  ),
                ),
              );
            },
            backgroundColor: farm.primaryColor,
            child: const Icon(Icons.edit),
          ),
        );
      },
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children, {
    IconData? actionIcon,
    VoidCallback? onAction,
  }) {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (actionIcon != null && onAction != null)
                  IconButton(
                    icon: Icon(actionIcon),
                    color: Theme.of(context).primaryColor,
                    onPressed: onAction,
                  ),
              ],
            ),
          ),
          Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Obtiene los hijos de una vaca basándose en los eventos de parto
  /// y comparando las fechas de nacimiento de los animales
  List<Cattle> _getChildren(Cattle mother, Farm farm, FarmProvider farmProvider) {
    // Obtener todos los eventos de parto donde esta vaca es la madre
    final birthingEvents = farm.reproductionEvents
        .where((event) =>
            event.eventType == ReproductionEventType.calving &&
            event.cattleId == mother.id &&
            event.calfBorn == true)
        .toList();

    if (birthingEvents.isEmpty) {
      return [];
    }

    final children = <Cattle>[];

    // Para cada evento de parto, buscar hijos
    for (final event in birthingEvents) {
      Cattle? child;
      
      // PRIORIDAD 1: Si hay calfId directo, usar ese (más preciso)
      if (event.calfId != null && event.calfId!.isNotEmpty) {
        try {
          child = farm.cattle.firstWhere((c) => c.id == event.calfId);
          children.add(child);
          continue; // Ya encontramos el hijo por ID, pasar al siguiente evento
        } catch (e) {
          // El ID no existe, continuar con búsqueda por fecha
        }
      }
      
      // PRIORIDAD 2: Búsqueda por fecha de nacimiento (fallback para compatibilidad)
      // Buscar animales cuya fecha de nacimiento coincida con la fecha del parto
      final matchingCattle = farm.cattle.where((cow) {
        // Diferencia en días entre la fecha de nacimiento y el parto
        final daysDifference = (cow.birthDate.difference(event.eventDate).inDays).abs();

        // Debe estar dentro de la tolerancia configurada
        if (daysDifference > AppConstants.childBirthDateToleranceDays) return false;

        // Si hay información de género en el parto, intentar coincidir
        if (event.calfGender != null) {
          final genderString = event.calfGender!.toLowerCase();
          CattleGender? expectedGender;
          
          if (genderString.contains('male') || genderString == 'macho') {
            expectedGender = CattleGender.male;
          } else if (genderString.contains('female') || genderString == 'hembra') {
            expectedGender = CattleGender.female;
          }

          if (expectedGender != null && cow.gender != expectedGender) {
            return false;
          }
        }

        return true;
      }).toList();

      // Si encontramos hijos por fecha, agregarlos (puede haber múltiples matches)
      children.addAll(matchingCattle);
    }

    // Eliminar duplicados y ordenar por fecha de nacimiento (más reciente primero)
    final uniqueChildren = <String, Cattle>{};
    for (final child in children) {
      if (!uniqueChildren.containsKey(child.id)) {
        uniqueChildren[child.id] = child;
      }
    }

    final sortedChildren = uniqueChildren.values.toList()
      ..sort((a, b) => b.birthDate.compareTo(a.birthDate));

    // Limitar el número de hijos mostrados
    return sortedChildren.take(AppConstants.maxChildrenDisplay).toList();
  }
}
