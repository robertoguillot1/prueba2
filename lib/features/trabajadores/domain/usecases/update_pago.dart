import '../../../../core/utils/result.dart';
import '../../../../domain/repositories/trabajadores/trabajadores_repository.dart';
import '../entities/pago.dart';

class UpdatePago {
  final TrabajadoresRepository repository;

  UpdatePago(this.repository);

  Future<Result<Pago>> call(Pago pago) async {
    return await repository.updatePago(pago);
  }
}








