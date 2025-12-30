import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../features/finance/domain/entities/expense_entity.dart';
import '../../../../features/finance/domain/entities/loan_entity.dart';
import '../../../../features/finance/domain/entities/payment_entity.dart';
import '../../../../features/finance/domain/usecases/get_expenses.dart';
import '../../../../features/finance/domain/usecases/get_loans.dart';
import '../../../../features/finance/domain/usecases/get_payments.dart';

// ========== STATES ==========
abstract class FinanceState extends Equatable {
  const FinanceState();

  @override
  List<Object?> get props => [];
}

class FinanceInitial extends FinanceState {}

class FinanceLoading extends FinanceState {}

class FinanceLoaded extends FinanceState {
  final List<ExpenseEntity> expenses;
  final List<LoanEntity> loans;
  final List<PaymentEntity> payments;
  final double totalExpenses;
  final double totalLoans;
  final double totalPayments;
  final double pendingLoans;

  const FinanceLoaded({
    required this.expenses,
    required this.loans,
    required this.payments,
    required this.totalExpenses,
    required this.totalLoans,
    required this.totalPayments,
    required this.pendingLoans,
  });

  @override
  List<Object?> get props => [
        expenses,
        loans,
        payments,
        totalExpenses,
        totalLoans,
        totalPayments,
        pendingLoans,
      ];
}

class FinanceError extends FinanceState {
  final String message;

  const FinanceError(this.message);

  @override
  List<Object?> get props => [message];
}

// ========== CUBIT ==========
class FinanceCubit extends Cubit<FinanceState> {
  final GetExpenses getExpenses;
  final GetLoans getLoans;
  final GetPayments getPayments;

  FinanceCubit({
    required this.getExpenses,
    required this.getLoans,
    required this.getPayments,
  }) : super(FinanceInitial());

  Future<void> loadFinanceData(String farmId) async {
    emit(FinanceLoading());
    try {
      final expensesResult = await getExpenses(GetExpensesParams(farmId: farmId));
      final loansResult = await getLoans(GetLoansParams(farmId: farmId));
      final paymentsResult = await getPayments(GetPaymentsParams(farmId: farmId));

      expensesResult.fold(
        (failure) => emit(FinanceError('Error al cargar gastos: ${failure.message}')),
        (expenses) {
          loansResult.fold(
            (failure) => emit(FinanceError('Error al cargar préstamos: ${failure.message}')),
            (loans) {
              paymentsResult.fold(
                (failure) => emit(FinanceError('Error al cargar pagos: ${failure.message}')),
                (payments) {
                  // Calcular totales
                  final totalExpenses = expenses.fold<double>(
                    0,
                    (sum, expense) => sum + expense.amount,
                  );
                  final totalLoans = loans.fold<double>(
                    0,
                    (sum, loan) => sum + loan.amount,
                  );
                  final totalPayments = payments.fold<double>(
                    0,
                    (sum, payment) => sum + payment.amount,
                  );
                  final pendingLoans = loans
                      .where((loan) => loan.status == LoanStatus.pending)
                      .fold<double>(
                        0,
                        (sum, loan) => sum + loan.amount,
                      );

                  emit(FinanceLoaded(
                    expenses: expenses,
                    loans: loans,
                    payments: payments,
                    totalExpenses: totalExpenses,
                    totalLoans: totalLoans,
                    totalPayments: totalPayments,
                    pendingLoans: pendingLoans,
                  ));
                },
              );
            },
          );
        },
      );
    } catch (e) {
      emit(FinanceError('Error inesperado: $e'));
    }
  }
}








