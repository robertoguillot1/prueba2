import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/di/dependency_injection.dart' as di;
import '../../../../../core/di/dependency_injection.dart' show sl;
import '../../../../../features/cattle/domain/entities/milk_production_entity.dart';
import '../../../../../features/cattle/domain/entities/weight_record_entity.dart';
import '../../../../../features/cattle/domain/entities/bovine_entity.dart';
import '../../../../../features/cattle/domain/usecases/get_cattle_list.dart';
import '../cubits/farm_production_cubit.dart';
import '../../details/cubits/production_cubit.dart';
import '../../screens/bovino_detail_screen.dart';

/// Tipos de vista de producción
enum ProductionView { milk, weight }

/// Pantalla para ver todas las producciones (leche y peso) de una finca
class FarmProductionScreen extends StatelessWidget {
  final String farmId;

  const FarmProductionScreen({
    super.key,
    required this.farmId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.DependencyInjection.createFarmProductionCubit()
        ..loadProduction(farmId: farmId),
      child: _FarmProductionScreenContent(farmId: farmId),
    );
  }
}

class _FarmProductionScreenContent extends StatefulWidget {
  final String farmId;

  const _FarmProductionScreenContent({required this.farmId});

  @override
  State<_FarmProductionScreenContent> createState() => _FarmProductionScreenContentState();
}

class _FarmProductionScreenContentState extends State<_FarmProductionScreenContent> {
  ProductionView _selectedView = ProductionView.milk;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Producción (Leche y Peso)'),
        centerTitle: true,
      ),
      body: BlocBuilder<FarmProductionCubit, ProductionState>(
        builder: (context, state) {
          if (state is ProductionLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProductionError) {
            return _buildErrorState(context, state.message);
          }

          if (state is ProductionLoaded) {
            return Column(
              children: [
                // Toggle de vista
                _buildViewToggle(),
                
                // Contenido según la vista seleccionada
                Expanded(
                  child: _selectedView == ProductionView.milk
                      ? _buildMilkView(context, state.leche)
                      : _buildWeightView(context, state.pesos),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildViewToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SegmentedButton<ProductionView>(
        segments: const [
          ButtonSegment(
            value: ProductionView.milk,
            label: Text('Leche'),
            icon: Icon(Icons.local_drink),
          ),
          ButtonSegment(
            value: ProductionView.weight,
            label: Text('Peso'),
            icon: Icon(Icons.monitor_weight),
          ),
        ],
        selected: {_selectedView},
        onSelectionChanged: (Set<ProductionView> selected) {
          setState(() {
            _selectedView = selected.first;
          });
        },
      ),
    );
  }

  Widget _buildMilkView(BuildContext context, List<MilkProductionEntity> records) {
    if (records.isEmpty) {
      return _buildEmptyState(
        context,
        icon: Icons.local_drink,
        title: 'Sin registros de leche',
        message: 'Aún no hay registros de producción de leche en esta finca.\nRegistra la producción desde el detalle de cada bovino.',
      );
    }

    // Calcular estadísticas
    final total = records.fold<double>(0, (sum, r) => sum + r.litersProduced);
    final average = total / records.length;
    final last7Days = records.where((r) {
      final daysDiff = DateTime.now().difference(r.recordDate).inDays;
      return daysDiff <= 7;
    }).toList();
    final avg7Days = last7Days.isEmpty
        ? 0.0
        : last7Days.fold<double>(0, (sum, r) => sum + r.litersProduced) / last7Days.length;

    return RefreshIndicator(
      onRefresh: () => context.read<FarmProductionCubit>().refresh(farmId: widget.farmId),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Estadísticas
          _buildMilkStats(average, avg7Days, records.length),
          const SizedBox(height: 24),

          // Título
          Text(
            'Registros de Producción (${records.length})',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          // Lista de registros
          ...records.map((record) => _buildMilkRecordCard(context, record)),
        ],
      ),
    );
  }

  Widget _buildWeightView(BuildContext context, List<WeightRecordEntity> records) {
    if (records.isEmpty) {
      return _buildEmptyState(
        context,
        icon: Icons.monitor_weight,
        title: 'Sin registros de peso',
        message: 'Aún no hay registros de peso en esta finca.\nRegistra el peso desde el detalle de cada bovino.',
      );
    }

    // Calcular estadísticas
    final latest = records.first;
    final oldest = records.last;
    final average = records.fold<double>(0, (sum, r) => sum + r.weight) / records.length;

    return RefreshIndicator(
      onRefresh: () => context.read<FarmProductionCubit>().refresh(farmId: widget.farmId),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Estadísticas
          _buildWeightStats(latest.weight, average, records.length),
          const SizedBox(height: 24),

          // Título
          Text(
            'Registros de Peso (${records.length})',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          // Lista de registros
          ...records.asMap().entries.map((entry) {
            final index = entry.key;
            final record = entry.value;
            final previousRecord = index < records.length - 1 ? records[index + 1] : null;
            return _buildWeightRecordCard(context, record, previousRecord);
          }),
        ],
      ),
    );
  }

  Widget _buildMilkStats(double average, double avg7Days, int totalRecords) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Promedio Total',
            '${average.toStringAsFixed(1)}L',
            Icons.analytics,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Últimos 7 días',
            '${avg7Days.toStringAsFixed(1)}L',
            Icons.calendar_today,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Total Registros',
            '$totalRecords',
            Icons.list,
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildWeightStats(double latest, double average, int totalRecords) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Peso Promedio',
            '${average.toStringAsFixed(1)}kg',
            Icons.analytics,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Último Registro',
            '${latest.toStringAsFixed(1)}kg',
            Icons.monitor_weight,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Total Registros',
            '$totalRecords',
            Icons.list,
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMilkRecordCard(BuildContext context, MilkProductionEntity record) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: InkWell(
        onTap: () => _navigateToBovine(context, record.bovineId),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_drink,
                  color: Colors.blue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${record.litersProduced.toStringAsFixed(1)} litros',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => _navigateToBovine(context, record.bovineId),
                          child: const Text('Ver Bovino'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          dateFormat.format(record.recordDate),
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                    if (record.notes != null && record.notes!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        record.notes!,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeightRecordCard(
    BuildContext context,
    WeightRecordEntity record,
    WeightRecordEntity? previousRecord,
  ) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final double? gain = previousRecord != null
        ? record.weight - previousRecord.weight
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: InkWell(
        onTap: () => _navigateToBovine(context, record.bovineId),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.monitor_weight,
                  color: Colors.green,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${record.weight.toStringAsFixed(1)} kg',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (gain != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: gain >= 0
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${gain >= 0 ? '+' : ''}${gain.toStringAsFixed(1)} kg',
                              style: TextStyle(
                                color: gain >= 0 ? Colors.green : Colors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        TextButton(
                          onPressed: () => _navigateToBovine(context, record.bovineId),
                          child: const Text('Ver Bovino'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          dateFormat.format(record.recordDate),
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                    if (record.notes != null && record.notes!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        record.notes!,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            'Error al cargar producciones',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.read<FarmProductionCubit>().refresh(farmId: widget.farmId),
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  void _navigateToBovine(BuildContext context, String bovineId) async {
    try {
      final getCattleList = sl<GetCattleList>();
      final result = await getCattleList(GetCattleListParams(farmId: widget.farmId));

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
        },
        (bovines) {
          // Normalizar a BovineEntity para evitar problemas de tipo
          final List<BovineEntity> list = bovines.map((b) => b as BovineEntity).toList();

          if (list.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No se encontró el bovino'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          final bovine = list.firstWhere(
            (b) => b.id == bovineId,
            orElse: () => list.first,
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BovinoDetailScreen(
                bovine: bovine,
                farmId: widget.farmId,
              ),
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al navegar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}


