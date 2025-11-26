import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/farm/farm.dart';
import '../../../../domain/usecases/farm/create_farm.dart';
import '../../../../domain/usecases/farm/update_farm.dart';
import 'farm_form_state.dart';

/// Cubit para manejar el formulario de finca
class FarmFormCubit extends Cubit<FarmFormState> {
  final CreateFarm createFarmUseCase;
  final UpdateFarm updateFarmUseCase;
  final String userId;

  FarmFormCubit({
    required this.createFarmUseCase,
    required this.updateFarmUseCase,
    required this.userId,
  }) : super(const FarmFormInitial());

  /// Crea una nueva finca
  Future<void> createFarm({
    required String name,
    String? location,
    String? description,
    String? imageUrl,
    int primaryColor = 0xFF4CAF50, // Verde por defecto
  }) async {
    print('🟢 [FarmFormCubit] createFarm iniciado - name: $name');
    emit(const FarmFormLoading());
    print('🟡 [FarmFormCubit] Estado emitido: FarmFormLoading');
    
    try {
      final farm = Farm(
        id: '', // Se generará en el datasource
        ownerId: userId,
        name: name,
        location: location,
        description: description,
        imageUrl: imageUrl,
        primaryColor: primaryColor,
        createdAt: DateTime.now(),
      );

      print('🔵 [FarmFormCubit] Llamando a createFarmUseCase...');
      final createdFarm = await createFarmUseCase.call(farm);
      print('✅ [FarmFormCubit] Finca creada exitosamente - ID: ${createdFarm.id}');
      
      emit(FarmFormSuccess(createdFarm));
      print('✅ [FarmFormCubit] Estado emitido: FarmFormSuccess');
    } catch (e, stackTrace) {
      print('❌ [FarmFormCubit] Error al crear finca: $e');
      print('❌ [FarmFormCubit] StackTrace: $stackTrace');
      emit(FarmFormError('Error al crear la finca: $e'));
      print('🔴 [FarmFormCubit] Estado emitido: FarmFormError');
    }
  }

  /// Actualiza una finca existente
  Future<void> updateFarm({
    required Farm farm,
    String? name,
    String? location,
    String? description,
    String? imageUrl,
    int? primaryColor,
  }) async {
    print('🟢 [FarmFormCubit] updateFarm iniciado - farmId: ${farm.id}');
    emit(const FarmFormLoading());
    print('🟡 [FarmFormCubit] Estado emitido: FarmFormLoading');
    
    try {
      final updatedFarm = farm.copyWith(
        name: name ?? farm.name,
        location: location ?? farm.location,
        description: description ?? farm.description,
        imageUrl: imageUrl ?? farm.imageUrl,
        primaryColor: primaryColor ?? farm.primaryColor,
        updatedAt: DateTime.now(),
      );

      print('🔵 [FarmFormCubit] Llamando a updateFarmUseCase...');
      final savedFarm = await updateFarmUseCase.call(updatedFarm);
      print('✅ [FarmFormCubit] Finca actualizada exitosamente - ID: ${savedFarm.id}');
      
      emit(FarmFormSuccess(savedFarm));
      print('✅ [FarmFormCubit] Estado emitido: FarmFormSuccess');
    } catch (e, stackTrace) {
      print('❌ [FarmFormCubit] Error al actualizar finca: $e');
      print('❌ [FarmFormCubit] StackTrace: $stackTrace');
      emit(FarmFormError('Error al actualizar la finca: $e'));
      print('🔴 [FarmFormCubit] Estado emitido: FarmFormError');
    }
  }

  /// Resetea el estado del formulario
  void reset() {
    emit(const FarmFormInitial());
  }
}


