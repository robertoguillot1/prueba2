import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/bovinos_viewmodel.dart';
import '../edit/bovino_edit_screen.dart';
import '../widgets/pedigree_tree_widget.dart';
import '../../../../domain/entities/bovinos/bovino.dart';
import '../../../../presentation/widgets/info_card.dart';
import '../../../../presentation/widgets/status_chip.dart';
import '../../../../presentation/widgets/custom_button.dart';

/// Pantalla de detalles de un Bovino
class BovinoDetailsScreen extends StatelessWidget {
  final Bovino bovino;
  final String farmId;

  const BovinoDetailsScreen({
    super.key,
    required this.bovino,
    required this.farmId,
  });

  Future<bool> _confirmDelete(BuildContext context, BovinosViewModel viewModel) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text('¿Estás seguro de eliminar a ${bovino.name ?? bovino.identification}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    return confirmed ?? false;
  }

  Future<void> _handleDelete(BuildContext context, BovinosViewModel viewModel) async {
    final confirmed = await _confirmDelete(context, viewModel);
    if (!confirmed) return;

    final success = await viewModel.deleteBovinoEntity(bovino.id, farmId);

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bovino eliminado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Error al eliminar bovino'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<BovinosViewModel>(),
          child: BovinoEditScreen(bovino: bovino, farmId: farmId),
        ),
      ),
    ).then((result) {
      if (result == true && context.mounted) {
        Navigator.pop(context, true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final viewModel = context.watch<BovinosViewModel>();
    
    // Asegurar que los bovinos estén cargados
    if (viewModel.bovinos.isEmpty && !viewModel.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        viewModel.loadBovinos(farmId);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(bovino.name ?? bovino.identification ?? 'Bovino'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEdit(context),
            tooltip: 'Editar',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _handleDelete(
              context,
              context.read<BovinosViewModel>(),
            ),
            tooltip: 'Eliminar',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar y nombre
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: _getHealthColor(bovino.healthStatus),
                    child: Icon(
                      bovino.gender == BovinoGender.female ? Icons.pets : Icons.pets_outlined,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    bovino.name ?? bovino.identification ?? 'Sin nombre',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      StatusChip(
                        label: _getCategoryString(bovino.category),
                        color: Colors.blue,
                      ),
                      StatusChip(
                        label: bovino.gender == BovinoGender.female ? 'Hembra' : 'Macho',
                        color: Colors.purple,
                      ),
                      StatusChip(
                        label: _getHealthString(bovino.healthStatus),
                        color: _getHealthColor(bovino.healthStatus),
                      ),
                      if (bovino.needsSpecialCare)
                        StatusChip(
                          label: 'Cuidados Especiales',
                          color: Colors.orange,
                          icon: Icons.warning,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Información básica
            Text(
              'Información Básica',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (bovino.identification != null)
              InfoCard(
                label: 'Identificación',
                value: bovino.identification!,
                icon: Icons.tag,
              ),
            if (bovino.identification != null) const SizedBox(height: 8),
            InfoCard(
              label: 'Fecha de Nacimiento',
              value: dateFormat.format(bovino.birthDate),
              icon: Icons.calendar_today,
            ),
            const SizedBox(height: 8),
            InfoCard(
              label: 'Edad',
              value: '${bovino.ageInYears} años',
              icon: Icons.cake,
            ),
            const SizedBox(height: 8),
            InfoCard(
              label: 'Peso Actual',
              value: '${bovino.currentWeight.toStringAsFixed(1)} kg',
              icon: Icons.monitor_weight,
            ),
            if (bovino.raza != null) ...[
              const SizedBox(height: 8),
              InfoCard(
                label: 'Raza',
                value: bovino.raza!,
                icon: Icons.agriculture,
              ),
            ],
            const SizedBox(height: 8),
            InfoCard(
              label: 'Etapa de Producción',
              value: _getProductionStageString(bovino.productionStage),
              icon: Icons.timeline,
            ),
            // Estado reproductivo
            if (bovino.breedingStatus != null ||
                bovino.lastHeatDate != null ||
                bovino.inseminationDate != null ||
                bovino.expectedCalvingDate != null ||
                bovino.previousCalvings != null) ...[
              const SizedBox(height: 24),
              Text(
                'Estado Reproductivo',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              if (bovino.breedingStatus != null)
                InfoCard(
                  label: 'Estado',
                  value: _getBreedingStatusString(bovino.breedingStatus!),
                  icon: Icons.favorite,
                ),
              if (bovino.lastHeatDate != null) ...[
                const SizedBox(height: 8),
                InfoCard(
                  label: 'Última Fecha de Celo',
                  value: dateFormat.format(bovino.lastHeatDate!),
                  icon: Icons.calendar_today,
                ),
              ],
              if (bovino.inseminationDate != null) ...[
                const SizedBox(height: 8),
                InfoCard(
                  label: 'Fecha de Inseminación',
                  value: dateFormat.format(bovino.inseminationDate!),
                  icon: Icons.medical_services,
                ),
              ],
              if (bovino.expectedCalvingDate != null) ...[
                const SizedBox(height: 8),
                InfoCard(
                  label: 'Fecha Esperada de Parto',
                  value: dateFormat.format(bovino.expectedCalvingDate!),
                  icon: Icons.pregnant_woman,
                ),
                if (bovino.daysUntilCalving != null && bovino.daysUntilCalving! >= 0) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.orange),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Parto en ${bovino.daysUntilCalving} días',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
              if (bovino.previousCalvings != null) ...[
                const SizedBox(height: 8),
                InfoCard(
                  label: 'Partos Previos',
                  value: bovino.previousCalvings.toString(),
                  icon: Icons.numbers,
                ),
              ],
            ],
            // Notas
            if (bovino.notes != null && bovino.notes!.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Notas',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(bovino.notes!),
              ),
            ],
            // Descendencia (Hijos)
            Consumer<BovinosViewModel>(
              builder: (context, viewModel, child) {
                final children = viewModel.bovinos.where((b) =>
                  b.idPadre == bovino.id || b.idMadre == bovino.id
                ).toList();
                
                if (children.isEmpty) {
                  return const SizedBox.shrink();
                }
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      'Descendencia',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    ...children.map((child) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: child.gender == BovinoGender.female
                              ? Colors.pink.shade100
                              : Colors.blue.shade100,
                          child: Icon(
                            child.gender == BovinoGender.female
                                ? Icons.female
                                : Icons.male,
                            color: child.gender == BovinoGender.female
                                ? Colors.pink.shade700
                                : Colors.blue.shade700,
                          ),
                        ),
                        title: Text(
                          child.name ?? child.identification ?? 'Sin nombre',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_getCategoryString(child.category)} - ${child.gender == BovinoGender.female ? 'Hembra' : 'Macho'}',
                            ),
                            if (child.raza != null && child.raza!.isNotEmpty)
                              Text('Raza: ${child.raza}'),
                            Text(
                              'Nacimiento: ${dateFormat.format(child.birthDate)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        trailing: child.idPadre == bovino.id
                            ? Chip(
                                label: const Text('Hijo'),
                                avatar: const Icon(Icons.male, size: 16),
                                backgroundColor: Colors.blue.shade50,
                              )
                            : Chip(
                                label: const Text('Hija'),
                                avatar: const Icon(Icons.female, size: 16),
                                backgroundColor: Colors.pink.shade50,
                              ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BovinoDetailsScreen(
                                bovino: child,
                                farmId: farmId,
                              ),
                            ),
                          );
                        },
                      ),
                    )),
                  ],
                );
              },
            ),
            // Genealogía
            const SizedBox(height: 24),
            Text(
              'Genealogía',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 600,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: PedigreeTreeWidget(
                  bovino: bovino,
                  farmId: farmId,
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    label: 'Editar',
                    icon: Icons.edit,
                    onPressed: () => _navigateToEdit(context),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    label: 'Eliminar',
                    icon: Icons.delete,
                    onPressed: () => _handleDelete(
                      context,
                      context.read<BovinosViewModel>(),
                    ),
                    backgroundColor: Colors.red,
                    isOutlined: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getHealthColor(HealthStatus status) {
    switch (status) {
      case HealthStatus.sano:
        return Colors.green;
      case HealthStatus.enfermo:
        return Colors.red;
      case HealthStatus.tratamiento:
        return Colors.orange;
    }
  }

  String _getHealthString(HealthStatus status) {
    switch (status) {
      case HealthStatus.sano:
        return 'Sano';
      case HealthStatus.enfermo:
        return 'Enfermo';
      case HealthStatus.tratamiento:
        return 'En Tratamiento';
    }
  }

  String _getCategoryString(BovinoCategory category) {
    switch (category) {
      case BovinoCategory.vaca:
        return 'Vaca';
      case BovinoCategory.toro:
        return 'Toro';
      case BovinoCategory.ternero:
        return 'Ternero';
      case BovinoCategory.novilla:
        return 'Novilla';
    }
  }

  String _getProductionStageString(ProductionStage stage) {
    switch (stage) {
      case ProductionStage.levante:
        return 'Levante';
      case ProductionStage.desarrollo:
        return 'Desarrollo';
      case ProductionStage.produccion:
        return 'Producción';
      case ProductionStage.descarte:
        return 'Descarte';
    }
  }

  String _getBreedingStatusString(BreedingStatus status) {
    switch (status) {
      case BreedingStatus.vacia:
        return 'Vacía';
      case BreedingStatus.enCelo:
        return 'En Celo';
      case BreedingStatus.prenada:
        return 'Prenada';
      case BreedingStatus.lactante:
        return 'Lactante';
      case BreedingStatus.seca:
        return 'Seca';
    }
  }
}

