import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/payment_entity.dart';
import '../repositories/finance_repository.dart';
import 'usecase.dart';

/// Parámetros para actualizar un pago
class UpdatePaymentParams {
  final PaymentEntity payment;

  const UpdatePaymentParams({required this.payment});
}

/// Caso de uso para actualizar un pago existente
class UpdatePayment implements UseCase<Either<Failure, PaymentEntity>, UpdatePaymentParams> {
  final FinanceRepository repository;

  UpdatePayment(this.repository);

  @override
  Future<Either<Failure, PaymentEntity>> call(UpdatePaymentParams params) async {
    // Validaciones básicas
    if (params.payment.amount <= 0) {
      return Left(ValidationFailure('El monto debe ser mayor a cero'));
    }
    return await repository.updatePayment(params.payment);
  }
}






