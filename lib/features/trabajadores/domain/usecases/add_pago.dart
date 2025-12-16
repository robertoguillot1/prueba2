import '../../../../core/utils/result.dart';
import '../../../../domain/repositories/trabajadores/trabajadores_repository.dart';
import '../entities/pago.dart';

class AddPago {
  final TrabajadoresRepository repository;

  AddPago(this.repository);

  Future<Result<Pago>> call(Pago pago) async {
    return await repository.createPago(pago);
  }
}
