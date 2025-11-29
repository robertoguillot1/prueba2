import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import '../../../../../features/cattle/domain/entities/milk_production_entity.dart';
import '../../../../../features/cattle/domain/entities/weight_record_entity.dart';
import '../../../../../features/cattle/domain/usecases/add_milk_production.dart';
import '../../../../../features/cattle/domain/usecases/add_weight_record.dart';
import '../../../../../core/errors/failures.dart';

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

    // Crear la entidad (el ID se generará en Firestore)
    final production = MilkProductionEntity(
      id: '', // Se generará en Firestore
      bovineId: bovineId,
      farmId: farmId,
      recordDate: date,
      litersProduced: liters,
      notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
      createdAt: DateTime.now(),
      updatedAt: null,
    );

    // Validar que la entidad sea válida
    if (!production.isValid) {
      emit(const ProductionFormError('Los datos de producción no son válidos'));
      return;
    }

    // Llamar al caso de uso
    final result = await _addMilkProduction(
      AddMilkProductionParams(production: production),
    );

    // Manejar resultado
    result.fold(
      (failure) {
        emit(ProductionFormError(_getErrorMessage(failure)));
      },
      (_) {
        emit(const ProductionFormSuccess('Producción de leche registrada exitosamente'));
      },
    );
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

    // Crear la entidad (el ID se generará en Firestore)
    final weightRecord = WeightRecordEntity(
      id: '', // Se generará en Firestore
      bovineId: bovineId,
      farmId: farmId,
      recordDate: date,
      weight: weight,
      notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
      createdAt: DateTime.now(),
      updatedAt: null,
    );

    // Validar que la entidad sea válida
    if (!weightRecord.isValid) {
      emit(const ProductionFormError('Los datos de peso no son válidos'));
      return;
    }

    // Llamar al caso de uso
    final result = await _addWeightRecord(
      AddWeightRecordParams(record: weightRecord),
    );

    // Manejar resultado
    result.fold(
      (failure) {
        emit(ProductionFormError(_getErrorMessage(failure)));
      },
      (_) {
        emit(const ProductionFormSuccess('Peso registrado exitosamente'));
      },
    );
  }

  /// Resetea el estado del formulario
  void reset() {
    emit(ProductionFormInitial());
  }

  /// Obtiene un mensaje de error legible desde un Failure
  String _getErrorMessage(Failure failure) {
    if (failure is ServerFailure) {
      return 'Error del servidor: ${failure.message}';
    } else if (failure is NetworkFailure) {
      return 'Error de conexión: ${failure.message}';
    } else if (failure is ValidationFailure) {
      return 'Error de validación: ${failure.message}';
    } else {
      return failure.message;
    }
  }
}
