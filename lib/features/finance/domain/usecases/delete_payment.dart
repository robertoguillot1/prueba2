import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/finance_repository.dart';
import 'usecase.dart';

/// Parámetros para eliminar un pago
class DeletePaymentParams {
  final String id;

  const DeletePaymentParams({required this.id});
}

/// Caso de uso para eliminar un pago
class DeletePayment implements UseCase<Either<Failure, void>, DeletePaymentParams> {
  final FinanceRepository repository;

  DeletePayment(this.repository);

  @override
  Future<Either<Failure, void>> call(DeletePaymentParams params) async {
    return await repository.deletePayment(params.id);
  }
}








