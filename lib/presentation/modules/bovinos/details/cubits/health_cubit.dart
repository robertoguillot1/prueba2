import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../features/cattle/domain/entities/vacuna_bovino_entity.dart';
import '../../../../../features/cattle/domain/usecases/get_vacunas_by_bovino.dart';
import '../../../../../features/cattle/domain/usecases/add_vacuna_bovino.dart';
import '../../../../../core/utils/result.dart';
import 'health_state.dart';

/// Cubit para gestionar el estado de sanidad (vacunas) de un bovino
class HealthCubit extends Cubit<HealthState> {
  final GetVacunasByBovino getVacunas;
  final AddVacunaBovino addVacuna;

  HealthCubit({
    required this.getVacunas,
    required this.addVacuna,
  }) : super(const HealthInitial());

  /// Carga las vacunas de un bovino
  Future<void> loadVacunas({
    required String bovineId,
    required String farmId,
  }) async {
    emit(const HealthLoading());

    try {
      final result = await getVacunas(bovineId, farmId);

      switch (result) {
        case Success<List<VacunaBovinoEntity>>(:final data):
          // Ordenar por fecha descendente (más recientes primero)
          final sortedVacunas = List<VacunaBovinoEntity>.from(data);
          sortedVacunas.sort((a, b) => b.fechaAplicacion.compareTo(a.fechaAplicacion));
          
          emit(HealthLoaded(vacunas: sortedVacunas));
        
        case Error<List<VacunaBovinoEntity>>(:final failure):
          emit(HealthError(failure.message));
      }
    } catch (e) {
      emit(HealthError('Error inesperado al cargar vacunas: $e'));
    }
  }

  /// Refresca la lista de vacunas
  Future<void> refresh({
    required String bovineId,
    required String farmId,
  }) async {
    await loadVacunas(bovineId: bovineId, farmId: farmId);
  }

  /// Agrega una nueva vacuna
  Future<void> addNewVacuna({
    required String bovinoId,
    required String farmId,
    required DateTime fechaAplicacion,
    required String nombreVacuna,
    String? lote,
    DateTime? proximaDosis,
    String? notas,
  }) async {
    emit(const HealthLoading());

    try {
      final newVacuna = VacunaBovinoEntity(
        id: '', // Se generará en el datasource
        bovinoId: bovinoId,
        farmId: farmId,
        fechaAplicacion: fechaAplicacion,
        nombreVacuna: nombreVacuna,
        lote: lote,
        proximaDosis: proximaDosis,
        notas: notas,
        createdAt: DateTime.now(),
      );

      final result = await addVacuna(AddVacunaBovinoParams(vacuna: newVacuna));

      switch (result) {
        case Success<VacunaBovinoEntity>():
          emit(const HealthOperationSuccess('Vacuna registrada exitosamente'));
          // Recargar la lista
          loadVacunas(bovineId: bovinoId, farmId: farmId);
        
        case Error<VacunaBovinoEntity>(:final failure):
          emit(HealthError(failure.message));
          // Intentar recargar la lista anterior
          loadVacunas(bovineId: bovinoId, farmId: farmId);
      }
    } catch (e) {
      emit(HealthError('Error inesperado al agregar vacuna: $e'));
      // Intentar recargar la lista anterior
      loadVacunas(bovineId: bovinoId, farmId: farmId);
    }
  }
}

