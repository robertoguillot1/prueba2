import '../../../core/utils/result.dart';
import '../../entities/bovinos/peso_bovino.dart';
import '../../repositories/bovinos/peso_bovino_repository.dart';

/// Use case para obtener registros de peso de un bovino
class GetPesosByBovino {
  final PesoBovinoRepository repository;

  GetPesosByBovino(this.repository);

  Future<Result<List<PesoBovino>>> call(String bovinoId, String farmId) async {
    return await repository.getRegistrosByBovino(bovinoId, farmId);
  }
}

