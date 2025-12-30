import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense_model.dart';
import '../models/loan_model.dart';
import '../models/payment_model.dart';

/// Excepción para errores del servidor
class ServerException implements Exception {
  final String message;
  const ServerException(this.message);

  @override
  String toString() => message;
}

/// Contrato abstracto para el datasource remoto de Finanzas
abstract class FinanceRemoteDataSource {
  // ========== EXPENSES ==========
  Future<List<ExpenseModel>> getExpenses(String farmId);
  Stream<List<ExpenseModel>> getExpensesStream(String farmId);
  Future<ExpenseModel> getExpense(String farmId, String id);
  Future<ExpenseModel> addExpense(ExpenseModel expense);
  Future<ExpenseModel> updateExpense(ExpenseModel expense);
  Future<void> deleteExpense(String farmId, String id);

  // ========== LOANS ==========
  Future<List<LoanModel>> getLoans(String farmId);
  Stream<List<LoanModel>> getLoansStream(String farmId);
  Future<LoanModel> getLoan(String farmId, String id);
  Future<LoanModel> addLoan(LoanModel loan);
  Future<LoanModel> updateLoan(LoanModel loan);
  Future<void> deleteLoan(String farmId, String id);

  // ========== PAYMENTS ==========
  Future<List<PaymentModel>> getPayments(String farmId);
  Stream<List<PaymentModel>> getPaymentsStream(String farmId);
  Future<PaymentModel> getPayment(String farmId, String id);
  Future<PaymentModel> addPayment(PaymentModel payment);
  Future<PaymentModel> updatePayment(PaymentModel payment);
  Future<void> deletePayment(String farmId, String id);
}

/// Implementación del datasource remoto usando Firebase Firestore
class FinanceRemoteDataSourceImpl implements FinanceRemoteDataSource {
  final FirebaseFirestore firestore;

  FinanceRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  // ========== EXPENSES ==========
  @override
  Future<List<ExpenseModel>> getExpenses(String farmId) async {
    try {
      final snapshot = await firestore
          .collection('farms')
          .doc(farmId)
          .collection('expenses')
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ExpenseModel.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      throw ServerException('Error al obtener la lista de gastos: $e');
    }
  }

  @override
  Stream<List<ExpenseModel>> getExpensesStream(String farmId) {
    try {
      return firestore
          .collection('farms')
          .doc(farmId)
          .collection('expenses')
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => ExpenseModel.fromJson({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList();
      });
    } catch (e) {
      throw ServerException('Error al obtener el stream de gastos: $e');
    }
  }

  @override
  Future<ExpenseModel> getExpense(String farmId, String id) async {
    try {
      final doc = await firestore
          .collection('farms')
          .doc(farmId)
          .collection('expenses')
          .doc(id)
          .get();

      if (!doc.exists) {
        throw ServerException('Gasto no encontrado con ID: $id');
      }

      return ExpenseModel.fromJson({
        ...doc.data()!,
        'id': doc.id,
      });
    } catch (e) {
      throw ServerException('Error al obtener el gasto: $e');
    }
  }

  @override
  Future<ExpenseModel> addExpense(ExpenseModel expense) async {
    try {
      final now = DateTime.now();
      final expenseWithDates = expense.copyWith(
        createdAt: now,
        updatedAt: now,
      );

      final docRef = await firestore
          .collection('farms')
          .doc(expense.farmId)
          .collection('expenses')
          .add(expenseWithDates.toJson());

      return expenseWithDates.copyWith(id: docRef.id);
    } catch (e) {
      throw ServerException('Error al agregar el gasto: $e');
    }
  }

  @override
  Future<ExpenseModel> updateExpense(ExpenseModel expense) async {
    try {
      final updatedExpense = expense.copyWith(updatedAt: DateTime.now());

      await firestore
          .collection('farms')
          .doc(expense.farmId)
          .collection('expenses')
          .doc(expense.id)
          .update(updatedExpense.toJson());

      return updatedExpense;
    } catch (e) {
      throw ServerException('Error al actualizar el gasto: $e');
    }
  }

  @override
  Future<void> deleteExpense(String farmId, String id) async {
    try {
      await firestore
          .collection('farms')
          .doc(farmId)
          .collection('expenses')
          .doc(id)
          .delete();
    } catch (e) {
      throw ServerException('Error al eliminar el gasto: $e');
    }
  }

  // ========== LOANS ==========
  @override
  Future<List<LoanModel>> getLoans(String farmId) async {
    try {
      final snapshot = await firestore
          .collection('farms')
          .doc(farmId)
          .collection('loans')
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => LoanModel.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      throw ServerException('Error al obtener la lista de préstamos: $e');
    }
  }

  @override
  Stream<List<LoanModel>> getLoansStream(String farmId) {
    try {
      return firestore
          .collection('farms')
          .doc(farmId)
          .collection('loans')
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => LoanModel.fromJson({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList();
      });
    } catch (e) {
      throw ServerException('Error al obtener el stream de préstamos: $e');
    }
  }

  @override
  Future<LoanModel> getLoan(String farmId, String id) async {
    try {
      final doc = await firestore
          .collection('farms')
          .doc(farmId)
          .collection('loans')
          .doc(id)
          .get();

      if (!doc.exists) {
        throw ServerException('Préstamo no encontrado con ID: $id');
      }

      return LoanModel.fromJson({
        ...doc.data()!,
        'id': doc.id,
      });
    } catch (e) {
      throw ServerException('Error al obtener el préstamo: $e');
    }
  }

  @override
  Future<LoanModel> addLoan(LoanModel loan) async {
    try {
      final now = DateTime.now();
      final loanWithDates = loan.copyWith(
        createdAt: now,
        updatedAt: now,
      );

      final docRef = await firestore
          .collection('farms')
          .doc(loan.farmId)
          .collection('loans')
          .add(loanWithDates.toJson());

      return loanWithDates.copyWith(id: docRef.id);
    } catch (e) {
      throw ServerException('Error al agregar el préstamo: $e');
    }
  }

  @override
  Future<LoanModel> updateLoan(LoanModel loan) async {
    try {
      final updatedLoan = loan.copyWith(updatedAt: DateTime.now());

      await firestore
          .collection('farms')
          .doc(loan.farmId)
          .collection('loans')
          .doc(loan.id)
          .update(updatedLoan.toJson());

      return updatedLoan;
    } catch (e) {
      throw ServerException('Error al actualizar el préstamo: $e');
    }
  }

  @override
  Future<void> deleteLoan(String farmId, String id) async {
    try {
      await firestore
          .collection('farms')
          .doc(farmId)
          .collection('loans')
          .doc(id)
          .delete();
    } catch (e) {
      throw ServerException('Error al eliminar el préstamo: $e');
    }
  }

  // ========== PAYMENTS ==========
  @override
  Future<List<PaymentModel>> getPayments(String farmId) async {
    try {
      final snapshot = await firestore
          .collection('farms')
          .doc(farmId)
          .collection('payments')
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => PaymentModel.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      throw ServerException('Error al obtener la lista de pagos: $e');
    }
  }

  @override
  Stream<List<PaymentModel>> getPaymentsStream(String farmId) {
    try {
      return firestore
          .collection('farms')
          .doc(farmId)
          .collection('payments')
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => PaymentModel.fromJson({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList();
      });
    } catch (e) {
      throw ServerException('Error al obtener el stream de pagos: $e');
    }
  }

  @override
  Future<PaymentModel> getPayment(String farmId, String id) async {
    try {
      final doc = await firestore
          .collection('farms')
          .doc(farmId)
          .collection('payments')
          .doc(id)
          .get();

      if (!doc.exists) {
        throw ServerException('Pago no encontrado con ID: $id');
      }

      return PaymentModel.fromJson({
        ...doc.data()!,
        'id': doc.id,
      });
    } catch (e) {
      throw ServerException('Error al obtener el pago: $e');
    }
  }

  @override
  Future<PaymentModel> addPayment(PaymentModel payment) async {
    try {
      final now = DateTime.now();
      final paymentWithDates = payment.copyWith(
        createdAt: now,
        updatedAt: now,
      );

      final docRef = await firestore
          .collection('farms')
          .doc(payment.farmId)
          .collection('payments')
          .add(paymentWithDates.toJson());

      return paymentWithDates.copyWith(id: docRef.id);
    } catch (e) {
      throw ServerException('Error al agregar el pago: $e');
    }
  }

  @override
  Future<PaymentModel> updatePayment(PaymentModel payment) async {
    try {
      final updatedPayment = payment.copyWith(updatedAt: DateTime.now());

      await firestore
          .collection('farms')
          .doc(payment.farmId)
          .collection('payments')
          .doc(payment.id)
          .update(updatedPayment.toJson());

      return updatedPayment;
    } catch (e) {
      throw ServerException('Error al actualizar el pago: $e');
    }
  }

  @override
  Future<void> deletePayment(String farmId, String id) async {
    try {
      await firestore
          .collection('farms')
          .doc(farmId)
          .collection('payments')
          .doc(id)
          .delete();
    } catch (e) {
      throw ServerException('Error al eliminar el pago: $e');
    }
  }
}








