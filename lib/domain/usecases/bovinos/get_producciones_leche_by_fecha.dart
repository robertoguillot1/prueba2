import '../../../core/utils/result.dart';
import '../../../core/errors/failures.dart';
import '../../entities/bovinos/produccion_leche.dart';
import '../../repositories/bovinos/produccion_leche_repository.dart';

/// Use case para obtener producciones de leche por rango de fechas
class GetProduccionesLecheByFecha {
  final ProduccionLecheRepository repository;

  GetProduccionesLecheByFecha(this.repository);

  Future<Result<List<ProduccionLeche>>> call(String farmId, DateTime fechaInicio, DateTime fechaFin) async {
    if (fechaFin.isBefore(fechaInicio)) {
      return const Error(ValidationFailure('La fecha fin debe ser posterior a la fecha inicio'));
    }
    return await repository.getProduccionesByFecha(farmId, fechaInicio, fechaFin);
  }
}

