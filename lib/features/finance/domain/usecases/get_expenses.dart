import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/expense_entity.dart';
import '../repositories/finance_repository.dart';
import 'usecase.dart';

/// Parámetros para obtener la lista de gastos
class GetExpensesParams {
  final String farmId;

  const GetExpensesParams({required this.farmId});
}

/// Caso de uso para obtener la lista de gastos de una finca
class GetExpenses implements UseCase<Either<Failure, List<ExpenseEntity>>, GetExpensesParams> {
  final FinanceRepository repository;

  GetExpenses(this.repository);

  @override
  Future<Either<Failure, List<ExpenseEntity>>> call(GetExpensesParams params) async {
    return await repository.getExpenses(params.farmId);
  }
}


