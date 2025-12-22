import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/expense_entity.dart';
import '../entities/loan_entity.dart';
import '../entities/payment_entity.dart';

/// Contrato abstracto del repositorio para Finanzas
abstract class FinanceRepository {
  // ========== EXPENSES ==========
  /// Obtiene la lista de gastos de una finca
  Future<Either<Failure, List<ExpenseEntity>>> getExpenses(String farmId);
  
  /// Obtiene un stream de gastos para actualizaciones en tiempo real
  Stream<List<ExpenseEntity>> getExpensesStream(String farmId);
  
  /// Obtiene un gasto por su ID
  Future<Either<Failure, ExpenseEntity>> getExpense(String id);
  
  /// Agrega un nuevo gasto
  Future<Either<Failure, ExpenseEntity>> addExpense(ExpenseEntity expense);
  
  /// Actualiza un gasto existente
  Future<Either<Failure, ExpenseEntity>> updateExpense(ExpenseEntity expense);
  
  /// Elimina un gasto por su ID
  Future<Either<Failure, void>> deleteExpense(String id);

  // ========== LOANS ==========
  /// Obtiene la lista de préstamos de una finca
  Future<Either<Failure, List<LoanEntity>>> getLoans(String farmId);
  
  /// Obtiene un stream de préstamos para actualizaciones en tiempo real
  Stream<List<LoanEntity>> getLoansStream(String farmId);
  
  /// Obtiene un préstamo por su ID
  Future<Either<Failure, LoanEntity>> getLoan(String id);
  
  /// Agrega un nuevo préstamo
  Future<Either<Failure, LoanEntity>> addLoan(LoanEntity loan);
  
  /// Actualiza un préstamo existente
  Future<Either<Failure, LoanEntity>> updateLoan(LoanEntity loan);
  
  /// Elimina un préstamo por su ID
  Future<Either<Failure, void>> deleteLoan(String id);

  // ========== PAYMENTS ==========
  /// Obtiene la lista de pagos de una finca
  Future<Either<Failure, List<PaymentEntity>>> getPayments(String farmId);
  
  /// Obtiene un stream de pagos para actualizaciones en tiempo real
  Stream<List<PaymentEntity>> getPaymentsStream(String farmId);
  
  /// Obtiene un pago por su ID
  Future<Either<Failure, PaymentEntity>> getPayment(String id);
  
  /// Agrega un nuevo pago
  Future<Either<Failure, PaymentEntity>> addPayment(PaymentEntity payment);
  
  /// Actualiza un pago existente
  Future<Either<Failure, PaymentEntity>> updatePayment(PaymentEntity payment);
  
  /// Elimina un pago por su ID
  Future<Either<Failure, void>> deletePayment(String id);
}






