import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/di/dependency_injection.dart' as di;
import '../../../../../domain/entities/bovinos/produccion_leche.dart';
import '../../../../../domain/entities/bovinos/peso_bovino.dart';
import '../../../../../features/cattle/domain/entities/bovine_entity.dart';
import '../cubits/production_cubit.dart';
import '../forms/milk_production_form_screen.dart';
import '../forms/weight_record_form_screen.dart';
import '../../widgets/leche_diaria_chart.dart';
import '../../widgets/peso_chart.dart';

/// Pestaña de Producción en el detalle del bovino
class ProductionTab extends StatelessWidget {
  final BovineEntity bovine;
  final String farmId;

  const ProductionTab({
    super.key,
    required this.bovine,
    required this.farmId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.DependencyInjection.createProductionCubit()
        ..loadProduction(bovineId: bovine.id, farmId: farmId),
      child: _ProductionTabContent(
        bovine: bovine,
        farmId: farmId,
      ),
    );
  }
}

/// Tipos de vista de producción
enum ProductionView { milk, weight }

class _ProductionTabContent extends StatefulWidget {
  final BovineEntity bovine;
  final String farmId;

  const _ProductionTabContent({
    required this.bovine,
    required this.farmId,
  });

  @override
  State<_ProductionTabContent> createState() => _ProductionTabContentState();
}

class _ProductionTabContentState extends State<_ProductionTabContent> {
  ProductionView _selectedView = ProductionView.weight;

  @override
  void initState() {
    super.initState();
    // Si el bovino es para leche, mostrar vista de leche por defecto
    if (_canProduceMilk) {
      _selectedView = ProductionView.milk;
    }
  }

  /// Verifica si el bovino puede producir leche
  bool get _canProduceMilk {
    // Solo hembras y propósito leche o doble propósito
    return widget.bovine.gender == BovineGender.female &&
        (widget.bovine.purpose == BovinePurpose.milk ||
            widget.bovine.purpose == BovinePurpose.dual);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Scaffold dentro del TabBarView para tener FAB local
      body: BlocBuilder<ProductionCubit, ProductionState>(
        builder: (context, state) {
          if (state is ProductionLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProductionError) {
            return _buildErrorState(context, state.message);
          }

          if (state is ProductionLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<ProductionCubit>().refresh(
                      bovineId: widget.bovine.id,
                      farmId: widget.farmId,
                    );
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: Column(
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
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
      // FAB persistente que cambia según la vista
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  /// Botón flotante que se adapta a la vista actual
  Widget _buildFloatingActionButton(BuildContext context) {
    // Si no puede producir leche y está en vista de leche, no mostrar FAB
    if (_selectedView == ProductionView.milk && !_canProduceMilk) {
      return const SizedBox.shrink();
    }

    final isMilkView = _selectedView == ProductionView.milk;

    return FloatingActionButton(
      onPressed: () {
        // Lógica INTELIGENTE basada en la vista seleccionada
        if (isMilkView) {
          // Vista Leche -> Ir a Formulario de Leche
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MilkProductionFormScreen(
                bovine: widget.bovine,
                farmId: widget.farmId,
              ),
            ),
          ).then((result) {
            // Recargar datos si se agregó un registro exitosamente
            if (result == true && context.mounted) {
              context.read<ProductionCubit>().refresh(
                    bovineId: widget.bovine.id,
                    farmId: widget.farmId,
                  );
            }
          });
        } else {
          // Vista Peso -> Ir a Formulario de Peso
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WeightRecordFormScreen(
                bovine: widget.bovine,
                farmId: widget.farmId,
              ),
            ),
          ).then((result) {
            // Recargar datos si se agregó un registro exitosamente
            if (result == true && context.mounted) {
              context.read<ProductionCubit>().refresh(
                    bovineId: widget.bovine.id,
                    farmId: widget.farmId,
                  );
            }
          });
        }
      },
      // Icono específico según la vista: gota para leche, báscula para peso
      child: Icon(isMilkView ? Icons.water_drop : Icons.monitor_weight),
      // Color según la acción: azul para leche, verde para peso
      backgroundColor: isMilkView ? Colors.blue : Colors.green,
      heroTag: 'production_fab_${widget.bovine.id}', // Evitar conflictos de Hero
    );
  }

  /// Toggle para cambiar entre vistas
  Widget _buildViewToggle() {
    // Si no puede producir leche, solo mostrar opción de peso
    if (!_canProduceMilk) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.monitor_weight, color: Colors.grey.shade600),
                const SizedBox(width: 12),
                Text(
                  'Historial de Peso',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ),
      );
    }

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

  /// Vista de producción de leche
  Widget _buildMilkView(BuildContext context, List<ProduccionLeche> records) {
    if (records.isEmpty) {
      return _buildEmptyState(
        context,
        icon: Icons.local_drink,
        title: 'Sin registros de leche',
        message: 'Comienza a registrar la producción diaria de leche',
        onAdd: _showAddMilkDialog,
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Gráfico de producción de leche
        LecheDiariaChart(registros: records),
        const SizedBox(height: 24),

        // Estadísticas
        _buildMilkStats(records),
        const SizedBox(height: 24),

        // Lista de registros
        ...records.map((record) => _buildMilkRecordCard(context, record)),

        const SizedBox(height: 80), // Espacio para el FAB
      ],
    );
  }

  /// Vista de historial de peso
  Widget _buildWeightView(BuildContext context, List<PesoBovino> records) {
    if (records.isEmpty) {
      return _buildEmptyState(
        context,
        icon: Icons.monitor_weight,
        title: 'Sin registros de peso',
        message: 'Registra el peso del animal periódicamente para monitorear su crecimiento',
        onAdd: _showAddWeightDialog,
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Gráfico de evolución de peso
        PesoChart(registros: records),
        const SizedBox(height: 24),

        // Estadísticas
        _buildWeightStats(records),
        const SizedBox(height: 24),

        // Lista de registros
        ...records.asMap().entries.map((entry) {
          final index = entry.key;
          final record = entry.value;
          final previousRecord = index < records.length - 1 ? records[index + 1] : null;
          return _buildWeightRecordCard(context, record, previousRecord);
        }),

        const SizedBox(height: 80), // Espacio para el FAB
      ],
    );
  }

  /// Estadísticas de leche
  Widget _buildMilkStats(List<ProduccionLeche> records) {
    if (records.isEmpty) return const SizedBox.shrink();

    final total = records.fold<double>(0, (sum, r) => sum + r.litersProduced);
    final average = total / records.length;
    final last7Days = records.take(7).toList();
    final avg7Days = last7Days.isEmpty
        ? 0.0
        : last7Days.fold<double>(0, (sum, r) => sum + r.litersProduced) / last7Days.length;

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
      ],
    );
  }

  /// Estadísticas de peso
  Widget _buildWeightStats(List<PesoBovino> records) {
    if (records.isEmpty) return const SizedBox.shrink();

    final latest = records.first;
    final oldest = records.last;
    final gain = latest.weight - oldest.weight;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Peso Actual',
            '${latest.weight.toStringAsFixed(1)}kg',
            Icons.monitor_weight,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Ganancia Total',
            '${gain >= 0 ? '+' : ''}${gain.toStringAsFixed(1)}kg',
            gain >= 0 ? Icons.trending_up : Icons.trending_down,
            gain >= 0 ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }

  /// Tarjeta de estadística
  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Tarjeta de registro de leche
  Widget _buildMilkRecordCard(BuildContext context, ProduccionLeche record) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.local_drink, color: Colors.blue),
        ),
        title: Text(
          '${record.litersProduced.toStringAsFixed(1)} Litros',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(dateFormat.format(record.recordDate)),
        trailing: record.notes != null
            ? const Icon(Icons.notes, size: 20, color: Colors.grey)
            : null,
        onTap: () => _showRecordDetails(context, record),
      ),
    );
  }

  /// Tarjeta de registro de peso
  Widget _buildWeightRecordCard(
    BuildContext context,
    PesoBovino record,
    PesoBovino? previousRecord,
  ) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final gain = previousRecord != null ? record.weight - previousRecord.weight : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.monitor_weight, color: Colors.green),
        ),
        title: Text(
          '${record.weight.toStringAsFixed(1)} kg',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dateFormat.format(record.recordDate)),
            if (gain != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    gain >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 14,
                    color: gain >= 0 ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${gain >= 0 ? '+' : ''}${gain.toStringAsFixed(1)}kg',
                    style: TextStyle(
                      fontSize: 12,
                      color: gain >= 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: record.notes != null
            ? const Icon(Icons.notes, size: 20, color: Colors.grey)
            : null,
        onTap: () => _showRecordDetails(context, record),
      ),
    );
  }

  /// Estado vacío (sin botón, el FAB maneja la acción)
  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
    required VoidCallback onAdd, // Mantenido para compatibilidad
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade500,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Mensaje visual que indica el FAB
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.touch_app, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Usa el botón flotante para agregar',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Estado de error
  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Error al cargar datos',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<ProductionCubit>().refresh(
                      bovineId: widget.bovine.id,
                      farmId: widget.farmId,
                    );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  /// Mostrar detalles de un registro
  void _showRecordDetails(BuildContext context, dynamic record) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    String title, value, date;
    String? notes;

    if (record is ProduccionLeche) {
      title = 'Producción de Leche';
      value = '${record.litersProduced.toStringAsFixed(1)} Litros';
      date = dateFormat.format(record.recordDate);
      notes = record.notes;
    } else if (record is PesoBovino) {
      title = 'Registro de Peso';
      value = '${record.weight.toStringAsFixed(1)} kg';
      date = dateFormat.format(record.recordDate);
      notes = record.notes;
    } else {
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Fecha: $date'),
            if (notes != null && notes.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Notas:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(notes),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  /// Mostrar formulario para agregar producción de leche
  void _showAddMilkDialog() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => MilkProductionFormScreen(
          bovine: widget.bovine,
          farmId: widget.farmId,
        ),
      ),
    );

    if (result == true && context.mounted) {
      context.read<ProductionCubit>().refresh(
            bovineId: widget.bovine.id,
            farmId: widget.farmId,
          );
    }
  }

  /// Mostrar formulario para agregar peso
  void _showAddWeightDialog() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => WeightRecordFormScreen(
          bovine: widget.bovine,
          farmId: widget.farmId,
        ),
      ),
    );

    if (result == true && context.mounted) {
      context.read<ProductionCubit>().refresh(
            bovineId: widget.bovine.id,
            farmId: widget.farmId,
          );
    }
  }
}

