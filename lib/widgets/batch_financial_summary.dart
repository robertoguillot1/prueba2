import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/broiler_batch.dart';
import '../models/batch_expense.dart';
import '../models/batch_sale.dart';

class BatchFinancialSummary extends StatelessWidget {
  final BroilerBatch batch;
  final List<BatchExpense> expenses;
  final BatchSale? sale;
  final Color primaryColor;

  const BatchFinancialSummary({
    super.key,
    required this.batch,
    required this.expenses,
    this.sale,
    required this.primaryColor,
  });

  // Calcular inversión total
  double get _inversionTotal {
    final gastosTotal = expenses.fold<double>(0.0, (sum, e) => sum + e.monto);
    return batch.costoCompraLote + gastosTotal;
  }

  // Calcular ingreso bruto
  double get _ingresoBruto {
    return sale?.totalVenta ?? 0.0;
  }

  // Calcular rentabilidad neta
  double get _rentabilidadNeta {
    return _ingresoBruto - _inversionTotal;
  }

  // Calcular costo de producción por pollo
  double get _costoPorPollos {
    if (batch.cantidadInicial == 0) return 0.0;
    return _inversionTotal / batch.cantidadInicial;
  }

  @override
  Widget build(BuildContext context) {
    if (sale == null && expenses.isEmpty && batch.costoCompraLote == 0) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text(
              'No hay datos financieros registrados',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );
    }

    final esRentable = _rentabilidadNeta >= 0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance_wallet, color: primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Resumen Financiero',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Inversión Total
            _buildFinancialRow(
              'Inversión Total',
              _inversionTotal,
              Colors.blue,
              Icons.trending_down,
            ),
            const SizedBox(height: 8),
            _buildBreakdownRow('  • Costo compra lote', batch.costoCompraLote),
            if (expenses.isNotEmpty)
              _buildBreakdownRow('  • Gastos totales', expenses.fold<double>(0.0, (sum, e) => sum + e.monto)),
            const SizedBox(height: 12),
            // Ingreso Bruto
            if (sale != null) ...[
              _buildFinancialRow(
                'Ingreso Bruto',
                _ingresoBruto,
                Colors.green,
                Icons.trending_up,
              ),
              const SizedBox(height: 12),
            ],
            // Rentabilidad Neta
            if (sale != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: esRentable ? Colors.green[50] : Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: esRentable ? Colors.green : Colors.red,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          esRentable ? Icons.arrow_upward : Icons.arrow_downward,
                          color: esRentable ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Rentabilidad Neta (Ganancia)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(_rentabilidadNeta),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: esRentable ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            // Costo de producción por pollo
            _buildFinancialRow(
              'Costo de Producción por Pollo',
              _costoPorPollos,
              Colors.orange,
              Icons.pets,
            ),
            if (sale != null && sale!.cantidadPollosVendidos > 0) ...[
              const SizedBox(height: 8),
              _buildBreakdownRow(
                '  • Ingreso por pollo vendido',
                _ingresoBruto / sale!.cantidadPollosVendidos,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialRow(String label, double value, Color color, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Text(
          NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(value),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildBreakdownRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          Text(
            NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(value),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}

