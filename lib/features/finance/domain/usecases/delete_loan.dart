import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/finance_repository.dart';
import 'usecase.dart';

/// Parámetros para eliminar un préstamo
class DeleteLoanParams {
  final String id;

  const DeleteLoanParams({required this.id});
}

/// Caso de uso para eliminar un préstamo
class DeleteLoan implements UseCase<Either<Failure, void>, DeleteLoanParams> {
  final FinanceRepository repository;

  DeleteLoan(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteLoanParams params) async {
    return await repository.deleteLoan(params.id);
  }
}






