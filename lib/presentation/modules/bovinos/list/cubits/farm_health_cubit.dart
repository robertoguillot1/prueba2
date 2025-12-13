import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import '../../../../../features/cattle/domain/entities/vacuna_bovino_entity.dart';
import '../../../../../features/cattle/domain/entities/bovine_entity.dart';
import '../../../../../features/cattle/domain/usecases/get_vacunas_by_bovino.dart';
import '../../../../../features/cattle/domain/usecases/get_cattle_list.dart';
import '../../../../../core/utils/result.dart';
import '../../details/cubits/health_state.dart';

/// Cubit para gestionar todas las vacunas de una finca
class FarmHealthCubit extends Cubit<HealthState> {
  final GetVacunasByBovino _getVacunasByBovino;
  final GetCattleList _getCattleList;

  FarmHealthCubit({
    required GetVacunasByBovino getVacunasByBovino,
    required GetCattleList getCattleList,
  })  : _getVacunasByBovino = getVacunasByBovino,
        _getCattleList = getCattleList,
        super(const HealthInitial());

  /// Carga todas las vacunas de todos los bovinos de la finca
  Future<void> loadVacunas({required String farmId}) async {
    emit(const HealthLoading());

    try {
      // 1. Obtener todos los bovinos de la finca
      final bovinesResult = await _getCattleList(GetCattleListParams(farmId: farmId));
      
      final bovines = bovinesResult.fold(
        (failure) => <BovineEntity>[],
        (bovines) => bovines,
      );

      if (bovines.isEmpty) {
        emit(const HealthLoaded(vacunas: []));
        return;
      }

      // 2. Para cada bovino, obtener sus vacunas
      final allVacunas = <VacunaBovinoEntity>[];
      
      for (final bovine in bovines) {
        final vacunasResult = await _getVacunasByBovino(bovine.id, farmId);
        if (vacunasResult is Success<List<VacunaBovinoEntity>>) {
          allVacunas.addAll(vacunasResult.data);
        } else {
          // Continuar aunque falle para un bovino específico
        }
      }

      // 3. Ordenar por fecha de aplicación (más reciente primero)
      allVacunas.sort((a, b) => b.fechaAplicacion.compareTo(a.fechaAplicacion));

      emit(HealthLoaded(vacunas: allVacunas));
    } catch (e) {
      emit(HealthError('Error al cargar vacunas: $e'));
    }
  }

  /// Refresca la lista de vacunas
  Future<void> refresh({required String farmId}) async {
    await loadVacunas(farmId: farmId);
  }
}


