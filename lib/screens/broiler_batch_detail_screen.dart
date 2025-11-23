import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';
import '../models/broiler_batch.dart';
import 'broiler_batch_form_screen.dart';
import '../widgets/broiler_growth_chart.dart';
import '../widgets/broiler_mortality_chart.dart';
import '../widgets/batch_financial_summary.dart';
import 'batch_balance_screen.dart';
import 'batch_expense_form_screen.dart';
import 'batch_sale_form_screen.dart';
import '../models/batch_expense.dart';
import '../models/batch_sale.dart';

class BroilerBatchDetailScreen extends StatefulWidget {
  final Farm farm;
  final BroilerBatch batch;

  const BroilerBatchDetailScreen({
    super.key,
    required this.farm,
    required this.batch,
  });

  @override
  State<BroilerBatchDetailScreen> createState() => _BroilerBatchDetailScreenState();
}

class _BroilerBatchDetailScreenState extends State<BroilerBatchDetailScreen> with SingleTickerProviderStateMixin {
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

        final updatedBatch = updatedFarm.broilerBatches.firstWhere(
          (b) => b.id == widget.batch.id,
          orElse: () => widget.batch,
        );

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
                      builder: (context) => BroilerBatchFormScreen(
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
              _buildInfoTab(context, updatedBatch),
              _buildStatisticsTab(context, updatedBatch),
            ],
          ),
          floatingActionButton: Builder(
            builder: (context) {
              if (_tabController.index == 0 && updatedBatch.estado == BatchStatus.activo) {
                // Botones en la pestaña de información solo si el lote está activo
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FloatingActionButton(
                      heroTag: "expense",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BatchExpenseFormScreen(
                              farm: updatedFarm,
                              batch: updatedBatch,
                            ),
                          ),
                        );
                      },
                      backgroundColor: Colors.orange,
                      child: const Icon(Icons.receipt),
                    ),
                    const SizedBox(height: 16),
                    FloatingActionButton.extended(
                      heroTag: "sale",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BatchSaleFormScreen(
                              farm: updatedFarm,
                              batch: updatedBatch,
                            ),
                          ),
                        );
                      },
                      backgroundColor: widget.farm.primaryColor,
                      icon: const Icon(Icons.sell),
                      label: const Text('Cerrar/Vender Lote'),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        );
      },
    );
  }

  Widget _buildInfoTab(BuildContext context, BroilerBatch batch) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barra de progreso
          _buildProgressCard(context, batch),
          const SizedBox(height: 16),

          // Información del lote
          _buildInfoCard(context, batch),
          const SizedBox(height: 16),

          // Peso actual vs esperado
          _buildWeightComparisonCard(context, batch),
          const SizedBox(height: 16),

          // Alimentación
          _buildFeedingCard(context, batch),
          const SizedBox(height: 16),

          // Estadísticas
          _buildStatsCard(context, batch),
          const SizedBox(height: 16),
          // Gastos registrados
          _buildExpensesSection(context, batch),
        ],
      ),
    );
  }

  Widget _buildExpensesSection(BuildContext context, BroilerBatch batch) {
    return Consumer<FarmProvider>(
      builder: (context, farmProvider, _child) {
        final updatedFarm = farmProvider.farms.firstWhere(
          (f) => f.id == widget.farm.id,
          orElse: () => widget.farm,
        );

        final expenses = farmProvider.getBatchExpensesByBatchId(batch.id, farmId: updatedFarm.id);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Gastos Registrados',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (batch.estado == BatchStatus.activo)
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BatchExpenseFormScreen(
                            farm: updatedFarm,
                            batch: batch,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (expenses.isEmpty)
              Card(
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text('No hay gastos registrados'),
                  ),
                ),
              )
            else
              ...expenses.take(5).map((expense) => Card(
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getExpenseTypeColor(expense.tipo).withOpacity(0.1),
                        child: Icon(
                          _getExpenseTypeIcon(expense.tipo),
                          color: _getExpenseTypeColor(expense.tipo),
                        ),
                      ),
                      title: Text(expense.concepto),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(DateFormat('dd/MM/yyyy').format(expense.fecha)),
                          if (expense.cantidad != null)
                            Text('${expense.cantidad!.toStringAsFixed(2)} ${_getExpenseTypeUnit(expense.tipo)}'),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(expense.monto),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          if (batch.estado == BatchStatus.activo)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 16),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BatchExpenseFormScreen(
                                          farm: updatedFarm,
                                          batch: batch,
                                          expenseToEdit: expense,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                                  onPressed: () => _confirmDeleteExpense(context, farmProvider, expense),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  )),
            if (expenses.length > 5)
              TextButton(
                onPressed: () {
                  // TODO: Navegar a pantalla completa de gastos
                },
                child: Text('Ver todos los gastos (${expenses.length})'),
              ),
          ],
        );
      },
    );
  }

  Color _getExpenseTypeColor(BatchExpenseType type) {
    return type.color;
  }

  IconData _getExpenseTypeIcon(BatchExpenseType type) {
    return type.icon;
  }

  String _getExpenseTypeUnit(BatchExpenseType type) {
    switch (type) {
      case BatchExpenseType.alimento:
        return 'bultos';
      case BatchExpenseType.medicina:
      case BatchExpenseType.vacunas:
      case BatchExpenseType.insumos:
      case BatchExpenseType.manoObra:
      case BatchExpenseType.otros:
        return 'unidades';
    }
  }

  void _confirmDeleteExpense(BuildContext context, FarmProvider farmProvider, BatchExpense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Gasto'),
        content: const Text('¿Eliminar este gasto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await farmProvider.deleteBatchExpense(expense.id, farmId: widget.farm.id);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Gasto eliminado')),
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

  Widget _buildStatisticsTab(BuildContext context, BroilerBatch batch) {
    return Consumer<FarmProvider>(
      builder: (context, farmProvider, _child) {
        final updatedFarm = farmProvider.farms.firstWhere(
          (f) => f.id == widget.farm.id,
          orElse: () => widget.farm,
        );

        final expenses = farmProvider.getBatchExpensesByBatchId(batch.id, farmId: updatedFarm.id);
        final sale = farmProvider.getBatchSaleByBatchId(batch.id, farmId: updatedFarm.id);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Resumen Financiero
              BatchFinancialSummary(
                batch: batch,
                expenses: expenses,
                sale: sale,
                primaryColor: widget.farm.primaryColor,
              ),
              const SizedBox(height: 16),
              // Botón para ver Balance Completo
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BatchBalanceScreen(
                        farm: widget.farm,
                        batch: batch,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.account_balance),
                label: const Text('Ver Balance Completo del Lote'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.farm.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 16),
              // Gráfico de crecimiento
              Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Curva de Crecimiento',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Peso Promedio (gramos) vs Días de Vida',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 250,
                    child: BroilerGrowthChart(
                      batch: batch,
                      primaryColor: widget.farm.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildLegendItem(Colors.grey.withOpacity(0.5), 'Estándar Ideal'),
                      const SizedBox(width: 16),
                      _buildLegendItem(widget.farm.primaryColor, 'Peso Actual'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Gráfico de mortalidad
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mortalidad',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: BroilerMortalityChart(batch: batch),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem(Colors.green, 'Vivos'),
                      const SizedBox(width: 16),
                      _buildLegendItem(Colors.red, 'Muertos'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
      },
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

  Widget _buildProgressCard(BuildContext context, BroilerBatch batch) {
    final progreso = batch.progresoPorcentaje;
    final diasRestantes = batch.diasParaSacrificio;

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
                  'Progreso del Lote',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: diasRestantes <= 10 ? Colors.orange : widget.farm.primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Día ${batch.edadActualDias} de ${batch.metaSacrificioDias}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progreso / 100,
                minHeight: 12,
                backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                  diasRestantes <= 10 ? Colors.orange : widget.farm.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${progreso.toStringAsFixed(0)}% completado - $diasRestantes días restantes',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, BroilerBatch batch) {
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
            _buildInfoRow('Fecha de Ingreso', DateFormat('dd/MM/yyyy').format(batch.fechaIngreso)),
            _buildInfoRow('Cantidad Inicial', '${batch.cantidadInicial} pollos'),
            _buildInfoRow('Cantidad Actual', '${batch.cantidadActual} pollos'),
            _buildInfoRow('Edad Inicial', '${batch.edadInicialDias} días'),
            _buildInfoRow('Edad Actual', '${batch.edadActualDias} días'),
            _buildInfoRow('Meta de Sacrificio', '${batch.metaSacrificioDias} días'),
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

  Widget _buildWeightComparisonCard(BuildContext context, BroilerBatch batch) {
    // Comparar peso actual (en gramos) con meta de peso (en gramos)
    final diferencia = batch.pesoPromedioActual - batch.metaPesoGramos;
    final esPositivo = diferencia >= 0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Peso Actual vs Esperado',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Peso Actual',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(batch.pesoPromedioActual / 1000).toStringAsFixed(2)} kg\n(${batch.pesoPromedioActual.toStringAsFixed(0)} g)',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const Text('vs', style: TextStyle(fontSize: 16)),
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Meta de Peso',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(batch.metaPesoGramos / 1000).toStringAsFixed(2)} kg\n(${batch.metaPesoGramos.toStringAsFixed(0)} g)',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: esPositivo ? Colors.green[50] : Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    esPositivo ? Icons.trending_up : Icons.trending_down,
                    color: esPositivo ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Diferencia: ${(diferencia / 1000).toStringAsFixed(2)} kg (${diferencia.toStringAsFixed(0)} g)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: esPositivo ? Colors.green : Colors.orange,
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

  Widget _buildFeedingCard(BuildContext context, BroilerBatch batch) {
    final consumoDiario = batch.consumoDiarioEstimadoKg;
    final necesitaAlimento = batch.necesitaComprarAlimento;

    return Card(
      elevation: 2,
      color: necesitaAlimento ? Colors.red[50] : null,
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
                  'Alimentación',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
            // Información de etapa y tipo de alimento
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700], size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Etapa: ${batch.etapaActualNombre}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Alimento Recomendado: ${batch.tipoAlimentoRecomendado}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[800],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Stock Actual', '${batch.stockAlimentoActualKg.toStringAsFixed(2)} kg'),
            _buildInfoRow('Consumo por Ave', '${batch.consumoActualPorAveGramos.toStringAsFixed(1)} g/día'),
            _buildInfoRow('Consumo del Lote', '${batch.consumoDiarioEstimadoKg.toStringAsFixed(2)} kg/día'),
            _buildInfoRow('Días de Reserva', consumoDiario > 0 
                ? '${(batch.stockAlimentoActualKg / consumoDiario).toStringAsFixed(1)} días'
                : 'Sin stock'),
            const Divider(),
            // Bultos necesarios por etapa
            _buildInfoRow('Bultos Necesarios (Etapa Actual)', '${batch.bultosNecesariosEtapaActual.toStringAsFixed(1)} bultos (40kg c/u)'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, BroilerBatch batch) {
    final mortalidad = batch.cantidadInicial - batch.cantidadActual;
    final porcentajeMortalidad = (mortalidad / batch.cantidadInicial) * 100;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estadísticas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Mortalidad', '$mortalidad pollos (${porcentajeMortalidad.toStringAsFixed(1)}%)'),
            _buildInfoRow('Supervivencia', '${((batch.cantidadActual / batch.cantidadInicial) * 100).toStringAsFixed(1)}%'),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, FarmProvider farmProvider, BroilerBatch batch) {
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
              await farmProvider.deleteBroilerBatch(batch.id, farmId: widget.farm.id);
              if (context.mounted) {
                Navigator.pop(context); // Cerrar diálogo
                Navigator.pop(context); // Volver a la lista
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
}

