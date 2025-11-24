import '../../../core/utils/result.dart';
import '../../entities/trabajadores/pago.dart';

/// Repositorio abstracto para Pagos
abstract class PagosRepository {
  /// Obtiene todos los pagos de una finca
  Future<Result<List<Pago>>> getAllPagos(String farmId);
  
  /// Obtiene un pago por su ID
  Future<Result<Pago>> getPagoById(String id, String farmId);
  
  /// Crea un nuevo pago
  Future<Result<Pago>> createPago(Pago pago);
  
  /// Actualiza un pago existente
  Future<Result<Pago>> updatePago(Pago pago);
  
  /// Elimina un pago
  Future<Result<void>> deletePago(String id, String farmId);
  
  /// Obtiene pagos de un trabajador específico
  Future<Result<List<Pago>>> getPagosByTrabajador(String trabajadorId, String farmId);
  
  /// Obtiene pagos en un rango de fechas
  Future<Result<List<Pago>>> getPagosByFecha(String farmId, DateTime fechaInicio, DateTime fechaFin);
}



