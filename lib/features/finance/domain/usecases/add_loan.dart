import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/loan_entity.dart';
import '../repositories/finance_repository.dart';
import 'usecase.dart';

/// Parámetros para agregar un préstamo
class AddLoanParams {
  final LoanEntity loan;

  const AddLoanParams({required this.loan});
}

/// Caso de uso para agregar un nuevo préstamo
class AddLoan implements UseCase<Either<Failure, LoanEntity>, AddLoanParams> {
  final FinanceRepository repository;

  AddLoan(this.repository);

  @override
  Future<Either<Failure, LoanEntity>> call(AddLoanParams params) async {
    // Validaciones básicas
    if (params.loan.amount <= 0) {
      return Left(ValidationFailure('El monto debe ser mayor a cero'));
    }
    if (params.loan.description.trim().isEmpty) {
      return Left(ValidationFailure('La descripción es requerida'));
    }
    if (params.loan.workerId.isEmpty) {
      return Left(ValidationFailure('El trabajador es requerido'));
    }
    return await repository.addLoan(params.loan);
  }
}








