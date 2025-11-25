import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';
import '../models/broiler_batch.dart';
import '../models/layer_batch.dart';
import 'broiler_batch_form_screen.dart';
import 'layer_batch_form_screen.dart';
import 'broiler_batch_detail_screen.dart';
import 'layer_batch_detail_screen.dart';

class PoultryHomeScreen extends StatefulWidget {
  final Farm farm;

  const PoultryHomeScreen({super.key, required this.farm});

  @override
  State<PoultryHomeScreen> createState() => _PoultryHomeScreenState();
}

class _PoultryHomeScreenState extends State<PoultryHomeScreen> with SingleTickerProviderStateMixin {
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

        return Scaffold(
          appBar: AppBar(
            title: const Text('🐔 Avicultura'),
            centerTitle: true,
            backgroundColor: updatedFarm.primaryColor,
            foregroundColor: Colors.white,
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(text: 'Engorde', icon: Icon(Icons.trending_up)),
                Tab(text: 'Ponedoras', icon: Icon(Icons.egg)),
              ],
            ),
          ),
          body: RefreshIndicator(
            onRefresh: farmProvider.loadFarms,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBroilerTab(context, updatedFarm, farmProvider),
                _buildLayerTab(context, updatedFarm, farmProvider),
              ],
            ),
          ),
          floatingActionButton: Builder(
            builder: (context) {
              return FloatingActionButton.extended(
                onPressed: () async {
                  if (_tabController.index == 0) {
                    // Crear nuevo lote de engorde
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BroilerBatchFormScreen(farm: updatedFarm),
                      ),
                    );
                  } else {
                    // Crear nuevo lote de ponedoras
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LayerBatchFormScreen(farm: updatedFarm),
                      ),
                    );
                  }
                },
                backgroundColor: updatedFarm.primaryColor,
                icon: const Icon(Icons.add),
                label: Text(_tabController.index == 0 ? 'Nuevo Lote Engorde' : 'Nuevo Lote Ponedoras'),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBroilerTab(BuildContext context, Farm farm, FarmProvider farmProvider) {
    final batches = farm.broilerBatches.toList()
      ..sort((a, b) => b.fechaIngreso.compareTo(a.fechaIngreso));

    if (batches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.egg,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay lotes de engorde',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Crea tu primer lote de pollos de engorde',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resumen rápido
          _buildBroilerSummary(context, batches),
          const SizedBox(height: 24),

          // Lista de lotes
          const Text(
            'Lotes Activos',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...batches.map((batch) => _buildBroilerBatchCard(context, batch, farm)),
        ],
      ),
    );
  }

  Widget _buildBroilerSummary(BuildContext context, List<BroilerBatch> batches) {
    final totalPollos = batches.fold<int>(0, (sum, b) => sum + b.cantidadActual);
    final totalLotes = batches.length;
    final lotesCercaSacrificio = batches.where((b) => b.diasParaSacrificio <= 10).length;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    '$totalLotes',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: widget.farm.primaryColor,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Lotes',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
            Container(
              height: 40,
              width: 1,
              color: Colors.grey[300],
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    '$totalPollos',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pollos',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
            Container(
              height: 40,
              width: 1,
              color: Colors.grey[300],
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    '$lotesCercaSacrificio',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: lotesCercaSacrificio > 0 ? Colors.red : Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Cerca sacrificio',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBroilerBatchCard(BuildContext context, BroilerBatch batch, Farm farm) {
    final progreso = batch.progresoPorcentaje;
    final diasRestantes = batch.diasParaSacrificio;
    final necesitaAlimento = batch.necesitaComprarAlimento;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BroilerBatchDetailScreen(farm: farm, batch: batch),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      batch.nombreLote,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (necesitaAlimento)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning, size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'Comprar Alimento',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Barra de progreso
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Día ${batch.edadActualDias} de ${batch.metaSacrificioDias}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${progreso.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: widget.farm.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progreso / 100,
                      minHeight: 8,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        diasRestantes <= 10 ? Colors.orange : widget.farm.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Información del lote
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      Icons.pets,
                      'Pollos',
                      '${batch.cantidadActual}',
                      Colors.blue,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.monitor_weight,
                      'Peso',
                      '${(batch.pesoPromedioActual / 1000).toStringAsFixed(2)} kg',
                      Colors.green,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.schedule,
                      'Días restantes',
                      '$diasRestantes',
                      diasRestantes <= 10 ? Colors.red : Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Peso actual vs esperado
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.farm.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Peso Actual',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          '${(batch.pesoPromedioActual / 1000).toStringAsFixed(2)} kg',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Text('vs'),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Peso Esperado',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          '${batch.pesoEsperadoKg.toStringAsFixed(2)} kg',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildLayerTab(BuildContext context, Farm farm, FarmProvider farmProvider) {
    final batches = farm.layerBatches.toList()
      ..sort((a, b) => b.fechaIngreso.compareTo(a.fechaIngreso));

    if (batches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.egg,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay lotes de ponedoras',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Crea tu primer lote de gallinas ponedoras',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resumen rápido
          _buildLayerSummary(context, batches, farm),
          const SizedBox(height: 24),

          // Lista de lotes
          const Text(
            'Lotes Activos',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...batches.map((batch) => _buildLayerBatchCard(context, batch, farm, farmProvider)),
        ],
      ),
    );
  }

  Widget _buildLayerSummary(BuildContext context, List<LayerBatch> batches, Farm farm) {
    final totalGallinas = batches.fold<int>(0, (sum, b) => sum + b.cantidadGallinas);
    final totalLotes = batches.length;
    final enPico = batches.where((b) => b.estaEnPicoProduccion).length;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    '$totalLotes',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: widget.farm.primaryColor,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Lotes',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
            Container(
              height: 40,
              width: 1,
              color: Colors.grey[300],
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    '$totalGallinas',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Gallinas',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
            Container(
              height: 40,
              width: 1,
              color: Colors.grey[300],
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    '$enPico',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'En pico',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLayerBatchCard(BuildContext context, LayerBatch batch, Farm farm, FarmProvider farmProvider) {
    final records = farmProvider.getLayerProductionRecordsByBatchId(batch.id, farmId: farm.id);
    final porcentajePostura = batch.calcularPorcentajePostura(records);
    final estadoColor = Color(batch.getColorEstado(records));
    final estadoTexto = batch.getEstadoProduccion(records);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LayerBatchDetailScreen(farm: farm, batch: batch),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      batch.nombreLote,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: estadoColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      estadoTexto,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Información del lote
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      Icons.pets,
                      'Gallinas',
                      '${batch.cantidadGallinas}',
                      Colors.blue,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.calendar_today,
                      'Semanas',
                      '${batch.semanasVida}',
                      Colors.purple,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.percent,
                      'Postura',
                      '${porcentajePostura.toStringAsFixed(0)}%',
                      estadoColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Estado de producción
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: estadoColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: estadoColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Porcentaje de Postura',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          '${porcentajePostura.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: estadoColor,
                          ),
                        ),
                      ],
                    ),
                    if (batch.debeDescartarse)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.warning, size: 14, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'Descartar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

