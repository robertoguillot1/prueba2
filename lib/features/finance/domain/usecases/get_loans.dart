import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/loan_entity.dart';
import '../repositories/finance_repository.dart';
import 'usecase.dart';

/// Parámetros para obtener la lista de préstamos
class GetLoansParams {
  final String farmId;

  const GetLoansParams({required this.farmId});
}

/// Caso de uso para obtener la lista de préstamos de una finca
class GetLoans implements UseCase<Either<Failure, List<LoanEntity>>, GetLoansParams> {
  final FinanceRepository repository;

  GetLoans(this.repository);

  @override
  Future<Either<Failure, List<LoanEntity>>> call(GetLoansParams params) async {
    return await repository.getLoans(params.farmId);
  }
}






