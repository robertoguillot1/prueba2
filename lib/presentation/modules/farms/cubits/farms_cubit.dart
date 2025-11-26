import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/farm/farm.dart';
import '../../../../domain/usecases/farm/get_farms_stream.dart';
import '../../../../domain/usecases/farm/delete_farm.dart';
import '../../../../domain/usecases/farm/set_current_farm.dart';
import '../../../../domain/repositories/farm_repository.dart';
import 'farms_state.dart';

/// Cubit para manejar la lista de fincas
class FarmsCubit extends Cubit<FarmsState> {
  final GetFarmsStream getFarmsStream;
  final DeleteFarm deleteFarmUseCase;
  final SetCurrentFarm setCurrentFarmUseCase;
  final FarmRepository farmRepository;
  final String userId;

  StreamSubscription<List<Farm>>? _farmsSubscription;
  bool _hasLoadedInitialData = false;

  FarmsCubit({
    required this.getFarmsStream,
    required this.deleteFarmUseCase,
    required this.setCurrentFarmUseCase,
    required this.farmRepository,
    required this.userId,
  }) : super(const FarmsInitial()) {
    _loadFarms();
  }

  /// Carga las fincas del usuario
  void _loadFarms() async {
    emit(const FarmsLoading());
    
    // Primero, hacer una consulta rápida para obtener los datos inmediatamente
    if (!_hasLoadedInitialData) {
      try {
        final farms = await farmRepository.getFarms(userId);
        emit(FarmsLoaded(farms));
        _hasLoadedInitialData = true;
      } catch (e) {
        emit(FarmsError('Error al cargar las fincas: $e'));
        return;
      }
    }
    
    // Luego, suscribirse al stream para actualizaciones en tiempo real
    _farmsSubscription?.cancel();
    _farmsSubscription = getFarmsStream().listen(
      (farms) {
        // Actualizar con los datos del stream
        emit(FarmsLoaded(farms));
      },
      onError: (error) {
        emit(FarmsError('Error al cargar las fincas: $error'));
      },
      cancelOnError: false,
    );
  }

  /// Recarga las fincas
  void reloadFarms() {
    _hasLoadedInitialData = false; // Resetear para forzar recarga inicial
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
    print('🟢 [FarmsCubit] setCurrentFarm iniciado - farmId: $farmId, userId: $userId');
    try {
      await setCurrentFarmUseCase.call(userId, farmId);
      print('✅ [FarmsCubit] setCurrentFarm completado exitosamente');
      // No emitir estado aquí, la navegación se maneja en la UI
    } catch (e, stackTrace) {
      print('❌ [FarmsCubit] Error en setCurrentFarm: $e');
      print('❌ [FarmsCubit] StackTrace: $stackTrace');
      emit(FarmsError('Error al establecer la finca actual: $e'));
      rethrow; // Re-lanzar el error para que la UI pueda manejarlo
    }
  }

  @override
  Future<void> close() {
    _farmsSubscription?.cancel();
    return super.close();
  }
}

