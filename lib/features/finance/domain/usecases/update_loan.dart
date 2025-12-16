import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/loan_entity.dart';
import '../repositories/finance_repository.dart';
import 'usecase.dart';

/// Parámetros para actualizar un préstamo
class UpdateLoanParams {
  final LoanEntity loan;

  const UpdateLoanParams({required this.loan});
}

/// Caso de uso para actualizar un préstamo existente
class UpdateLoan implements UseCase<Either<Failure, LoanEntity>, UpdateLoanParams> {
  final FinanceRepository repository;

  UpdateLoan(this.repository);

  @override
  Future<Either<Failure, LoanEntity>> call(UpdateLoanParams params) async {
    // Validaciones básicas
    if (params.loan.amount <= 0) {
      return Left(ValidationFailure('El monto debe ser mayor a cero'));
    }
    if (params.loan.description.trim().isEmpty) {
      return Left(ValidationFailure('La descripción es requerida'));
    }
    return await repository.updateLoan(params.loan);
  }
}


