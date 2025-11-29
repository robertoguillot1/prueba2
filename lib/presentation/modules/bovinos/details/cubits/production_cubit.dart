import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import '../../../../../features/cattle/domain/entities/milk_production_entity.dart';
import '../../../../../features/cattle/domain/entities/weight_record_entity.dart';
import '../../../../../features/cattle/domain/usecases/get_milk_productions_by_bovine.dart';
import '../../../../../features/cattle/domain/usecases/get_weight_records_by_bovine.dart';
import '../../../../../core/errors/failures.dart';

// ============================================
// ESTADOS
// ============================================

/// Estados de producción
abstract class ProductionState extends Equatable {
  const ProductionState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class ProductionInitial extends ProductionState {}

/// Estado de carga
class ProductionLoading extends ProductionState {}

/// Estado con datos cargados
class ProductionLoaded extends ProductionState {
  final List<MilkProductionEntity> leche;
  final List<WeightRecordEntity> pesos;

  const ProductionLoaded({
    required this.leche,
    required this.pesos,
  });

  @override
  List<Object?> get props => [leche, pesos];
}

/// Estado de error
class ProductionError extends ProductionState {
  final String message;

  const ProductionError(this.message);

  @override
  List<Object?> get props => [message];
}

// ============================================
// CUBIT
// ============================================

/// Cubit para gestionar datos de producción del bovino
class ProductionCubit extends Cubit<ProductionState> {
  final GetMilkProductionsByBovine _getProduccionesLeche;
  final GetWeightRecordsByBovine _getPesos;

  ProductionCubit({
    required GetMilkProductionsByBovine getProduccionesLeche,
    required GetWeightRecordsByBovine getPesos,
  })  : _getProduccionesLeche = getProduccionesLeche,
        _getPesos = getPesos,
        super(ProductionInitial());

  /// Carga los datos de producción (leche y peso)
  Future<void> loadProduction({
    required String bovineId,
    required String farmId,
  }) async {
    emit(ProductionLoading());

    // Cargar ambos tipos de datos en paralelo
    final results = await Future.wait([
      _getProduccionesLeche(
        GetMilkProductionsByBovineParams(
          bovineId: bovineId,
          farmId: farmId,
        ),
      ),
      _getPesos(
        GetWeightRecordsByBovineParams(
          bovineId: bovineId,
          farmId: farmId,
        ),
      ),
    ]);

    final lecheResult = results[0] as Either<Failure, List<MilkProductionEntity>>;
    final pesosResult = results[1] as Either<Failure, List<WeightRecordEntity>>;

    // Manejar resultados
    List<MilkProductionEntity> lecheList = [];
    List<WeightRecordEntity> pesosList = [];

    lecheResult.fold(
      (failure) {
        // Si falla leche, continuamos con lista vacía
      },
      (data) {
        lecheList = data;
      },
    );

    pesosResult.fold(
      (failure) {
        // Si falla pesos, continuamos con lista vacía
      },
      (data) {
        pesosList = data;
      },
    );

    // Ordenar por fecha descendente
    lecheList.sort((a, b) => b.recordDate.compareTo(a.recordDate));
    pesosList.sort((a, b) => b.recordDate.compareTo(a.recordDate));

    emit(ProductionLoaded(leche: lecheList, pesos: pesosList));
  }

  /// Recarga los datos
  Future<void> refresh({required String bovineId, required String farmId}) async {
    await loadProduction(bovineId: bovineId, farmId: farmId);
  }
}
