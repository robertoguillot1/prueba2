import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../../domain/entities/bovinos/produccion_leche.dart';
import '../../../../../domain/entities/bovinos/peso_bovino.dart';
import '../../../../../domain/usecases/bovinos/get_producciones_leche_by_bovino.dart';
import '../../../../../domain/usecases/bovinos/get_pesos_by_bovino.dart';
import '../../../../../core/utils/result.dart';

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
  final List<ProduccionLeche> leche;
  final List<PesoBovino> pesos;

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
  final GetProduccionesLecheByBovino _getProduccionesLeche;
  final GetPesosByBovino _getPesos;

  ProductionCubit({
    required GetProduccionesLecheByBovino getProduccionesLeche,
    required GetPesosByBovino getPesos,
  })  : _getProduccionesLeche = getProduccionesLeche,
        _getPesos = getPesos,
        super(ProductionInitial());

  /// Carga los datos de producción (leche y peso)
  Future<void> loadProduction({
    required String bovineId,
    required String farmId,
  }) async {
    emit(ProductionLoading());

    try {
      // Cargar ambos tipos de datos en paralelo
      final results = await Future.wait([
        _getProduccionesLeche(bovineId, farmId),
        _getPesos(bovineId, farmId),
      ]);

      final lecheResult = results[0] as Result<List<ProduccionLeche>>;
      final pesosResult = results[1] as Result<List<PesoBovino>>;

      // Manejar resultados
      List<ProduccionLeche> lecheList = [];
      List<PesoBovino> pesosList = [];

      switch (lecheResult) {
        case Success(:final data):
          lecheList = data;
        case Error():
          // Si falla leche, continuamos con lista vacía
          break;
      }

      switch (pesosResult) {
        case Success(:final data):
          pesosList = data;
        case Error():
          // Si falla pesos, continuamos con lista vacía
          break;
      }

      // Ordenar por fecha descendente
      lecheList.sort((a, b) => b.recordDate.compareTo(a.recordDate));
      pesosList.sort((a, b) => b.recordDate.compareTo(a.recordDate));

      emit(ProductionLoaded(leche: lecheList, pesos: pesosList));
    } catch (e) {
      emit(ProductionError('Error al cargar datos de producción: $e'));
    }
  }

  /// Recarga los datos
  void refresh({required String bovineId, required String farmId}) {
    loadProduction(bovineId: bovineId, farmId: farmId);
  }
}



