import '../../../core/utils/result.dart';
import '../../entities/trabajadores/tarea.dart';

/// Repositorio abstracto para Tareas
abstract class TareasRepository {
  /// Obtiene todas las tareas de una finca
  Future<Result<List<Tarea>>> getAllTareas(String farmId);
  
  /// Obtiene una tarea por su ID
  Future<Result<Tarea>> getTareaById(String id, String farmId);
  
  /// Crea una nueva tarea
  Future<Result<Tarea>> createTarea(Tarea tarea);
  
  /// Actualiza una tarea existente
  Future<Result<Tarea>> updateTarea(Tarea tarea);
  
  /// Elimina una tarea
  Future<Result<void>> deleteTarea(String id, String farmId);
  
  /// Obtiene tareas de un trabajador específico
  Future<Result<List<Tarea>>> getTareasByTrabajador(String trabajadorId, String farmId);
  
  /// Obtiene tareas por estado
  Future<Result<List<Tarea>>> getTareasByEstado(String farmId, TareaEstado estado);
}

