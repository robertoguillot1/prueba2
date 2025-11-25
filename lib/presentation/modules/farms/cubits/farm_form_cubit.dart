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
    emit(const FarmFormLoading());
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

      final createdFarm = await createFarmUseCase.call(farm);
      emit(FarmFormSuccess(createdFarm));
    } catch (e) {
      emit(FarmFormError('Error al crear la finca: $e'));
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
    emit(const FarmFormLoading());
    try {
      final updatedFarm = farm.copyWith(
        name: name ?? farm.name,
        location: location ?? farm.location,
        description: description ?? farm.description,
        imageUrl: imageUrl ?? farm.imageUrl,
        primaryColor: primaryColor ?? farm.primaryColor,
        updatedAt: DateTime.now(),
      );

      final savedFarm = await updateFarmUseCase.call(updatedFarm);
      emit(FarmFormSuccess(savedFarm));
    } catch (e) {
      emit(FarmFormError('Error al actualizar la finca: $e'));
    }
  }

  /// Resetea el estado del formulario
  void reset() {
    emit(const FarmFormInitial());
  }
}


