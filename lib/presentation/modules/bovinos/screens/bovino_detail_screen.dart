import 'package:flutter/material.dart';
import 'dart:io';
import '../widgets/genealogy_widget.dart';
import '../details/tabs/transfer_tab.dart';
import '../screens/bovino_form_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../features/cattle/domain/entities/bovine_entity.dart';
import '../../../../core/di/dependency_injection.dart' as di;
import '../../../../presentation/widgets/photo/photo_display_widget.dart';
import '../cubits/form/bovino_form_cubit.dart';
import '../cubits/form/bovino_form_state.dart';
import '../details/tabs/reproduction_tab.dart';
import '../details/tabs/production_tab.dart';
import '../details/tabs/health_tab.dart';
import '../details/tabs/feeding_tab.dart'; // Import at top

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
      child: Builder(
        builder: (context) {
          final isFemale = bovine.gender == BovineGender.female;
          // Base tabs: General, Production, Health, Feeding, Transport
          // If female: + Reproduction
          final tabCount = isFemale ? 6 : 5;

          return DefaultTabController(
            length: tabCount,
            child: Scaffold(
              body: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return <Widget>[
                    _buildSliverAppBar(context),
                    SliverPersistentHeader(
                      delegate: _StickyTabBarDelegate(
                        TabBar(
                          tabs: _buildTabs(isFemale),
                          isScrollable: true,
                          labelColor: Theme.of(context).primaryColor,
                          indicatorColor: Theme.of(context).primaryColor,
                          tabAlignment: TabAlignment.start,
                        ),
                      ),
                      pinned: true,
                    ),
                  ];
                },
                body: TabBarView(
                  children: _buildTabViews(context, isFemale),
                ),
              ),
              floatingActionButton: Builder(
                builder: (context) {
                  return _buildConditionalFAB(context, isFemale) ?? const SizedBox.shrink();
                }
              ),
            ),
          );
        },
      ),
    );
  }

  /// Construye la lista de tabs según el género
  List<Tab> _buildTabs(bool isFemale) {
    final tabs = <Tab>[
      const Tab(icon: Icon(Icons.info_outline), text: 'General'),
    ];

    // Solo agregar tab de Reproducción si es hembra
    if (isFemale) {
      tabs.add(const Tab(icon: Icon(Icons.favorite_outline), text: 'Reproducción'));
    }

    tabs.addAll([
      const Tab(icon: Icon(Icons.show_chart), text: 'Producción'),
      const Tab(icon: Icon(Icons.medical_services_outlined), text: 'Sanidad'),
      const Tab(icon: Icon(Icons.restaurant), text: 'Alimentación'), // NEW TAB
      const Tab(icon: Icon(Icons.local_shipping), text: 'Transporte'),
    ]);

    return tabs;
  }

  /// Construye la lista de TabBarView children según el género
  List<Widget> _buildTabViews(BuildContext context, bool isFemale) {
    final views = <Widget>[
      _buildGeneralTab(context),
    ];

    // Solo agregar tab de Reproducción si es hembra
    if (isFemale) {
      views.add(_buildReproductionTab(context));
    }

    views.addAll([
      _buildProductionTab(context),
      _buildHealthTab(context),
      FeedingTab(bovineId: bovine.id, farmId: farmId), // NEW TAB VIEW
      _buildTransferTab(context),
    ]);

    return views;
  }

  /// FAB condicional que solo aparece en tabs General y Reproducción (si es hembra)
  Widget? _buildConditionalFAB(BuildContext context, bool isFemale) {
    // Obtener el índice actual del TabController
    final tabController = DefaultTabController.of(context);
    
    return AnimatedBuilder(
      animation: tabController,
      builder: (context, child) {
        final currentIndex = tabController.index;
        
        // Para hembras: mostrar en General (0) y Reproducción (1)
        // Para machos: solo mostrar en General (0)
        if (isFemale) {
          if (currentIndex == 0 || currentIndex == 1) {
            return FloatingActionButton.extended(
              onPressed: () => _navigateToEdit(context),
              icon: const Icon(Icons.edit),
              label: const Text('Editar'),
              heroTag: 'edit_bovine_fab',
            );
          }
        } else {
          // Machos: solo en General (0)
          if (currentIndex == 0) {
            return FloatingActionButton.extended(
              onPressed: () => _navigateToEdit(context),
              icon: const Icon(Icons.edit),
              label: const Text('Editar'),
              heroTag: 'edit_bovine_fab',
            );
          }
        }
        
        // En tabs Producción y Sanidad, no mostrar (tienen sus propios FABs)
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SliverAppBar(
      expandedHeight: 260, // Reducido de 280 a 260
      pinned: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.camera_alt),
          onPressed: () => _showPhotoOptions(context),
          tooltip: 'Agregar/Editar foto',
        ),
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
                _getGenderColor(bovine.gender).withValues(alpha: 0.3),
                theme.scaffoldBackgroundColor,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16), // Reducido de 60 a 16
                // Avatar/Foto del animal (más pequeño)
                Stack(
                  children: [
                    PhotoDisplayWidget(
                      photoUrl: bovine.photoUrl,
                      entityId: bovine.id,
                      module: 'cattle',
                      size: 100,
                      placeholder: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getGenderColor(bovine.gender).withValues(alpha: 0.2),
                          border: Border.all(
                            color: _getGenderColor(bovine.gender),
                            width: 3,
                          ),
                        ),
                        child: Icon(
                          _getGenderIcon(bovine.gender),
                          size: 50, // Reducido de 60 a 50
                          color: _getGenderColor(bovine.gender),
                        ),
                      ),
                      onTap: () => _showPhotoOptions(context),
                    ),
                    // Botón de cámara flotante
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, size: 18),
                          color: Colors.white,
                          onPressed: () => _showPhotoOptions(context),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12), // Reducido de 16 a 12
                // Identificador
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    bovine.identifier,
                    style: theme.textTheme.headlineSmall?.copyWith( // Reducido de headlineMedium
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                // Nombre (si existe)
                if (bovine.name != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      bovine.name!,
                      style: theme.textTheme.bodyLarge?.copyWith( // Reducido de titleMedium
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const SizedBox(height: 12), // Reducido de 16 a 12
                // Chips de información (más compactos)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 6, // Reducido de 8 a 6
                    runSpacing: 6,
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
                ),
                const SizedBox(height: 8),
              ],
            ),
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
      backgroundColor: color.withValues(alpha: 0.1),
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
      physics: const AlwaysScrollableScrollPhysics(), // Asegurar scroll
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
        _buildSectionTitle('Genealogía', Icons.family_restroom),
        const SizedBox(height: 16),
        GenealogyWidget(
          bovine: bovine,
          farmId: farmId,
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
    return ReproductionTab(
      bovine: bovine,
      farmId: farmId,
    );
  }

  // TAB 3: PRODUCCIÓN
  // TAB 3: PRODUCCIÓN
  Widget _buildProductionTab(BuildContext context) {
    return ProductionTab(
      bovine: bovine,
      farmId: farmId,
    );
  }

  // TAB 4: SANIDAD
  Widget _buildHealthTab(BuildContext context) {
    return HealthTab(
      bovine: bovine,
      farmId: farmId,
    );
  }

  // TAB 5: TRANSPORTE
  Widget _buildTransferTab(BuildContext context) {
    return TransferTab(
      bovine: bovine,
      farmId: farmId,
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

  Future<void> _showPhotoOptions(BuildContext context) async {
    final photoService = di.DependencyInjection.photoService;
    final option = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar foto'),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Seleccionar de galería'),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
            if (bovine.photoUrl != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Eliminar foto', style: TextStyle(color: Colors.red)),
                onTap: () => Navigator.pop(context, 'delete'),
              ),
          ],
        ),
      ),
    );

    if (option == null) return;

    File? photo;
    if (option == 'camera') {
      photo = await photoService.takePhoto();
    } else if (option == 'gallery') {
      photo = await photoService.pickFromGallery();
    } else if (option == 'delete') {
      // Eliminar foto
      if (bovine.photoUrl != null) {
        await photoService.deletePhoto(bovine.photoUrl!);
        // Actualizar el bovino sin foto
        final cubit = context.read<BovinoFormCubit>();
        await cubit.updatePhoto(bovine, farmId, null);
        // Esperar a que se complete la actualización y recargar
        if (context.mounted) {
          // Usar BlocListener para detectar cuando se complete
          final updatedBovine = bovine.copyWith(photoUrl: null);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => BovinoDetailScreen(
                bovine: updatedBovine,
                farmId: farmId,
              ),
            ),
          );
        }
      }
      return;
    }

    if (photo != null) {
      final compressed = await photoService.compressImage(photo);
      if (compressed != null) {
        final savedPath = await photoService.savePhoto(compressed, bovine.id, 'cattle');
        if (savedPath != null && context.mounted) {
          // Actualizar el bovino con la nueva foto
          final cubit = context.read<BovinoFormCubit>();
          await cubit.updatePhoto(bovine, farmId, savedPath);
          // Esperar a que se complete la actualización y recargar
          if (context.mounted) {
            final updatedBovine = bovine.copyWith(photoUrl: savedPath);
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => BovinoDetailScreen(
                  bovine: updatedBovine,
                  farmId: farmId,
                ),
              ),
            );
          }
        }
      }
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

