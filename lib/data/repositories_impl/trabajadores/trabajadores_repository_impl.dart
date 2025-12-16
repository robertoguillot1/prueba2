import '../../../core/utils/result.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/trabajadores/trabajador.dart';
import '../../../domain/repositories/trabajadores/trabajadores_repository.dart';
import '../../datasources/trabajadores/trabajadores_datasource.dart';
import '../../models/trabajadores/trabajador_model.dart';
import '../../../features/trabajadores/domain/entities/pago.dart';
import '../../../features/trabajadores/domain/entities/prestamo.dart';
import '../../../features/trabajadores/data/models/pago_model.dart';
import '../../../features/trabajadores/data/models/prestamo_model.dart';

/// Implementación del repositorio de Trabajadores
class TrabajadoresRepositoryImpl implements TrabajadoresRepository {
  final TrabajadoresDataSource dataSource;

  TrabajadoresRepositoryImpl(this.dataSource);

  @override
  Future<Result<List<Trabajador>>> getAllTrabajadores(String farmId) async {
    try {
      final models = await dataSource.getAllTrabajadores(farmId);
      return Success(models);
    } catch (e) {
      return Error(CacheFailure('Error al obtener trabajadores: $e'));
    }
  }

  @override
  Future<Result<Trabajador>> getTrabajadorById(String id, String farmId) async {
    try {
      final model = await dataSource.getTrabajadorById(id, farmId);
      return Success(model);
    } catch (e) {
      if (e is CacheFailure) {
        return Error(e);
      }
      return Error(CacheFailure('Error al obtener trabajador: $e'));
    }
  }

  @override
  Future<Result<Trabajador>> createTrabajador(Trabajador trabajador) async {
    try {
      final model = TrabajadorModel.fromEntity(trabajador);
      final created = await dataSource.createTrabajador(model);
      return Success(created);
    } catch (e) {
      if (e is Failure) {
        return Error(e);
      }
      return Error(CacheFailure('Error al crear trabajador: $e'));
    }
  }

  @override
  Future<Result<Trabajador>> updateTrabajador(Trabajador trabajador) async {
    try {
      final model = TrabajadorModel.fromEntity(trabajador);
      final updated = await dataSource.updateTrabajador(model);
      return Success(updated);
    } catch (e) {
      if (e is Failure) {
        return Error(e);
      }
      return Error(CacheFailure('Error al actualizar trabajador: $e'));
    }
  }

  @override
  Future<Result<void>> deleteTrabajador(String id, String farmId) async {
    try {
      await dataSource.deleteTrabajador(id, farmId);
      return const Success(null);
    } catch (e) {
      return Error(CacheFailure('Error al eliminar trabajador: $e'));
    }
  }

  @override
  Future<Result<List<Trabajador>>> getTrabajadoresActivos(String farmId) async {
    try {
      final models = await dataSource.getTrabajadoresActivos(farmId);
      return Success(models);
    } catch (e) {
      return Error(CacheFailure('Error al obtener trabajadores activos: $e'));
    }
  }

  @override
  Future<Result<List<Trabajador>>> searchTrabajadores(String farmId, String query) async {
    try {
      final models = await dataSource.searchTrabajadores(farmId, query);
      return Success(models);
    } catch (e) {
      return Error(CacheFailure('Error al buscar trabajadores: $e'));
    }
  }

  // === PAGOS ===
  @override
  Future<Result<List<Pago>>> getPagosByTrabajador(String workerId) async {
    try {
      final models = await dataSource.getPagosByTrabajador(workerId);
      return Success(models);
    } catch (e) {
      return Error(CacheFailure('Error al obtener pagos: $e'));
    }
  }

  @override
  Future<Result<Pago>> createPago(Pago pago) async {
    try {
      // Ensure we pass a Model to the DataSource
      final model = pago is PagoModel ? pago : PagoModel.fromEntity(pago);
      final createdValues = await dataSource.createPago(model);
      return Success(createdValues);
    } catch (e) {
       return Error(CacheFailure('Error al crear pago: $e'));
    }
  }

  @override
  Future<Result<Pago>> updatePago(Pago pago) async {
    // Este método no está implementado en el data source legacy
    // El repositorio híbrido es el que debe usarse para pagos/préstamos
    return Error(CacheFailure('updatePago no está disponible en el sistema legacy. Use TrabajadoresHybridRepository.'));
  }

  @override
  Future<Result<void>> deletePago(String workerId, String pagoId) async {
    // Este método no está implementado en el data source legacy
    // El repositorio híbrido es el que debe usarse para pagos/préstamos
    return Error(CacheFailure('deletePago no está disponible en el sistema legacy. Use TrabajadoresHybridRepository.'));
  }

  // === PRESTAMOS ===
  @override
  Future<Result<List<Prestamo>>> getPrestamosByTrabajador(String workerId) async {
    try {
      final models = await dataSource.getPrestamosByTrabajador(workerId);
      return Success(models);
    } catch (e) {
      return Error(CacheFailure('Error al obtener préstamos: $e'));
    }
  }

  @override
  Future<Result<Prestamo>> createPrestamo(Prestamo prestamo) async {
    try {
      final model = prestamo is PrestamoModel ? prestamo : PrestamoModel.fromEntity(prestamo);
      final created = await dataSource.createPrestamo(model);
      return Success(created);
    } catch (e) {
      return Error(CacheFailure('Error al crear préstamo: $e'));
    }
  }

  @override
  Future<Result<Prestamo>> updatePrestamo(Prestamo prestamo) async {
    try {
      final model = prestamo is PrestamoModel ? prestamo : PrestamoModel.fromEntity(prestamo);
      final updated = await dataSource.updatePrestamo(model);
      return Success(updated);
    } catch (e) {
      return Error(CacheFailure('Error al actualizar préstamo: $e'));
    }
  }

  @override
  Future<Result<void>> deletePrestamo(String workerId, String prestamoId) async {
    // Este método no está implementado en el data source legacy
    // El repositorio híbrido es el que debe usarse para pagos/préstamos
    return Error(CacheFailure('deletePrestamo no está disponible en el sistema legacy. Use TrabajadoresHybridRepository.'));
  }
}
