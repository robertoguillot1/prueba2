import 'package:equatable/equatable.dart';
import '../../../../domain/entities/farm/farm.dart';

/// Estados del cubit de lista de fincas
abstract class FarmsState extends Equatable {
  const FarmsState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class FarmsInitial extends FarmsState {
  const FarmsInitial();
}

/// Estado de carga
class FarmsLoading extends FarmsState {
  const FarmsLoading();
}

/// Estado cuando las fincas se han cargado exitosamente
class FarmsLoaded extends FarmsState {
  final List<Farm> farms;

  const FarmsLoaded(this.farms);

  @override
  List<Object?> get props => [farms];
}

/// Estado cuando ocurre un error
class FarmsError extends FarmsState {
  final String message;

  const FarmsError(this.message);

  @override
  List<Object?> get props => [message];
}


