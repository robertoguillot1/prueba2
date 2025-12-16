import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/entities/loan_entity.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/finance_repository.dart';
import '../datasources/finance_remote_datasource.dart';
import '../models/expense_model.dart';
import '../models/loan_model.dart';
import '../models/payment_model.dart';

/// Implementación del repositorio de Finanzas
class FinanceRepositoryImpl implements FinanceRepository {
  final FinanceRemoteDataSource remoteDataSource;

  FinanceRepositoryImpl({required this.remoteDataSource});

  // ========== EXPENSES ==========
  @override
  Future<Either<Failure, List<ExpenseEntity>>> getExpenses(String farmId) async {
    try {
      final expenses = await remoteDataSource.getExpenses(farmId);
      return Right(expenses);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Stream<List<ExpenseEntity>> getExpensesStream(String farmId) {
    try {
      return remoteDataSource.getExpensesStream(farmId);
    } catch (e) {
      return Stream.value([]);
    }
  }

  @override
  Future<Either<Failure, ExpenseEntity>> getExpense(String id) async {
    try {
      // Necesitamos farmId, pero no lo tenemos. Por ahora, lanzamos error.
      // En producción, deberíamos buscar en todas las fincas o pasar farmId como parámetro.
      return Left(ServerFailure('getExpense requiere farmId'));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, ExpenseEntity>> addExpense(ExpenseEntity expense) async {
    try {
      final expenseModel = ExpenseModel.fromEntity(expense);
      final added = await remoteDataSource.addExpense(expenseModel);
      return Right(added);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, ExpenseEntity>> updateExpense(ExpenseEntity expense) async {
    try {
      final expenseModel = ExpenseModel.fromEntity(expense);
      final updated = await remoteDataSource.updateExpense(expenseModel);
      return Right(updated);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteExpense(String id) async {
    try {
      // Necesitamos farmId, pero no lo tenemos. Por ahora, lanzamos error.
      return Left(ServerFailure('deleteExpense requiere farmId'));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  // ========== LOANS ==========
  @override
  Future<Either<Failure, List<LoanEntity>>> getLoans(String farmId) async {
    try {
      final loans = await remoteDataSource.getLoans(farmId);
      return Right(loans);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Stream<List<LoanEntity>> getLoansStream(String farmId) {
    try {
      return remoteDataSource.getLoansStream(farmId);
    } catch (e) {
      return Stream.value([]);
    }
  }

  @override
  Future<Either<Failure, LoanEntity>> getLoan(String id) async {
    try {
      return Left(ServerFailure('getLoan requiere farmId'));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, LoanEntity>> addLoan(LoanEntity loan) async {
    try {
      final loanModel = LoanModel.fromEntity(loan);
      final added = await remoteDataSource.addLoan(loanModel);
      return Right(added);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, LoanEntity>> updateLoan(LoanEntity loan) async {
    try {
      final loanModel = LoanModel.fromEntity(loan);
      final updated = await remoteDataSource.updateLoan(loanModel);
      return Right(updated);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteLoan(String id) async {
    try {
      return Left(ServerFailure('deleteLoan requiere farmId'));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  // ========== PAYMENTS ==========
  @override
  Future<Either<Failure, List<PaymentEntity>>> getPayments(String farmId) async {
    try {
      final payments = await remoteDataSource.getPayments(farmId);
      return Right(payments);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Stream<List<PaymentEntity>> getPaymentsStream(String farmId) {
    try {
      return remoteDataSource.getPaymentsStream(farmId);
    } catch (e) {
      return Stream.value([]);
    }
  }

  @override
  Future<Either<Failure, PaymentEntity>> getPayment(String id) async {
    try {
      return Left(ServerFailure('getPayment requiere farmId'));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, PaymentEntity>> addPayment(PaymentEntity payment) async {
    try {
      final paymentModel = PaymentModel.fromEntity(payment);
      final added = await remoteDataSource.addPayment(paymentModel);
      return Right(added);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, PaymentEntity>> updatePayment(PaymentEntity payment) async {
    try {
      final paymentModel = PaymentModel.fromEntity(payment);
      final updated = await remoteDataSource.updatePayment(paymentModel);
      return Right(updated);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deletePayment(String id) async {
    try {
      return Left(ServerFailure('deletePayment requiere farmId'));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }
}


