import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/expense_entity.dart';
import '../repositories/finance_repository.dart';
import 'usecase.dart';

/// Parámetros para actualizar un gasto
class UpdateExpenseParams {
  final ExpenseEntity expense;

  const UpdateExpenseParams({required this.expense});
}

/// Caso de uso para actualizar un gasto existente
class UpdateExpense implements UseCase<Either<Failure, ExpenseEntity>, UpdateExpenseParams> {
  final FinanceRepository repository;

  UpdateExpense(this.repository);

  @override
  Future<Either<Failure, ExpenseEntity>> call(UpdateExpenseParams params) async {
    // Validaciones básicas
    if (params.expense.amount <= 0) {
      return Left(ValidationFailure('El monto debe ser mayor a cero'));
    }
    if (params.expense.description.trim().isEmpty) {
      return Left(ValidationFailure('La descripción es requerida'));
    }
    return await repository.updateExpense(params.expense);
  }
}








