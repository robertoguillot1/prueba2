import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../features/cattle/domain/entities/bovine_entity.dart';
import '../../../../../features/cattle/domain/usecases/add_bovine.dart';
import '../../../../../features/cattle/domain/usecases/update_bovine.dart';
import '../../../../../features/cattle/domain/usecases/delete_bovine.dart';
import 'bovino_form_state.dart';

/// Cubit para manejar el formulario de Bovino (Crear/Editar/Eliminar)
class BovinoFormCubit extends Cubit<BovinoFormState> {
  final AddBovine addBovineUseCase;
  final UpdateBovine updateBovineUseCase;
  final DeleteBovine deleteBovineUseCase;

  BovineEntity? _currentBovine; // Almacena el bovino en modo edición
  bool get isEditMode => _currentBovine != null;

  BovinoFormCubit({
    required this.addBovineUseCase,
    required this.updateBovineUseCase,
    required this.deleteBovineUseCase,
  }) : super(const BovinoFormInitial());

  /// Inicializa el formulario
  /// Si recibe un bovino, entra en modo edición
  /// Si es null, entra en modo creación
  void initialize(BovineEntity? bovine) {
    _currentBovine = bovine;
    if (bovine != null) {
      emit(BovinoFormLoaded(bovine));
    } else {
      emit(const BovinoFormInitial());
    }
  }

  /// Envía el formulario
  Future<void> submit({
    required String farmId,
    required String identifier,
    String? name,
    required String breed,
    required BovineGender gender,
    required DateTime birthDate,
    required double weight,
    required BovinePurpose purpose,
    required BovineStatus status,
    String? motherId,
    String? fatherId,
    int previousCalvings = 0,
    HealthStatus healthStatus = HealthStatus.healthy,
    ProductionStage productionStage = ProductionStage.raising,
    BreedingStatus? breedingStatus,
    DateTime? lastHeatDate,
    DateTime? inseminationDate,
    DateTime? expectedCalvingDate,
    String? notes,
  }) async {
    // Validaciones básicas
    if (identifier.trim().isEmpty) {
      emit(const BovinoFormError('El identificador es obligatorio'));
      return;
    }

    if (breed.trim().isEmpty) {
      emit(const BovinoFormError('La raza es obligatoria'));
      return;
    }

    if (weight <= 0) {
      emit(const BovinoFormError('El peso debe ser mayor a 0'));
      return;
    }

    if (birthDate.isAfter(DateTime.now())) {
      emit(const BovinoFormError('La fecha de nacimiento no puede ser futura'));
      return;
    }

    emit(const BovinoFormLoading());

    try {
      if (isEditMode) {
        // MODO EDICIÓN
        await _updateBovine(
          farmId: farmId,
          identifier: identifier,
          name: name,
          breed: breed,
          gender: gender,
          birthDate: birthDate,
          weight: weight,
          purpose: purpose,
          status: status,
          motherId: motherId,
          fatherId: fatherId,
          previousCalvings: previousCalvings,
          healthStatus: healthStatus,
          productionStage: productionStage,
          breedingStatus: breedingStatus,
          lastHeatDate: lastHeatDate,
          inseminationDate: inseminationDate,
          expectedCalvingDate: expectedCalvingDate,
          notes: notes,
        );
      } else {
        // MODO CREACIÓN
        await _createBovine(
          farmId: farmId,
          identifier: identifier,
          name: name,
          breed: breed,
          gender: gender,
          birthDate: birthDate,
          weight: weight,
          purpose: purpose,
          status: status,
          motherId: motherId,
          fatherId: fatherId,
          previousCalvings: previousCalvings,
          healthStatus: healthStatus,
          productionStage: productionStage,
          breedingStatus: breedingStatus,
          lastHeatDate: lastHeatDate,
          inseminationDate: inseminationDate,
          expectedCalvingDate: expectedCalvingDate,
          notes: notes,
        );
      }
    } catch (e) {
      emit(BovinoFormError('Error inesperado: $e'));
    }
  }

  /// Crea un nuevo bovino
  Future<void> _createBovine({
    required String farmId,
    required String identifier,
    String? name,
    required String breed,
    required BovineGender gender,
    required DateTime birthDate,
    required double weight,
    required BovinePurpose purpose,
    required BovineStatus status,
    String? motherId,
    String? fatherId,
    int previousCalvings = 0,
    HealthStatus healthStatus = HealthStatus.healthy,
    ProductionStage productionStage = ProductionStage.raising,
    BreedingStatus? breedingStatus,
    DateTime? lastHeatDate,
    DateTime? inseminationDate,
    DateTime? expectedCalvingDate,
    String? notes,
  }) async {
    final newBovine = BovineEntity(
      id: '', // Se generará en el datasource
      farmId: farmId,
      identifier: identifier,
      name: name?.trim().isEmpty == true ? null : name?.trim(),
      breed: breed,
      gender: gender,
      birthDate: birthDate,
      weight: weight,
      purpose: purpose,
      status: status,
      createdAt: DateTime.now(),
      motherId: motherId,
      fatherId: fatherId,
      previousCalvings: previousCalvings,
      healthStatus: healthStatus,
      productionStage: productionStage,
      breedingStatus: breedingStatus,
      lastHeatDate: lastHeatDate,
      inseminationDate: inseminationDate,
      expectedCalvingDate: expectedCalvingDate,
      notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
    );

    final result = await addBovineUseCase.call(AddBovineParams(bovine: newBovine));

    result.fold(
      (failure) => emit(BovinoFormError(failure.message)),
      (createdBovine) => emit(BovinoFormSuccess(
        bovine: createdBovine,
        isEdit: false,
      )),
    );
  }

  /// Actualiza un bovino existente
  Future<void> _updateBovine({
    required String farmId,
    required String identifier,
    String? name,
    required String breed,
    required BovineGender gender,
    required DateTime birthDate,
    required double weight,
    required BovinePurpose purpose,
    required BovineStatus status,
    String? motherId,
    String? fatherId,
    int previousCalvings = 0,
    HealthStatus healthStatus = HealthStatus.healthy,
    ProductionStage productionStage = ProductionStage.raising,
    BreedingStatus? breedingStatus,
    DateTime? lastHeatDate,
    DateTime? inseminationDate,
    DateTime? expectedCalvingDate,
    String? notes,
  }) async {
    if (_currentBovine == null) {
      emit(const BovinoFormError('No hay un bovino para actualizar'));
      return;
    }

    final updatedBovine = _currentBovine!.copyWith(
      identifier: identifier,
      name: name?.trim().isEmpty == true ? null : name?.trim(),
      breed: breed,
      gender: gender,
      birthDate: birthDate,
      weight: weight,
      purpose: purpose,
      status: status,
      updatedAt: DateTime.now(),
      motherId: motherId,
      fatherId: fatherId,
      previousCalvings: previousCalvings,
      healthStatus: healthStatus,
      productionStage: productionStage,
      breedingStatus: breedingStatus,
      lastHeatDate: lastHeatDate,
      inseminationDate: inseminationDate,
      expectedCalvingDate: expectedCalvingDate,
      notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
    );

    final result = await updateBovineUseCase.call(
      UpdateBovineParams(bovine: updatedBovine),
    );

    result.fold(
      (failure) => emit(BovinoFormError(failure.message)),
      (updatedBovineResult) => emit(BovinoFormSuccess(
        bovine: updatedBovineResult,
        isEdit: true,
      )),
    );
  }

  /// Elimina un bovino
  Future<void> delete(String bovineId) async {
    // Guardar el estado actual
    final currentState = state;
    
    emit(const BovinoFormLoading());

    try {
      final result = await deleteBovineUseCase.call(DeleteBovineParams(id: bovineId));

      result.fold(
        (failure) {
          emit(BovinoFormError(failure.message));
          // Restaurar el estado anterior después de un error
          if (currentState is BovinoFormLoaded) {
            emit(currentState);
          }
        },
        (_) {
          emit(const BovinoFormDeleted());
        },
      );
    } catch (e) {
      emit(BovinoFormError('Error inesperado al eliminar bovino: $e'));
      // Restaurar el estado anterior
      if (currentState is BovinoFormLoaded) {
        emit(currentState);
      }
    }
  }

  /// Resetea el formulario
  void reset() {
    _currentBovine = null;
    emit(const BovinoFormInitial());
  }
}

