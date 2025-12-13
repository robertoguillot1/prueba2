import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/bovine_entity.dart';
import '../../domain/usecases/get_cattle_list.dart';
import '../../domain/usecases/get_bovine.dart';
import '../../domain/usecases/add_bovine.dart';
import '../../domain/usecases/update_bovine.dart';
import '../../domain/usecases/delete_bovine.dart';
import '../../domain/repositories/cattle_repository.dart';
import 'cattle_state.dart';

/// Cubit para manejar el estado de los bovinos
class CattleCubit extends Cubit<CattleState> {
  final GetCattleList getCattleListUseCase;
  final GetBovine getBovineUseCase;
  final AddBovine addBovineUseCase;
  final UpdateBovine updateBovineUseCase;
  final DeleteBovine deleteBovineUseCase;
  final CattleRepository repository;

  StreamSubscription<List<BovineEntity>>? _cattleSubscription;
  String? _currentFarmId;

  CattleCubit({
    required this.getCattleListUseCase,
    required this.getBovineUseCase,
    required this.addBovineUseCase,
    required this.updateBovineUseCase,
    required this.deleteBovineUseCase,
    required this.repository,
  }) : super(const CattleInitial());

  /// Carga los bovinos de una finca
  /// Se suscribe al stream para actualizaciones en tiempo real
  Future<void> loadCattle(String farmId) async {
    _currentFarmId = farmId;
    emit(const CattleLoading());

    try {
      // Cancelar suscripción anterior si existe
      await _cattleSubscription?.cancel();

      // Primero, obtener los datos iniciales usando el use case
      final result = await getCattleListUseCase(GetCattleListParams(farmId: farmId));

      result.fold(
        (failure) => emit(CattleError(failure.message)),
        (cattleList) {
          emit(CattleLoaded(cattleList));

          // Luego, suscribirse al stream para actualizaciones en tiempo real
          _cattleSubscription = repository.getCattleListStream(farmId).listen(
            (cattle) {
              if (!isClosed) {
                emit(CattleLoaded(cattle));
              }
            },
            onError: (error) {
              if (!isClosed) {
                emit(CattleError('Error al cargar bovinos: $error'));
              }
            },
            cancelOnError: false,
          );
        },
      );
    } catch (e) {
      emit(CattleError('Error inesperado al cargar bovinos: $e'));
    }
  }

  /// Recarga los bovinos de la finca actual
  Future<void> reloadCattle() async {
    if (_currentFarmId != null) {
      await loadCattle(_currentFarmId!);
    } else {
      emit(const CattleError('No hay una finca seleccionada'));
    }
  }

  /// Agrega un nuevo bovino
  Future<void> addBovine(BovineEntity bovine) async {
    // Guardar el estado actual
    final currentState = state;
    
    emit(const CattleLoading());

    try {
      final result = await addBovineUseCase(AddBovineParams(bovine: bovine));

      result.fold(
        (failure) {
          emit(CattleError(failure.message));
          // Restaurar el estado anterior después de un error
          if (currentState is CattleLoaded) {
            emit(currentState);
          }
        },
        (createdBovine) async {
          // Recargar la lista para obtener los datos actualizados
          if (_currentFarmId != null) {
            final listResult = await getCattleListUseCase(
              GetCattleListParams(farmId: _currentFarmId!),
            );

            listResult.fold(
              (failure) => emit(CattleError(failure.message)),
              (cattleList) => emit(CattleOperationSuccess(
                message: 'Bovino agregado exitosamente',
                cattle: cattleList,
              )),
            );
          }
        },
      );
    } catch (e) {
      emit(CattleError('Error inesperado al agregar bovino: $e'));
      // Restaurar el estado anterior
      if (currentState is CattleLoaded) {
        emit(currentState);
      }
    }
  }

  /// Actualiza un bovino existente
  Future<void> updateBovine(BovineEntity bovine) async {
    // Guardar el estado actual
    final currentState = state;
    
    emit(const CattleLoading());

    try {
      final result = await updateBovineUseCase(UpdateBovineParams(bovine: bovine));

      result.fold(
        (failure) {
          emit(CattleError(failure.message));
          // Restaurar el estado anterior después de un error
          if (currentState is CattleLoaded) {
            emit(currentState);
          }
        },
        (updatedBovine) async {
          // Recargar la lista para obtener los datos actualizados
          if (_currentFarmId != null) {
            final listResult = await getCattleListUseCase(
              GetCattleListParams(farmId: _currentFarmId!),
            );

            listResult.fold(
              (failure) => emit(CattleError(failure.message)),
              (cattleList) => emit(CattleOperationSuccess(
                message: 'Bovino actualizado exitosamente',
                cattle: cattleList,
              )),
            );
          }
        },
      );
    } catch (e) {
      emit(CattleError('Error inesperado al actualizar bovino: $e'));
      // Restaurar el estado anterior
      if (currentState is CattleLoaded) {
        emit(currentState);
      }
    }
  }

  /// Elimina un bovino
  Future<void> deleteBovine(String bovineId) async {
    // Guardar el estado actual
    final currentState = state;
    
    emit(const CattleLoading());

    try {
      final result = await deleteBovineUseCase(DeleteBovineParams(id: bovineId));

      result.fold(
        (failure) {
          emit(CattleError(failure.message));
          // Restaurar el estado anterior después de un error
          if (currentState is CattleLoaded) {
            emit(currentState);
          }
        },
        (_) async {
          // Recargar la lista para obtener los datos actualizados
          if (_currentFarmId != null) {
            final listResult = await getCattleListUseCase(
              GetCattleListParams(farmId: _currentFarmId!),
            );

            listResult.fold(
              (failure) => emit(CattleError(failure.message)),
              (cattleList) => emit(CattleOperationSuccess(
                message: 'Bovino eliminado exitosamente',
                cattle: cattleList,
              )),
            );
          }
        },
      );
    } catch (e) {
      emit(CattleError('Error inesperado al eliminar bovino: $e'));
      // Restaurar el estado anterior
      if (currentState is CattleLoaded) {
        emit(currentState);
      }
    }
  }

  /// Limpia el mensaje de éxito y vuelve al estado cargado
  void clearSuccessMessage() {
    if (state is CattleOperationSuccess) {
      final successState = state as CattleOperationSuccess;
      emit(CattleLoaded(successState.cattle));
    }
  }

  @override
  Future<void> close() {
    _cattleSubscription?.cancel();
    return super.close();
  }
}







