import 'package:equatable/equatable.dart';
import '../../../../../features/cattle/domain/entities/vacuna_bovino_entity.dart';

/// Estados del Cubit de Sanidad
abstract class HealthState extends Equatable {
  const HealthState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class HealthInitial extends HealthState {
  const HealthInitial();
}

/// Estado de carga
class HealthLoading extends HealthState {
  const HealthLoading();
}

/// Estado exitoso con datos cargados
class HealthLoaded extends HealthState {
  final List<VacunaBovinoEntity> vacunas;

  const HealthLoaded({required this.vacunas});

  @override
  List<Object?> get props => [vacunas];

  /// Obtiene las vacunas que requieren refuerzo próximo (dentro de 30 días)
  List<VacunaBovinoEntity> get vacunasConRefuerzoPendiente {
    final now = DateTime.now();
    final limite = now.add(const Duration(days: 30));
    
    return vacunas.where((v) {
      if (v.proximaDosis == null) return false;
      return v.proximaDosis!.isAfter(now) && v.proximaDosis!.isBefore(limite);
    }).toList();
  }

  /// Obtiene las vacunas con refuerzo atrasado
  List<VacunaBovinoEntity> get vacunasConRefuerzoAtrasado {
    return vacunas.where((v) => v.refuerzoAtrasado).toList();
  }
}

/// Estado de error
class HealthError extends HealthState {
  final String message;

  const HealthError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Estado después de una operación exitosa (agregar/actualizar/eliminar)
class HealthOperationSuccess extends HealthState {
  final String message;

  const HealthOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}




