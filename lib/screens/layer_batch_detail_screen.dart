import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';
import '../models/layer_batch.dart';
import '../models/layer_production_record.dart';
import 'layer_batch_form_screen.dart';
import 'layer_production_record_form_screen.dart';
import '../widgets/layer_production_chart.dart';

class LayerBatchDetailScreen extends StatefulWidget {
  final Farm farm;
  final LayerBatch batch;

  const LayerBatchDetailScreen({
    super.key,
    required this.farm,
    required this.batch,
  });

  @override
  State<LayerBatchDetailScreen> createState() => _LayerBatchDetailScreenState();
}

class _LayerBatchDetailScreenState extends State<LayerBatchDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FarmProvider>(
      builder: (context, farmProvider, _child) {
        final updatedFarm = farmProvider.farms.firstWhere(
          (f) => f.id == widget.farm.id,
          orElse: () => widget.farm,
        );

        final updatedBatch = updatedFarm.layerBatches.firstWhere(
          (b) => b.id == widget.batch.id,
          orElse: () => widget.batch,
        );

        final records = farmProvider.getLayerProductionRecordsByBatchId(
          updatedBatch.id,
          farmId: updatedFarm.id,
        );

        final porcentajePostura = updatedBatch.calcularPorcentajePostura(records);
        final estadoColor = Color(updatedBatch.getColorEstado(records));
        final estadoTexto = updatedBatch.getEstadoProduccion(records);

        return Scaffold(
          appBar: AppBar(
            title: Text(updatedBatch.nombreLote),
            backgroundColor: widget.farm.primaryColor,
            foregroundColor: Colors.white,
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(text: 'Información', icon: Icon(Icons.info)),
                Tab(text: 'Estadísticas', icon: Icon(Icons.bar_chart)),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LayerBatchFormScreen(
                        farm: updatedFarm,
                        batchToEdit: updatedBatch,
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmDelete(context, farmProvider, updatedBatch),
              ),
            ],
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildInfoTab(context, updatedBatch, records, porcentajePostura, estadoColor, estadoTexto, updatedFarm, farmProvider),
              _buildStatisticsTab(context, updatedBatch, records),
            ],
          ),
          floatingActionButton: Builder(
            builder: (context) {
              return _tabController.index == 0
                  ? FloatingActionButton.extended(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LayerProductionRecordFormScreen(
                              farm: updatedFarm,
                              batch: updatedBatch,
                            ),
                          ),
                        );
                      },
                      backgroundColor: widget.farm.primaryColor,
                      icon: const Icon(Icons.add),
                      label: const Text('Registrar Producción'),
                    )
                  : const SizedBox.shrink();
            },
          ),
        );
      },
    );
  }

  Widget _buildInfoTab(
    BuildContext context,
    LayerBatch batch,
    List<LayerProductionRecord> records,
    double porcentajePostura,
    Color estadoColor,
    String estadoTexto,
    Farm farm,
    FarmProvider farmProvider,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Estado de producción
          _buildProductionStatusCard(context, batch, records, porcentajePostura, estadoColor, estadoTexto),
          const SizedBox(height: 16),

          // Información del lote
          _buildInfoCard(context, batch),
          const SizedBox(height: 16),

          // Resumen de producción
          _buildProductionSummaryCard(context, records, batch),
          const SizedBox(height: 16),

          // Registros de producción
          _buildProductionRecordsSection(context, records, farm, batch, farmProvider),
        ],
      ),
    );
  }

  Widget _buildStatisticsTab(
    BuildContext context,
    LayerBatch batch,
    List<LayerProductionRecord> records,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gráfico de curva de postura
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Curva de Postura',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Porcentaje de Postura vs Semanas de Vida',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: LayerProductionChart(
                      batch: batch,
                      records: records,
                      primaryColor: widget.farm.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildLegendItem(widget.farm.primaryColor, 'Porcentaje de Postura'),
                      const SizedBox(width: 16),
                      _buildLegendItem(Colors.red, 'Alerta (caída >5%)'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildProductionStatusCard(
    BuildContext context,
    LayerBatch batch,
    List<LayerProductionRecord> records,
    double porcentajePostura,
    Color estadoColor,
    String estadoTexto,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Estado de Producción',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: estadoColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    estadoTexto,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '${porcentajePostura.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: estadoColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Postura',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                Container(
                  height: 50,
                  width: 1,
                  color: Colors.grey[300],
                ),
                Column(
                  children: [
                    Text(
                      '${batch.cantidadGallinas}',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: widget.farm.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Gallinas',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                Container(
                  height: 50,
                  width: 1,
                  color: Colors.grey[300],
                ),
                Column(
                  children: [
                    Text(
                      '${batch.semanasVida}',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Semanas',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            if (batch.debeDescartarse) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Este lote debe ser descartado (> 100 semanas)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, LayerBatch batch) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información del Lote',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Fecha de Nacimiento', DateFormat('dd/MM/yyyy').format(batch.fechaNacimiento)),
            _buildInfoRow('Fecha de Ingreso', DateFormat('dd/MM/yyyy').format(batch.fechaIngreso)),
            _buildInfoRow('Cantidad de Gallinas', '${batch.cantidadGallinas}'),
            _buildInfoRow('Semanas de Vida', '${batch.semanasVida}'),
            if (batch.precioPorCarton != null)
              _buildInfoRow(
                'Precio por Cartón',
                NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(batch.precioPorCarton),
              ),
            if (batch.estaEnPicoProduccion)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.trending_up, color: Colors.green, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'En pico de producción (18-30 semanas)',
                      style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[600]),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildProductionSummaryCard(
    BuildContext context,
    List<LayerProductionRecord> records,
    LayerBatch batch,
  ) {
    if (records.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text('No hay registros de producción'),
          ),
        ),
      );
    }

    final hoy = DateTime.now();
    final registroHoy = records.firstWhere(
      (r) => r.fecha.year == hoy.year && r.fecha.month == hoy.month && r.fecha.day == hoy.day,
      orElse: () => records.first,
    );

    final totalHuevos = registroHoy.cantidadHuevos;
    final cartones = registroHoy.cartones;
    final huevosSueltos = registroHoy.huevosSueltos;
    final ganancia = registroHoy.gananciaEstimada;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Producción de Hoy',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '$totalHuevos',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: widget.farm.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Huevos',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                Container(
                  height: 50,
                  width: 1,
                  color: Colors.grey[300],
                ),
                Column(
                  children: [
                    Text(
                      '$cartones',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cartones + $huevosSueltos',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                if (ganancia > 0) ...[
                  Container(
                    height: 50,
                    width: 1,
                    color: Colors.grey[300],
                  ),
                  Column(
                    children: [
                      Text(
                        NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(ganancia),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Ganancia',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductionRecordsSection(
    BuildContext context,
    List<LayerProductionRecord> records,
    Farm farm,
    LayerBatch batch,
    FarmProvider farmProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Historial de Producción',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (records.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: Text('No hay registros de producción')),
            ),
          )
        else
          ...records.take(10).map((record) => Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: widget.farm.primaryColor.withValues(alpha: 0.1),
                    child: Icon(Icons.egg, color: widget.farm.primaryColor),
                  ),
                  title: Text(
                    '${record.cantidadHuevos} huevos - ${record.cartones} cartones y ${record.huevosSueltos} sueltos',
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(DateFormat('dd/MM/yyyy').format(record.fecha)),
                      if (record.cantidadHuevosRotos > 0)
                        Text(
                          '${record.cantidadHuevosRotos} rotos',
                          style: const TextStyle(color: Colors.red),
                        ),
                      if (record.gananciaEstimada > 0)
                        Text(
                          'Ganancia: ${NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(record.gananciaEstimada)}',
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LayerProductionRecordFormScreen(
                                farm: farm,
                                batch: batch,
                                recordToEdit: record,
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                        onPressed: () => _confirmDeleteRecord(context, farmProvider, record),
                      ),
                    ],
                  ),
                ),
              )),
      ],
    );
  }

  void _confirmDelete(BuildContext context, FarmProvider farmProvider, LayerBatch batch) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Lote'),
        content: Text('¿Estás seguro de que quieres eliminar el lote "${batch.nombreLote}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await farmProvider.deleteLayerBatch(batch.id, farmId: widget.farm.id);
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Lote eliminado')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteRecord(BuildContext context, FarmProvider farmProvider, LayerProductionRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Registro'),
        content: const Text('¿Eliminar este registro de producción?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await farmProvider.deleteLayerProductionRecord(record.id, farmId: widget.farm.id);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Registro eliminado')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

