import '../../../../core/utils/result.dart';
import '../../../../domain/repositories/trabajadores/trabajadores_repository.dart';

class DeletePago {
  final TrabajadoresRepository repository;

  DeletePago(this.repository);

  Future<Result<void>> call(String workerId, String pagoId) async {
    return await repository.deletePago(workerId, pagoId);
  }
}








