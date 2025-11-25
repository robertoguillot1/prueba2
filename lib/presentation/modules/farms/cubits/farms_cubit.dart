import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/farm/farm.dart';
import '../../../../domain/usecases/farm/get_farms_stream.dart';
import '../../../../domain/usecases/farm/delete_farm.dart';
import '../../../../domain/usecases/farm/set_current_farm.dart';
import 'farms_state.dart';

/// Cubit para manejar la lista de fincas
class FarmsCubit extends Cubit<FarmsState> {
  final GetFarmsStream getFarmsStream;
  final DeleteFarm deleteFarmUseCase;
  final SetCurrentFarm setCurrentFarmUseCase;
  final String userId;

  StreamSubscription<List<Farm>>? _farmsSubscription;

  FarmsCubit({
    required this.getFarmsStream,
    required this.deleteFarmUseCase,
    required this.setCurrentFarmUseCase,
    required this.userId,
  }) : super(const FarmsInitial()) {
    _loadFarms();
  }

  /// Carga las fincas del usuario
  void _loadFarms() {
    emit(const FarmsLoading());
    
    _farmsSubscription?.cancel();
    _farmsSubscription = getFarmsStream().listen(
      (farms) {
        emit(FarmsLoaded(farms));
      },
      onError: (error) {
        emit(FarmsError('Error al cargar las fincas: $error'));
      },
    );
  }

  /// Recarga las fincas
  void reloadFarms() {
    _loadFarms();
  }

  /// Elimina una finca
  Future<void> deleteFarm(String farmId) async {
    try {
      await deleteFarmUseCase.call(userId, farmId);
      // El stream se actualizará automáticamente
    } catch (e) {
      emit(FarmsError('Error al eliminar la finca: $e'));
    }
  }

  /// Establece la finca actual
  Future<void> setCurrentFarm(String farmId) async {
    try {
      await setCurrentFarmUseCase.call(userId, farmId);
    } catch (e) {
      emit(FarmsError('Error al establecer la finca actual: $e'));
    }
  }

  @override
  Future<void> close() {
    _farmsSubscription?.cancel();
    return super.close();
  }
}

