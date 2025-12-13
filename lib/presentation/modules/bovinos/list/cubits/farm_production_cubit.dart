import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../features/cattle/domain/entities/milk_production_entity.dart';
import '../../../../../features/cattle/domain/entities/weight_record_entity.dart';
import '../../../../../features/cattle/domain/entities/bovine_entity.dart';
import '../../../../../features/cattle/domain/usecases/get_milk_productions_by_bovine.dart';
import '../../../../../features/cattle/domain/usecases/get_weight_records_by_bovine.dart';
import '../../../../../features/cattle/domain/usecases/get_cattle_list.dart';
import '../../../../../core/utils/result.dart';
import '../../details/cubits/production_cubit.dart';

/// Cubit para gestionar todas las producciones (leche y peso) de una finca
class FarmProductionCubit extends Cubit<ProductionState> {
  final GetMilkProductionsByBovine _getMilkProductions;
  final GetWeightRecordsByBovine _getWeightRecords;
  final GetCattleList _getCattleList;

  FarmProductionCubit({
    required GetMilkProductionsByBovine getMilkProductions,
    required GetWeightRecordsByBovine getWeightRecords,
    required GetCattleList getCattleList,
  })  : _getMilkProductions = getMilkProductions,
        _getWeightRecords = getWeightRecords,
        _getCattleList = getCattleList,
        super(ProductionInitial());

  /// Carga todas las producciones de leche y registros de peso de todos los bovinos de la finca
  Future<void> loadProduction({required String farmId}) async {
    emit(ProductionLoading());

    try {
      // 1. Obtener todos los bovinos de la finca
      final bovinesResult = await _getCattleList(GetCattleListParams(farmId: farmId));
      
      final bovines = bovinesResult.fold(
        (failure) => <BovineEntity>[],
        (bovines) => bovines,
      );

      if (bovines.isEmpty) {
        emit(const ProductionLoaded(leche: [], pesos: []));
        return;
      }

      // 2. Para cada bovino, obtener sus producciones de leche y registros de peso
      final allMilkProductions = <MilkProductionEntity>[];
      final allWeightRecords = <WeightRecordEntity>[];
      
      for (final bovine in bovines) {
        // Cargar producciones de leche
        final milkResult = await _getMilkProductions(
          GetMilkProductionsByBovineParams(
            bovineId: bovine.id,
            farmId: farmId,
          ),
        );
        milkResult.fold(
          (failure) {
            // Continuar aunque falle para un bovino
          },
          (productions) {
            allMilkProductions.addAll(productions);
          },
        );

        // Cargar registros de peso
        final weightResult = await _getWeightRecords(
          GetWeightRecordsByBovineParams(
            bovineId: bovine.id,
            farmId: farmId,
          ),
        );
        weightResult.fold(
          (failure) {
            // Continuar aunque falle para un bovino
          },
          (records) {
            allWeightRecords.addAll(records);
          },
        );
      }

      // 3. Ordenar por fecha descendente (más reciente primero)
      allMilkProductions.sort((a, b) => b.recordDate.compareTo(a.recordDate));
      allWeightRecords.sort((a, b) => b.recordDate.compareTo(a.recordDate));

      emit(ProductionLoaded(leche: allMilkProductions, pesos: allWeightRecords));
    } catch (e) {
      emit(ProductionError('Error al cargar producciones: $e'));
    }
  }

  /// Refresca la lista de producciones
  Future<void> refresh({required String farmId}) async {
    await loadProduction(farmId: farmId);
  }
}

