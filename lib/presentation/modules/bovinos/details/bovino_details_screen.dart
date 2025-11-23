import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../viewmodels/bovinos_viewmodel.dart';
import '../viewmodels/eventos_reproductivos_viewmodel.dart';
import '../edit/bovino_edit_screen.dart';
import '../widgets/pedigree_tree_widget.dart';
import '../widgets/reproduction_timeline_widget.dart';
import '../widgets/evento_reproductivo_form_screen.dart';
import '../../../../domain/entities/bovinos/bovino.dart';
import '../../../../domain/entities/bovinos/evento_reproductivo.dart';
import '../../../../core/di/dependency_injection.dart';
import '../details/cubits/bovino_partos_cubit.dart';
import '../details/cubits/bovino_descendencia_cubit.dart';
import '../../../../presentation/widgets/info_card.dart';
import '../../../../presentation/widgets/status_chip.dart';
import '../../../../presentation/widgets/custom_button.dart';

/// Pantalla de detalles de un Bovino
class BovinoDetailsScreen extends StatefulWidget {
  final Bovino bovino;
  final String farmId;

  const BovinoDetailsScreen({
    super.key,
    required this.bovino,
    required this.farmId,
  });

  @override
  State<BovinoDetailsScreen> createState() => _BovinoDetailsScreenState();
}

class _BovinoDetailsScreenState extends State<BovinoDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late BovinoPartosCubit _partosCubit;
  late BovinoDescendenciaCubit _descendenciaCubit;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Crear los Cubits usando DependencyInjection
    _partosCubit = DependencyInjection.createBovinoPartosCubit(widget.farmId);
    _descendenciaCubit = DependencyInjection.createBovinoDescendenciaCubit(widget.farmId);
    
    // Inicializar carga de datos reactivos después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Cargar partos
      _partosCubit.cargarPartos(widget.bovino.id);
      // Cargar descendencia
      _descendenciaCubit.cargarDescendencia(widget.bovino.id);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _partosCubit.close();
    _descendenciaCubit.close();
    super.dispose();
  }

  Future<bool> _confirmDelete(BuildContext context, BovinosViewModel viewModel) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text('¿Estás seguro de eliminar a ${widget.bovino.name ?? widget.bovino.identification}?'),
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

    final success = await viewModel.deleteBovinoEntity(widget.bovino.id, widget.farmId);

    if (!mounted) return;

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
          child: BovinoEditScreen(bovino: widget.bovino, farmId: widget.farmId),
        ),
      ),
    ).then((result) {
      if (result == true && mounted) {
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
        viewModel.loadBovinos(widget.farmId);
      });
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider<BovinoPartosCubit>.value(value: _partosCubit),
        BlocProvider<BovinoDescendenciaCubit>.value(value: _descendenciaCubit),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.bovino.name ?? widget.bovino.identification ?? 'Bovino'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.info), text: 'Información'),
              Tab(icon: Icon(Icons.favorite), text: 'Reproducción'),
              Tab(icon: Icon(Icons.account_tree), text: 'Genealogía'),
            ],
          ),
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
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildInfoTab(dateFormat, viewModel),
            _buildReproductionTab(),
            _buildPedigreeTab(),
          ],
        ),
        floatingActionButton: _tabController.index == 1
            ? FloatingActionButton.extended(
                onPressed: () => _navigateToNewEvent(context),
                icon: const Icon(Icons.add),
                label: const Text('Nuevo Evento'),
              )
            : null,
      ),
    );
  }

  Widget _buildInfoTab(DateFormat dateFormat, BovinosViewModel viewModel) {
    return SingleChildScrollView(
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
                    backgroundColor: _getHealthColor(widget.bovino.healthStatus),
                    child: Icon(
                      widget.bovino.gender == BovinoGender.female ? Icons.pets : Icons.pets_outlined,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.bovino.name ?? widget.bovino.identification ?? 'Sin nombre',
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
                        label: _getCategoryString(widget.bovino.category),
                        color: Colors.blue,
                      ),
                      StatusChip(
                        label: widget.bovino.gender == BovinoGender.female ? 'Hembra' : 'Macho',
                        color: Colors.purple,
                      ),
                      StatusChip(
                        label: _getHealthString(widget.bovino.healthStatus),
                        color: _getHealthColor(widget.bovino.healthStatus),
                      ),
                      if (widget.bovino.needsSpecialCare)
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
            if (widget.bovino.identification != null)
              InfoCard(
                label: 'Identificación',
                value: widget.bovino.identification!,
                icon: Icons.tag,
              ),
            if (widget.bovino.identification != null) const SizedBox(height: 8),
            InfoCard(
              label: 'Fecha de Nacimiento',
              value: dateFormat.format(widget.bovino.birthDate),
              icon: Icons.calendar_today,
            ),
            const SizedBox(height: 8),
            InfoCard(
              label: 'Edad',
              value: '${widget.bovino.ageInYears} años',
              icon: Icons.cake,
            ),
            const SizedBox(height: 8),
            InfoCard(
              label: 'Peso Actual',
              value: '${widget.bovino.currentWeight.toStringAsFixed(1)} kg',
              icon: Icons.monitor_weight,
            ),
            if (widget.bovino.raza != null) ...[
              const SizedBox(height: 8),
              InfoCard(
                label: 'Raza',
                value: widget.bovino.raza!,
                icon: Icons.agriculture,
              ),
            ],
            const SizedBox(height: 8),
            InfoCard(
              label: 'Etapa de Producción',
              value: _getProductionStageString(widget.bovino.productionStage),
              icon: Icons.timeline,
            ),
            // Estado reproductivo
            if (widget.bovino.breedingStatus != null ||
                widget.bovino.lastHeatDate != null ||
                widget.bovino.inseminationDate != null ||
                widget.bovino.expectedCalvingDate != null ||
                widget.bovino.previousCalvings != null) ...[
              const SizedBox(height: 24),
              Text(
                'Estado Reproductivo',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              if (widget.bovino.breedingStatus != null)
                InfoCard(
                  label: 'Estado',
                  value: _getBreedingStatusString(widget.bovino.breedingStatus!),
                  icon: Icons.favorite,
                ),
              if (widget.bovino.lastHeatDate != null) ...[
                const SizedBox(height: 8),
                InfoCard(
                  label: 'Última Fecha de Celo',
                  value: dateFormat.format(widget.bovino.lastHeatDate!),
                  icon: Icons.calendar_today,
                ),
              ],
              if (widget.bovino.inseminationDate != null) ...[
                const SizedBox(height: 8),
                InfoCard(
                  label: 'Fecha de Inseminación',
                  value: dateFormat.format(widget.bovino.inseminationDate!),
                  icon: Icons.medical_services,
                ),
              ],
              if (widget.bovino.expectedCalvingDate != null) ...[
                const SizedBox(height: 8),
                InfoCard(
                  label: 'Fecha Esperada de Parto',
                  value: dateFormat.format(widget.bovino.expectedCalvingDate!),
                  icon: Icons.pregnant_woman,
                ),
                if (widget.bovino.daysUntilCalving != null && widget.bovino.daysUntilCalving! >= 0) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.orange),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Parto en ${widget.bovino.daysUntilCalving} días',
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
              if (widget.bovino.previousCalvings != null) ...[
                const SizedBox(height: 8),
                InfoCard(
                  label: 'Partos Previos',
                  value: widget.bovino.previousCalvings.toString(),
                  icon: Icons.numbers,
                ),
              ],
            ],
            // Notas
            if (widget.bovino.notes != null && widget.bovino.notes!.isNotEmpty) ...[
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
                child: Text(widget.bovino.notes!),
              ),
            ],
            // Descendencia (Hijos) - Ahora usando BlocBuilder
            BlocBuilder<BovinoDescendenciaCubit, BovinoDescendenciaState>(
              builder: (context, state) {
                if (state is BovinoDescendenciaLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (state is BovinoDescendenciaError) {
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            'Error: ${state.message}',
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<BovinoDescendenciaCubit>().cargarDescendencia(widget.bovino.id);
                            },
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is BovinoDescendenciaLoaded) {
                  if (state.hijos.isEmpty) {
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
                      ...state.hijos.map((child) => Card(
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
                          trailing: child.idPadre == widget.bovino.id
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
                                  farmId: widget.farmId,
                                ),
                              ),
                            );
                          },
                        ),
                      )),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
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
      );
  }

  Widget _buildReproductionTab() {
    return BlocBuilder<BovinoPartosCubit, BovinoPartosState>(
      builder: (context, state) {
        if (state is BovinoPartosLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is BovinoPartosError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Error: ${state.message}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<BovinoPartosCubit>().cargarPartos(widget.bovino.id);
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        if (state is BovinoPartosLoaded) {
          if (state.partos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.child_care_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Sin registros de parto',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No se han registrado partos para este animal',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<BovinoPartosCubit>().cargarPartos(widget.bovino.id);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.partos.length,
              itemBuilder: (context, index) {
                final parto = state.partos[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.purple.shade100,
                      child: Icon(Icons.child_care, color: Colors.purple.shade700),
                    ),
                    title: Text(
                      'Parto',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Fecha: ${DateFormat('dd/MM/yyyy').format(parto.fecha)}'),
                        if (parto.notas != null && parto.notas!.isNotEmpty)
                          Text('Notas: ${parto.notas}'),
                        if (parto.nacioCria == true)
                          Chip(
                            label: const Text('Cría creada'),
                            avatar: Icon(Icons.check_circle, size: 16),
                            backgroundColor: Colors.green.shade50,
                          ),
                      ],
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Opcional: mostrar detalles del parto
                    },
                  ),
                );
              },
            ),
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildPedigreeTab() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      margin: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: PedigreeTreeWidget(
          bovino: widget.bovino,
          farmId: widget.farmId,
        ),
      ),
    );
  }

  void _navigateToNewEvent(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventoReproductivoFormScreen(
          bovino: widget.bovino,
          farmId: widget.farmId,
        ),
      ),
    );

    if (result == true && mounted) {
      // Recargar partos cuando se crea un nuevo evento
      _partosCubit.cargarPartos(widget.bovino.id);
      // Recargar descendencia por si se creó una cría
      _descendenciaCubit.cargarDescendencia(widget.bovino.id);
    }
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

