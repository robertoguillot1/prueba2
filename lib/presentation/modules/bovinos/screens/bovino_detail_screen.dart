import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../features/cattle/domain/entities/bovine_entity.dart';
import '../../../../core/di/dependency_injection.dart' as di;
import '../cubits/form/bovino_form_cubit.dart';
import '../cubits/form/bovino_form_state.dart';
import 'bovino_form_screen.dart';

/// Pantalla de detalle/perfil de un Bovino
class BovinoDetailScreen extends StatelessWidget {
  final BovineEntity bovine;
  final String farmId;

  const BovinoDetailScreen({
    super.key,
    required this.bovine,
    required this.farmId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<BovinoFormCubit>(),
      child: BlocListener<BovinoFormCubit, BovinoFormState>(
        listener: (context, state) {
          if (state is BovinoFormDeleted) {
            // Mostrar mensaje de éxito
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            // Cerrar pantalla y regresar a la lista con resultado true
            Navigator.pop(context, true);
          } else if (state is BovinoFormError) {
            // Mostrar mensaje de error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: _buildDetailContent(context),
      ),
    );
  }

  Widget _buildDetailContent(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              _buildSliverAppBar(context),
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyTabBarDelegate(
                  TabBar(
                    tabs: const [
                      Tab(icon: Icon(Icons.info_outline), text: 'General'),
                      Tab(icon: Icon(Icons.favorite_outline), text: 'Reproducción'),
                      Tab(icon: Icon(Icons.show_chart), text: 'Producción'),
                      Tab(icon: Icon(Icons.medical_services_outlined), text: 'Sanidad'),
                    ],
                    labelColor: Theme.of(context).primaryColor,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              _buildGeneralTab(context),
              _buildReproductionTab(context),
              _buildProductionTab(context),
              _buildHealthTab(context),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _navigateToEdit(context),
          icon: const Icon(Icons.edit),
          label: const Text('Editar'),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _showDeleteConfirmation(context),
          tooltip: 'Eliminar bovino',
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _getGenderColor(bovine.gender).withOpacity(0.3),
                theme.scaffoldBackgroundColor,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60), // Espacio para el AppBar
              // Avatar/Foto del animal
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getGenderColor(bovine.gender).withOpacity(0.2),
                  border: Border.all(
                    color: _getGenderColor(bovine.gender),
                    width: 3,
                  ),
                ),
                child: Icon(
                  _getGenderIcon(bovine.gender),
                  size: 60,
                  color: _getGenderColor(bovine.gender),
                ),
              ),
              const SizedBox(height: 16),
              // Identificador
              Text(
                bovine.identifier,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              // Nombre (si existe)
              if (bovine.name != null)
                Text(
                  bovine.name!,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              const SizedBox(height: 16),
              // Chips de información
              Wrap(
                spacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _buildInfoChip(
                    label: bovine.breed,
                    icon: Icons.pets,
                    color: Colors.blue,
                  ),
                  _buildInfoChip(
                    label: _getGenderLabel(bovine.gender),
                    icon: _getGenderIcon(bovine.gender),
                    color: _getGenderColor(bovine.gender),
                  ),
                  _buildInfoChip(
                    label: _getStatusLabel(bovine.status),
                    icon: _getStatusIcon(bovine.status),
                    color: _getStatusColor(bovine.status),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color, width: 1),
      labelStyle: TextStyle(
        color: color,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    );
  }

  // TAB 1: GENERAL
  Widget _buildGeneralTab(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionTitle('Información General', Icons.info),
        const SizedBox(height: 16),
        _buildInfoCard(
          context,
          children: [
            _buildInfoRow(
              icon: Icons.tag,
              label: 'Identificador',
              value: bovine.identifier,
            ),
            const Divider(),
            _buildInfoRow(
              icon: Icons.label,
              label: 'Nombre',
              value: bovine.name ?? 'Sin nombre',
            ),
            const Divider(),
            _buildInfoRow(
              icon: Icons.pets,
              label: 'Raza',
              value: bovine.breed,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSectionTitle('Datos Físicos', Icons.monitor_weight),
        const SizedBox(height: 16),
        _buildInfoCard(
          context,
          children: [
            _buildInfoRow(
              icon: Icons.cake,
              label: 'Fecha de Nacimiento',
              value: dateFormat.format(bovine.birthDate),
            ),
            const Divider(),
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: 'Edad',
              value: '${bovine.age} ${bovine.age == 1 ? 'año' : 'años'}',
            ),
            const Divider(),
            _buildInfoRow(
              icon: Icons.monitor_weight,
              label: 'Peso',
              value: '${bovine.weight.toStringAsFixed(1)} kg',
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSectionTitle('Clasificación', Icons.category),
        const SizedBox(height: 16),
        _buildInfoCard(
          context,
          children: [
            _buildInfoRow(
              icon: Icons.male,
              label: 'Género',
              value: _getGenderLabel(bovine.gender),
              valueColor: _getGenderColor(bovine.gender),
            ),
            const Divider(),
            _buildInfoRow(
              icon: Icons.work_outline,
              label: 'Propósito',
              value: _getPurposeLabel(bovine.purpose),
              valueColor: _getPurposeColor(bovine.purpose),
            ),
            const Divider(),
            _buildInfoRow(
              icon: _getStatusIcon(bovine.status),
              label: 'Estado',
              value: _getStatusLabel(bovine.status),
              valueColor: _getStatusColor(bovine.status),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSectionTitle('Información del Sistema', Icons.settings),
        const SizedBox(height: 16),
        _buildInfoCard(
          context,
          children: [
            _buildInfoRow(
              icon: Icons.agriculture,
              label: 'ID de Finca',
              value: bovine.farmId,
            ),
            const Divider(),
            _buildInfoRow(
              icon: Icons.access_time,
              label: 'Fecha de Registro',
              value: dateFormat.format(bovine.createdAt),
            ),
            if (bovine.updatedAt != null) ...[
              const Divider(),
              _buildInfoRow(
                icon: Icons.update,
                label: 'Última Actualización',
                value: dateFormat.format(bovine.updatedAt!),
              ),
            ],
          ],
        ),
        const SizedBox(height: 80), // Espacio para el FAB
      ],
    );
  }

  // TAB 2: REPRODUCCIÓN
  Widget _buildReproductionTab(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_outline,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Próximamente',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Aquí podrás ver el historial de partos, gestaciones y reproducción del animal',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade500,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // TAB 3: PRODUCCIÓN
  Widget _buildProductionTab(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Próximamente',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Aquí podrás ver el historial de producción de leche, control de peso y rendimiento',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade500,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // TAB 4: SANIDAD
  Widget _buildHealthTab(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medical_services_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Próximamente',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Aquí podrás ver el historial de vacunas, tratamientos y chequeos veterinarios',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade500,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade700),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, {required List<Widget> children}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: valueColor ?? Colors.black87,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToEdit(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BovinoFormScreen(
          farmId: farmId,
          bovine: bovine,
        ),
      ),
    );

    if (result == true && context.mounted) {
      // Si se editó exitosamente, cerrar la pantalla de detalle
      // para que la lista se actualice
      Navigator.pop(context, true);
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('¿Eliminar Bovino?'),
        content: Text(
          'Esta acción no se puede deshacer. ¿Estás seguro de eliminar a ${bovine.identifier}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          BlocBuilder<BovinoFormCubit, BovinoFormState>(
            builder: (context, state) {
              final isLoading = state is BovinoFormLoading;
              
              return TextButton(
                onPressed: isLoading
                    ? null
                    : () {
                        // Cerrar el diálogo
                        Navigator.pop(dialogContext);
                        // Llamar al método delete del cubit
                        context.read<BovinoFormCubit>().delete(bovine.id);
                      },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Eliminar'),
              );
            },
          ),
        ],
      ),
    );
  }

  // Helpers para obtener labels, colores e iconos
  String _getGenderLabel(BovineGender gender) {
    switch (gender) {
      case BovineGender.male:
        return 'Macho';
      case BovineGender.female:
        return 'Hembra';
    }
  }

  IconData _getGenderIcon(BovineGender gender) {
    switch (gender) {
      case BovineGender.male:
        return Icons.male;
      case BovineGender.female:
        return Icons.female;
    }
  }

  Color _getGenderColor(BovineGender gender) {
    switch (gender) {
      case BovineGender.male:
        return Colors.blue;
      case BovineGender.female:
        return Colors.pink;
    }
  }

  String _getPurposeLabel(BovinePurpose purpose) {
    switch (purpose) {
      case BovinePurpose.meat:
        return 'Carne';
      case BovinePurpose.milk:
        return 'Leche';
      case BovinePurpose.dual:
        return 'Doble Propósito';
    }
  }

  Color _getPurposeColor(BovinePurpose purpose) {
    switch (purpose) {
      case BovinePurpose.meat:
        return Colors.red;
      case BovinePurpose.milk:
        return Colors.blue;
      case BovinePurpose.dual:
        return Colors.purple;
    }
  }

  String _getStatusLabel(BovineStatus status) {
    switch (status) {
      case BovineStatus.active:
        return 'Activo';
      case BovineStatus.sold:
        return 'Vendido';
      case BovineStatus.dead:
        return 'Muerto';
    }
  }

  IconData _getStatusIcon(BovineStatus status) {
    switch (status) {
      case BovineStatus.active:
        return Icons.check_circle;
      case BovineStatus.sold:
        return Icons.sell;
      case BovineStatus.dead:
        return Icons.dangerous;
    }
  }

  Color _getStatusColor(BovineStatus status) {
    switch (status) {
      case BovineStatus.active:
        return Colors.green;
      case BovineStatus.sold:
        return Colors.orange;
      case BovineStatus.dead:
        return Colors.red;
    }
  }
}

/// Delegado para mantener el TabBar pegado cuando se hace scroll
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _StickyTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}

