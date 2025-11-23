import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/bovinos_viewmodel.dart';
import '../edit/bovino_edit_screen.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: Text(bovino.name ?? bovino.identification ?? 'Bovino'),
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
                    backgroundColor: Colors.brown.shade300,
                    child: const Icon(
                      Icons.pets,
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
                  Text(
                    bovino.identification ?? 'Sin identificación',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Información básica
            InfoCard(
              title: 'Información Básica',
              children: [
                _buildInfoRow('Identificación', bovino.identification ?? 'N/A'),
                _buildInfoRow('Fecha de Nacimiento',
                  bovino.birthDate != null
                    ? dateFormat.format(bovino.birthDate)
                    : 'N/A'),
                _buildInfoRow('Categoría', bovino.category.toString()),
                _buildInfoRow('Género', bovino.gender.toString()),
                _buildInfoRow('Peso Actual', '${bovino.currentWeight} kg'),
              ],
            ),
            const SizedBox(height: 16),
            // Estado de salud
            InfoCard(
              title: 'Estado de Salud',
              children: [
                _buildInfoRow('Estado', bovino.healthStatus.toString()),
                if (bovino.breedingStatus != null)
                  _buildInfoRow('Estado Reproductivo', bovino.breedingStatus.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
