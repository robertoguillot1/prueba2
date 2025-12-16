import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/finance_repository.dart';
import 'usecase.dart';

/// Parámetros para eliminar un gasto
class DeleteExpenseParams {
  final String id;

  const DeleteExpenseParams({required this.id});
}

/// Caso de uso para eliminar un gasto
class DeleteExpense implements UseCase<Either<Failure, void>, DeleteExpenseParams> {
  final FinanceRepository repository;

  DeleteExpense(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteExpenseParams params) async {
    return await repository.deleteExpense(params.id);
  }
}


