import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/gallinas_viewmodel.dart';
import '../edit/gallina_edit_screen.dart';
import '../../../../domain/entities/avicultura/gallina.dart';
import '../../../../presentation/widgets/info_card.dart';
import '../../../../presentation/widgets/status_chip.dart';
import '../../../../presentation/widgets/custom_button.dart';

/// Pantalla de detalles de una Gallina
class GallinaDetailsScreen extends StatelessWidget {
  final Gallina gallina;
  final String farmId;

  const GallinaDetailsScreen({
    super.key,
    required this.gallina,
    required this.farmId,
  });

  void _navigateToEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<GallinasViewModel>(),
          child: GallinaEditScreen(gallina: gallina, farmId: farmId),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(gallina.name ?? gallina.identification ?? 'Gallina'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEdit(context),
            tooltip: 'Editar',
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
                    backgroundColor: _getEstadoColor(gallina.estado),
                    child: Icon(
                      gallina.gender == GallinaGender.female ? Icons.pets : Icons.pets_outlined,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    gallina.name ?? gallina.identification ?? 'Sin nombre',
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
                        label: gallina.gender == GallinaGender.female ? 'Hembra' : 'Macho',
                        color: Colors.purple,
                      ),
                      StatusChip(
                        label: _getEstadoString(gallina.estado),
                        color: _getEstadoColor(gallina.estado),
                      ),
                      if (gallina.estaEnPicoProduccion)
                        StatusChip(
                          label: 'Pico Producción',
                          color: Colors.green,
                          icon: Icons.trending_up,
                        ),
                      if (gallina.debeDescartarse)
                        StatusChip(
                          label: 'Descartar',
                          color: Colors.red,
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
            if (gallina.identification != null)
              InfoCard(
                label: 'Identificación',
                value: gallina.identification!,
                icon: Icons.tag,
              ),
            if (gallina.identification != null) const SizedBox(height: 8),
            InfoCard(
              label: 'Fecha de Nacimiento',
              value: dateFormat.format(gallina.fechaNacimiento),
              icon: Icons.calendar_today,
            ),
            const SizedBox(height: 8),
            InfoCard(
              label: 'Edad',
              value: '${gallina.edadEnSemanas} semanas',
              icon: Icons.cake,
            ),
            if (gallina.raza != null) ...[
              const SizedBox(height: 8),
              InfoCard(
                label: 'Raza',
                value: gallina.raza!,
                icon: Icons.agriculture,
              ),
            ],
            // Lote
            if (gallina.loteId != null || gallina.fechaIngresoLote != null) ...[
              const SizedBox(height: 24),
              Text(
                'Información de Lote',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              if (gallina.loteId != null)
                InfoCard(
                  label: 'ID del Lote',
                  value: gallina.loteId!,
                  icon: Icons.group,
                ),
              if (gallina.fechaIngresoLote != null) ...[
                const SizedBox(height: 8),
                InfoCard(
                  label: 'Fecha de Ingreso al Lote',
                  value: dateFormat.format(gallina.fechaIngresoLote!),
                  icon: Icons.calendar_today,
                ),
              ],
            ],
            // Notas
            if (gallina.notes != null && gallina.notes!.isNotEmpty) ...[
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
                child: Text(gallina.notes!),
              ),
            ],
            const SizedBox(height: 32),
            // Botón de acción
            CustomButton(
              label: 'Editar',
              icon: Icons.edit,
              onPressed: () => _navigateToEdit(context),
            ),
          ],
        ),
      ),
    );
  }

  Color _getEstadoColor(EstadoGallina estado) {
    switch (estado) {
      case EstadoGallina.activa:
        return Colors.green;
      case EstadoGallina.enferma:
        return Colors.red;
      case EstadoGallina.muerta:
        return Colors.grey;
      case EstadoGallina.descartada:
        return Colors.orange;
    }
  }

  String _getEstadoString(EstadoGallina estado) {
    switch (estado) {
      case EstadoGallina.activa:
        return 'Activa';
      case EstadoGallina.enferma:
        return 'Enferma';
      case EstadoGallina.muerta:
        return 'Muerta';
      case EstadoGallina.descartada:
        return 'Descartada';
    }
  }
}

