import '../../../../core/utils/result.dart';
import '../../../../domain/repositories/trabajadores/trabajadores_repository.dart';
import '../entities/pago.dart';

class GetPagos {
  final TrabajadoresRepository repository;

  GetPagos(this.repository);

  Future<Result<List<Pago>>> call(String workerId) async {
    return await repository.getPagosByTrabajador(workerId);
  }
}
