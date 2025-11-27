import '../../../../core/utils/result.dart';
import '../entities/vacuna_bovino_entity.dart';
import '../repositories/vacuna_bovino_repository.dart';

/// UseCase para obtener todas las vacunas de un bovino
class GetVacunasByBovino {
  final VacunaBovinoRepository repository;

  GetVacunasByBovino(this.repository);

  Future<Result<List<VacunaBovinoEntity>>> call(
    String bovinoId,
    String farmId,
  ) async {
    return await repository.getVacunasByBovino(bovinoId, farmId);
  }
}



