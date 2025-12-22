import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/payment_entity.dart';
import '../repositories/finance_repository.dart';
import 'usecase.dart';

/// Parámetros para agregar un pago
class AddPaymentParams {
  final PaymentEntity payment;

  const AddPaymentParams({required this.payment});
}

/// Caso de uso para agregar un nuevo pago
class AddPayment implements UseCase<Either<Failure, PaymentEntity>, AddPaymentParams> {
  final FinanceRepository repository;

  AddPayment(this.repository);

  @override
  Future<Either<Failure, PaymentEntity>> call(AddPaymentParams params) async {
    // Validaciones básicas
    if (params.payment.amount <= 0) {
      return Left(ValidationFailure('El monto debe ser mayor a cero'));
    }
    if (params.payment.workerId.isEmpty) {
      return Left(ValidationFailure('El trabajador es requerido'));
    }
    return await repository.addPayment(params.payment);
  }
}






