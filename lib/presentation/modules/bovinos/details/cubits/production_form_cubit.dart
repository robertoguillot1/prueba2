import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../../domain/entities/bovinos/produccion_leche.dart';
import '../../../../../domain/entities/bovinos/peso_bovino.dart';
import '../../../../../domain/usecases/bovinos/add_milk_production.dart';
import '../../../../../domain/usecases/bovinos/add_weight_record.dart';
import '../../../../../core/utils/result.dart';

// ============================================
// ESTADOS
// ============================================

/// Estados del formulario de producción
abstract class ProductionFormState extends Equatable {
  const ProductionFormState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class ProductionFormInitial extends ProductionFormState {}

/// Estado de guardando
class ProductionFormLoading extends ProductionFormState {}

/// Estado de éxito
class ProductionFormSuccess extends ProductionFormState {
  final String message;

  const ProductionFormSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// Estado de error
class ProductionFormError extends ProductionFormState {
  final String message;

  const ProductionFormError(this.message);

  @override
  List<Object?> get props => [message];
}

// ============================================
// CUBIT
// ============================================

/// Cubit para manejar formularios de producción (Leche y Peso)
class ProductionFormCubit extends Cubit<ProductionFormState> {
  final AddMilkProduction _addMilkProduction;
  final AddWeightRecord _addWeightRecord;

  ProductionFormCubit({
    required AddMilkProduction addMilkProduction,
    required AddWeightRecord addWeightRecord,
  })  : _addMilkProduction = addMilkProduction,
        _addWeightRecord = addWeightRecord,
        super(ProductionFormInitial());

  /// Guarda un registro de producción de leche
  Future<void> saveMilk({
    required String farmId,
    required String bovineId,
    required DateTime date,
    required double liters,
    String? notes,
  }) async {
    emit(ProductionFormLoading());

    try {
      final production = ProduccionLeche(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        bovinoId: bovineId,
        farmId: farmId,
        recordDate: date,
        litersProduced: liters,
        notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await _addMilkProduction(production);

      switch (result) {
        case Success():
          emit(const ProductionFormSuccess('Producción de leche registrada exitosamente'));
        case Error(:final failure):
          emit(ProductionFormError(failure.message));
      }
    } catch (e) {
      emit(ProductionFormError('Error inesperado al guardar producción: $e'));
    }
  }

  /// Guarda un registro de peso
  Future<void> saveWeight({
    required String farmId,
    required String bovineId,
    required DateTime date,
    required double weight,
    String? notes,
  }) async {
    emit(ProductionFormLoading());

    try {
      final weightRecord = PesoBovino(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        bovinoId: bovineId,
        farmId: farmId,
        recordDate: date,
        weight: weight,
        notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await _addWeightRecord(weightRecord);

      switch (result) {
        case Success():
          emit(const ProductionFormSuccess('Peso registrado exitosamente'));
        case Error(:final failure):
          emit(ProductionFormError(failure.message));
      }
    } catch (e) {
      emit(ProductionFormError('Error inesperado al guardar peso: $e'));
    }
  }

  /// Resetea el estado del formulario
  void reset() {
    emit(ProductionFormInitial());
  }
}



