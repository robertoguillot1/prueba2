import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/expense_entity.dart';
import '../repositories/finance_repository.dart';
import 'usecase.dart';

/// Parámetros para agregar un gasto
class AddExpenseParams {
  final ExpenseEntity expense;

  const AddExpenseParams({required this.expense});
}

/// Caso de uso para agregar un nuevo gasto
class AddExpense implements UseCase<Either<Failure, ExpenseEntity>, AddExpenseParams> {
  final FinanceRepository repository;

  AddExpense(this.repository);

  @override
  Future<Either<Failure, ExpenseEntity>> call(AddExpenseParams params) async {
    // Validaciones básicas
    if (params.expense.amount <= 0) {
      return Left(ValidationFailure('El monto debe ser mayor a cero'));
    }
    if (params.expense.description.trim().isEmpty) {
      return Left(ValidationFailure('La descripción es requerida'));
    }
    return await repository.addExpense(params.expense);
  }
}


