import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';
import '../models/expense.dart';
import 'expense_form_screen.dart';

class ExpensesListScreen extends StatelessWidget {
  final Farm farm;

  const ExpensesListScreen({super.key, required this.farm});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gastos - ${farm.name}'),
        centerTitle: true,
        backgroundColor: farm.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<FarmProvider>(
        builder: (context, farmProvider, _child) {
          // Get the updated farm from provider to ensure we see the latest expenses
          final updatedFarm = farmProvider.farms.firstWhere(
            (f) => f.id == farm.id,
            orElse: () => farm,
          );
          final expenses = updatedFarm.expenses.toList()
            ..sort((a, b) => b.expenseDate.compareTo(a.expenseDate));
          
          if (expenses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay gastos registrados',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Los gastos de la finca aparecerán aquí',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Summary card
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
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
                                'Total Gastos (Mes)',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                NumberFormat.currency(symbol: '\$', decimalDigits: 0)
                                    .format(updatedFarm.totalExpensesThisMonth),
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
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
                                'Total Gastos',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                '${expenses.length}',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: updatedFarm.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Expenses list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    
                    return Card(
                      elevation: 1,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: updatedFarm.primaryColor.withOpacity(0.1),
                          child: Icon(
                            Icons.receipt,
                            color: updatedFarm.primaryColor,
                          ),
                        ),
                        title: Text(
                          expense.description,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    expense.category,
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat('dd/MM/yyyy').format(expense.expenseDate),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            if (expense.notes != null && expense.notes!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                expense.notes!,
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              NumberFormat.currency(symbol: '\$', decimalDigits: 0)
                                  .format(expense.amount),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 18),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ExpenseFormScreen(
                                          farm: updatedFarm,
                                          expenseToEdit: expense,
                                        ),
                                      ),
                                    );
                                  },
                                  tooltip: 'Editar',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                                  onPressed: () => _confirmDelete(context, farmProvider, expense),
                                  tooltip: 'Eliminar',
                                ),
                              ],
                            ),
                          ],
                        ),
                        isThreeLine: expense.notes != null && expense.notes!.isNotEmpty,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExpenseFormScreen(farm: farm),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Registrar Gasto'),
        backgroundColor: farm.primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _confirmDelete(BuildContext context, FarmProvider farmProvider, Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Gasto'),
        content: Text(
          '¿Estás seguro de que quieres eliminar este gasto?\n\n'
          '${expense.description}\n'
          '${NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(expense.amount)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await farmProvider.deleteExpense(expense.id, farmId: farm.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Gasto eliminado')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}


