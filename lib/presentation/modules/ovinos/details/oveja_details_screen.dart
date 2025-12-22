import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:io' if (dart.library.html) 'dart:html' as io;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../viewmodels/ovejas_viewmodel.dart';
import '../edit/oveja_edit_screen.dart';
import '../../../../domain/entities/ovinos/oveja.dart';
import '../../../../presentation/widgets/info_card.dart';
import '../../../../presentation/widgets/status_chip.dart';
import '../../../../presentation/widgets/custom_button.dart';
import '../../../../presentation/widgets/photo/photo_display_widget.dart';
import '../../../../core/services/photo_service.dart';
import '../../../../core/di/dependency_injection.dart';

/// Pantalla de detalles de una Oveja
class OvejaDetailsScreen extends StatelessWidget {
  final Oveja oveja;
  final String farmId;

  const OvejaDetailsScreen({
    super.key,
    required this.oveja,
    required this.farmId,
  });

  Future<bool> _confirmDelete(BuildContext context, OvejasViewModel viewModel) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text('¿Estás seguro de eliminar a ${oveja.name ?? oveja.identification}?'),
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

  Future<void> _handleDelete(BuildContext context, OvejasViewModel viewModel) async {
    final confirmed = await _confirmDelete(context, viewModel);
    if (!confirmed) return;

    final success = await viewModel.deleteOvejaEntity(oveja.id, farmId);

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Oveja eliminada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Error al eliminar oveja'),
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
          value: context.read<OvejasViewModel>(),
          child: OvejaEditScreen(oveja: oveja, farmId: farmId),
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
    final age = DateTime.now().difference(oveja.birthDate).inDays ~/ 365;

    return Scaffold(
      appBar: AppBar(
        title: Text(oveja.name ?? oveja.identification ?? 'Oveja'),
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
              context.read<OvejasViewModel>(),
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
                  Stack(
                    children: [
                      PhotoDisplayWidget(
                        photoUrl: oveja.photoUrl,
                        entityId: oveja.id,
                        module: 'ovinos',
                        size: 100,
                        placeholder: CircleAvatar(
                          radius: 50,
                          backgroundColor: _getStatusColor(oveja.estadoReproductivo),
                          child: Icon(
                            oveja.gender == OvejaGender.female ? Icons.pets : Icons.pets_outlined,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                        onTap: () => _showPhotoOptions(context),
                      ),
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
                  const SizedBox(height: 16),
                  Text(
                    oveja.name ?? oveja.identification ?? 'Sin nombre',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      StatusChip(
                        label: oveja.gender == OvejaGender.female ? 'Hembra' : 'Macho',
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      if (oveja.estadoReproductivo != null)
                        StatusChip(
                          label: _getEstadoString(oveja.estadoReproductivo!),
                          color: _getStatusColor(oveja.estadoReproductivo),
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
            InfoCard(
              label: 'Identificación',
              value: oveja.identification ?? 'No especificada',
              icon: Icons.tag,
            ),
            const SizedBox(height: 8),
            InfoCard(
              label: 'Fecha de Nacimiento',
              value: dateFormat.format(oveja.birthDate),
              icon: Icons.calendar_today,
            ),
            const SizedBox(height: 8),
            InfoCard(
              label: 'Edad',
              value: '$age años',
              icon: Icons.cake,
            ),
            if (oveja.currentWeight != null) ...[
              const SizedBox(height: 8),
              InfoCard(
                label: 'Peso Actual',
                value: '${oveja.currentWeight!.toStringAsFixed(1)} kg',
                icon: Icons.monitor_weight,
              ),
            ],
            // Estado reproductivo
            if (oveja.estadoReproductivo != null ||
                oveja.fechaMonta != null ||
                oveja.fechaProbableParto != null ||
                oveja.partosPrevios != null) ...[
              const SizedBox(height: 24),
              Text(
                'Estado Reproductivo',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              if (oveja.fechaMonta != null)
                InfoCard(
                  label: 'Fecha de Monta',
                  value: dateFormat.format(oveja.fechaMonta!),
                  icon: Icons.favorite,
                ),
              if (oveja.fechaProbableParto != null) ...[
                const SizedBox(height: 8),
                InfoCard(
                  label: 'Fecha Probable de Parto',
                  value: dateFormat.format(oveja.fechaProbableParto!),
                  icon: Icons.pregnant_woman,
                ),
                if (oveja.diasRestantesParto != null) ...[
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
                            'Parto en ${oveja.diasRestantesParto} días',
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
              if (oveja.partosPrevios != null) ...[
                const SizedBox(height: 8),
                InfoCard(
                  label: 'Partos Previos',
                  value: oveja.partosPrevios.toString(),
                  icon: Icons.numbers,
                ),
              ],
            ],
            // Notas
            if (oveja.notes != null && oveja.notes!.isNotEmpty) ...[
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
                child: Text(oveja.notes!),
              ),
            ],
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
                      context.read<OvejasViewModel>(),
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

  Color _getStatusColor(EstadoReproductivoOveja? estado) {
    if (estado == null) return Colors.grey;
    switch (estado) {
      case EstadoReproductivoOveja.vacia:
        return Colors.green;
      case EstadoReproductivoOveja.gestante:
        return Colors.orange;
      case EstadoReproductivoOveja.lactante:
        return Colors.blue;
    }
  }

  String _getEstadoString(EstadoReproductivoOveja estado) {
    switch (estado) {
      case EstadoReproductivoOveja.vacia:
        return 'Vacía';
      case EstadoReproductivoOveja.gestante:
        return 'Gestante';
      case EstadoReproductivoOveja.lactante:
        return 'Lactante';
    }
  }

  Future<void> _showPhotoOptions(BuildContext context) async {
    final photoService = DependencyInjection.photoService;
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
            if (oveja.photoUrl != null)
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

    dynamic photo;
    if (option == 'camera') {
      photo = await photoService.takePhoto();
    } else if (option == 'gallery') {
      photo = await photoService.pickFromGallery();
    } else if (option == 'delete') {
      // Eliminar foto
      if (oveja.photoUrl != null) {
        await photoService.deletePhoto(oveja.photoUrl!);
      }
      return;
    }

    if (photo != null) {
      final compressed = await photoService.compressImage(photo);
      if (compressed != null) {
        final savedPath = await photoService.savePhoto(compressed, oveja.id, 'ovinos');
        if (savedPath != null) {
          // Actualizar la oveja con la nueva foto
          final viewModel = context.read<OvejasViewModel>();
          final updatedOveja = oveja.copyWith(photoUrl: savedPath);
          await viewModel.updateOvejaEntity(updatedOveja, farmId);
        }
      }
    }
  }
}

