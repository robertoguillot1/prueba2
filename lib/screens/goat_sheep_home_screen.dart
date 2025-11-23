import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';
import '../models/goat_sheep.dart';
import '../widgets/summary_card.dart';
import 'goat_sheep_inventory_screen.dart';
import 'goat_sheep_vaccines_screen.dart';

class GoatSheepHomeScreen extends StatelessWidget {
  final Farm farm;

  const GoatSheepHomeScreen({super.key, required this.farm});

  @override
  Widget build(BuildContext context) {
    return Consumer<FarmProvider>(
      builder: (context, farmProvider, _child) {
        final updatedFarm = farmProvider.farms.firstWhere(
          (f) => f.id == farm.id,
          orElse: () => farm,
        );

        // Contar por tipo
        final chivosCount = updatedFarm.goatSheep.where((a) => a.type == GoatSheepType.chivo).length;
        final ovejasCount = updatedFarm.goatSheep.where((a) => a.type == GoatSheepType.oveja).length;
        final totalCount = updatedFarm.goatSheep.length;

        // Contar por estado reproductivo
        final gestantesCount = updatedFarm.goatSheep
            .where((a) => a.estadoReproductivo == EstadoReproductivo.gestante)
            .length;
        final nearPartoCount = updatedFarm.goatSheep.where((a) => a.isNearParto).length;

        return Scaffold(
          appBar: AppBar(
            title: const Text('🐑 Control Chivos/Ovejas'),
            centerTitle: true,
            backgroundColor: farm.primaryColor,
            foregroundColor: Colors.white,
          ),
          body: RefreshIndicator(
            onRefresh: farmProvider.loadFarms,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Resumen rápido
                  _buildQuickSummary(context, updatedFarm, chivosCount, ovejasCount, totalCount),
                  const SizedBox(height: 24),

                  // Estadísticas reproductivas
                  if (gestantesCount > 0 || nearPartoCount > 0)
                    _buildReproductiveStats(context, updatedFarm, gestantesCount, nearPartoCount),
                  if (gestantesCount > 0 || nearPartoCount > 0) const SizedBox(height: 24),

                  // Módulos de gestión
                  _buildManagementModules(context, updatedFarm),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickSummary(BuildContext context, Farm farm, int chivosCount, int ovejasCount, int totalCount) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              farm.primaryColor.withOpacity(0.1),
              Colors.purple.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              '🐑',
              style: TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 12),
            Text(
              'Inventario de Chivos/Ovejas',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: farm.primaryColor,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Total Animales',
                    '$totalCount',
                    Icons.pets,
                    Colors.purple[300]!,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Chivos',
                    '$chivosCount',
                    Icons.pets,
                    Colors.blue[300]!,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Ovejas',
                    '$ovejasCount',
                    Icons.pets,
                    Colors.pink[300]!,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildReproductiveStats(BuildContext context, Farm farm, int gestantesCount, int nearPartoCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estado Reproductivo',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            if (gestantesCount > 0)
              Expanded(
                child: SummaryCard(
                  title: 'Gestantes',
                  value: '$gestantesCount',
                  color: Colors.green,
                  icon: Icons.child_care,
                ),
              ),
            if (gestantesCount > 0 && nearPartoCount > 0) const SizedBox(width: 16),
            if (nearPartoCount > 0)
              Expanded(
                child: SummaryCard(
                  title: 'Cerca del Parto',
                  value: '$nearPartoCount',
                  color: Colors.orange,
                  icon: Icons.warning,
                ),
              ),
          ],
        ),
        if (nearPartoCount > 0) ...[
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            color: Colors.orange[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: Colors.orange[700],
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '⚠️ Alerta',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[700],
                              ),
                        ),
                        Text(
                          '$nearPartoCount animal${nearPartoCount > 1 ? 'es' : ''} cerca del parto (≤ 10 días)',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildManagementModules(BuildContext context, Farm farm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Módulos de Gestión',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildModuleButton(
              context,
              icon: Icons.list,
              title: 'Inventario',
              subtitle: '${farm.goatSheep.length} animales',
              color: Colors.purple[300]!,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GoatSheepInventoryScreen(farm: farm),
                  ),
                );
              },
            ),
            _buildModuleButton(
              context,
              icon: Icons.medical_services,
              title: 'Control de Vacunas',
              subtitle: 'Registro y seguimiento',
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GoatSheepVaccinesScreen(farm: farm),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModuleButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontSize: 11,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

