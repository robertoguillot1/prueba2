import '../../../core/utils/result.dart';
import '../../entities/bovinos/produccion_leche.dart';
import '../../repositories/bovinos/produccion_leche_repository.dart';

/// Use case para obtener producciones de leche de un bovino
class GetProduccionesLecheByBovino {
  final ProduccionLecheRepository repository;

  GetProduccionesLecheByBovino(this.repository);

  Future<Result<List<ProduccionLeche>>> call(String bovinoId, String farmId) async {
    return await repository.getProduccionesByBovino(bovinoId, farmId);
  }
}



