import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import '../../../../../features/cattle/domain/entities/bovine_entity.dart';
import '../../../../../features/cattle/domain/usecases/get_cattle_list.dart';
import 'bovine_list_state.dart';

/// Cubit para gestionar la lista de bovinos
class BovineListCubit extends Cubit<BovineListState> {
  final GetCattleList getCattleList;

  BovineListCubit({
    required this.getCattleList,
  }) : super(const BovineListInitial());

  /// Carga la lista de bovinos de una finca
  Future<void> loadBovines(String farmId) async {
    emit(const BovineListLoading());

    try {
      final result = await getCattleList(GetCattleListParams(farmId: farmId));

      // Usar .fold() para manejar Either<Failure, Data>
      result.fold(
        (failure) => emit(BovineListError(failure.message)),  // Left = Error
        (data) => emit(BovineListLoaded(bovines: data)),      // Right = Success
      );
    } catch (e) {
      emit(BovineListError('Error inesperado al cargar bovinos: $e'));
    }
  }

  /// Refresca la lista
  Future<void> refresh(String farmId) async {
    await loadBovines(farmId);
  }

  /// Aplica un filtro de búsqueda
  void search(String query) {
    final currentState = state;
    if (currentState is BovineListLoaded) {
      emit(currentState.copyWith(searchQuery: query));
    }
  }

  /// Limpia el filtro de búsqueda
  void clearSearch() {
    final currentState = state;
    if (currentState is BovineListLoaded) {
      emit(currentState.copyWith(searchQuery: ''));
    }
  }
}

