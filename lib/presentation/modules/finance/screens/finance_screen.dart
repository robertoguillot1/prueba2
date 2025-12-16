import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../cubits/finance_cubit.dart';
import '../../../../features/finance/domain/entities/expense_entity.dart';
import '../../../../features/finance/domain/entities/loan_entity.dart';
import '../../../../features/finance/domain/entities/payment_entity.dart';
import '../../../../features/finance/domain/usecases/get_expenses.dart';
import '../../../../features/finance/domain/usecases/get_loans.dart';
import '../../../../features/finance/domain/usecases/get_payments.dart';
import '../../../../core/di/dependency_injection.dart' show sl;

class FinanceScreen extends StatelessWidget {
  final String farmId;

  const FinanceScreen({
    super.key,
    required this.farmId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FinanceCubit(
        getExpenses: sl<GetExpenses>(),
        getLoans: sl<GetLoans>(),
        getPayments: sl<GetPayments>(),
      )..loadFinanceData(farmId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Finanzas'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<FinanceCubit>().loadFinanceData(farmId);
              },
            ),
          ],
        ),
        body: BlocBuilder<FinanceCubit, FinanceState>(
          builder: (context, state) {
            if (state is FinanceLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is FinanceError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<FinanceCubit>().loadFinanceData(farmId);
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (state is FinanceLoaded) {
              return _buildLoadedState(context, state);
            }

            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            _showAddMenu(context);
          },
          icon: const Icon(Icons.add),
          label: const Text('Agregar'),
        ),
      ),
    );
  }

  Widget _buildLoadedState(BuildContext context, FinanceLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resumen financiero
          _buildSummaryCards(context, state),
          const SizedBox(height: 24),

          // Tabs para gastos, préstamos y pagos
          DefaultTabController(
            length: 3,
            child: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: 'Gastos', icon: Icon(Icons.shopping_cart)),
                    Tab(text: 'Préstamos', icon: Icon(Icons.account_balance_wallet)),
                    Tab(text: 'Pagos', icon: Icon(Icons.payments)),
                  ],
                ),
                SizedBox(
                  height: 400,
                  child: TabBarView(
                    children: [
                      _buildExpensesList(context, state.expenses),
                      _buildLoansList(context, state.loans),
                      _buildPaymentsList(context, state.payments),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, FinanceLoaded state) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                context,
                'Total Gastos',
                currencyFormat.format(state.totalExpenses),
                Colors.red,
                Icons.shopping_cart,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                context,
                'Total Préstamos',
                currencyFormat.format(state.totalLoans),
                Colors.orange,
                Icons.account_balance_wallet,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                context,
                'Total Pagos',
                currencyFormat.format(state.totalPayments),
                Colors.green,
                Icons.payments,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                context,
                'Préstamos Pendientes',
                currencyFormat.format(state.pendingLoans),
                Colors.amber,
                Icons.pending,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpensesList(BuildContext context, List<ExpenseEntity> expenses) {
    if (expenses.isEmpty) {
      return const Center(
        child: Text('No hay gastos registrados'),
      );
    }

    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return _buildExpenseCard(context, expense);
      },
    );
  }

  Widget _buildExpenseCard(BuildContext context, ExpenseEntity expense) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.red.withOpacity(0.2),
          child: const Icon(Icons.shopping_cart, color: Colors.red),
        ),
        title: Text(expense.description),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(expense.category.displayName),
            Text(dateFormat.format(expense.date)),
          ],
        ),
        trailing: Text(
          currencyFormat.format(expense.amount),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
      ),
    );
  }

  Widget _buildLoansList(BuildContext context, List<LoanEntity> loans) {
    if (loans.isEmpty) {
      return const Center(
        child: Text('No hay préstamos registrados'),
      );
    }

    return ListView.builder(
      itemCount: loans.length,
      itemBuilder: (context, index) {
        final loan = loans[index];
        return _buildLoanCard(context, loan);
      },
    );
  }

  Widget _buildLoanCard(BuildContext context, LoanEntity loan) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: loan.status == LoanStatus.pending
              ? Colors.orange.withOpacity(0.2)
              : Colors.green.withOpacity(0.2),
          child: Icon(
            loan.status == LoanStatus.pending ? Icons.pending : Icons.check_circle,
            color: loan.status == LoanStatus.pending ? Colors.orange : Colors.green,
          ),
        ),
        title: Text(loan.description),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Estado: ${loan.status.displayName}'),
            Text(dateFormat.format(loan.date)),
          ],
        ),
        trailing: Text(
          currencyFormat.format(loan.amount),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: loan.status == LoanStatus.pending ? Colors.orange : Colors.green,
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentsList(BuildContext context, List<PaymentEntity> payments) {
    if (payments.isEmpty) {
      return const Center(
        child: Text('No hay pagos registrados'),
      );
    }

    return ListView.builder(
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final payment = payments[index];
        return _buildPaymentCard(context, payment);
      },
    );
  }

  Widget _buildPaymentCard(BuildContext context, PaymentEntity payment) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.withOpacity(0.2),
          child: const Icon(Icons.payments, color: Colors.green),
        ),
        title: Text('Pago ${payment.type.displayName}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trabajador: ${payment.workerId}'),
            Text(dateFormat.format(payment.date)),
          ],
        ),
        trailing: Text(
          currencyFormat.format(payment.amount),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ),
    );
  }

  void _showAddMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Agregar Gasto'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navegar a formulario de gasto
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text('Agregar Préstamo'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navegar a formulario de préstamo
              },
            ),
            ListTile(
              leading: const Icon(Icons.payments),
              title: const Text('Agregar Pago'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navegar a formulario de pago
              },
            ),
          ],
        ),
      ),
    );
  }
}
