import 'package:equatable/equatable.dart';
import '../../../../domain/entities/farm/farm.dart';

/// Estados del cubit de formulario de finca
abstract class FarmFormState extends Equatable {
  const FarmFormState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class FarmFormInitial extends FarmFormState {
  const FarmFormInitial();
}

/// Estado de carga (guardando)
class FarmFormLoading extends FarmFormState {
  const FarmFormLoading();
}

/// Estado cuando se guardó exitosamente
class FarmFormSuccess extends FarmFormState {
  final Farm farm;

  const FarmFormSuccess(this.farm);

  @override
  List<Object?> get props => [farm];
}

/// Estado cuando ocurre un error
class FarmFormError extends FarmFormState {
  final String message;

  const FarmFormError(this.message);

  @override
  List<Object?> get props => [message];
}





