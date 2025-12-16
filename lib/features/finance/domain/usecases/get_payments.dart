import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/payment_entity.dart';
import '../repositories/finance_repository.dart';
import 'usecase.dart';

/// Parámetros para obtener la lista de pagos
class GetPaymentsParams {
  final String farmId;

  const GetPaymentsParams({required this.farmId});
}

/// Caso de uso para obtener la lista de pagos de una finca
class GetPayments implements UseCase<Either<Failure, List<PaymentEntity>>, GetPaymentsParams> {
  final FinanceRepository repository;

  GetPayments(this.repository);

  @override
  Future<Either<Failure, List<PaymentEntity>>> call(GetPaymentsParams params) async {
    return await repository.getPayments(params.farmId);
  }
}


