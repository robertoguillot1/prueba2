import 'package:equatable/equatable.dart';
import '../../domain/entities/bovine_entity.dart';

/// Estados del cubit de Cattle
abstract class CattleState extends Equatable {
  const CattleState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class CattleInitial extends CattleState {
  const CattleInitial();
}

/// Estado de carga
class CattleLoading extends CattleState {
  const CattleLoading();
}

/// Estado cuando los bovinos se han cargado exitosamente
class CattleLoaded extends CattleState {
  final List<BovineEntity> cattle;

  const CattleLoaded(this.cattle);

  @override
  List<Object?> get props => [cattle];
}

/// Estado cuando una operación se completó exitosamente
class CattleOperationSuccess extends CattleState {
  final String message;
  final List<BovineEntity> cattle; // Mantener la lista actualizada

  const CattleOperationSuccess({
    required this.message,
    required this.cattle,
  });

  @override
  List<Object?> get props => [message, cattle];
}

/// Estado cuando ocurre un error
class CattleError extends CattleState {
  final String message;

  const CattleError(this.message);

  @override
  List<Object?> get props => [message];
}


