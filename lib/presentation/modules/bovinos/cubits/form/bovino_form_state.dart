import 'package:equatable/equatable.dart';
import '../../../../../features/cattle/domain/entities/bovine_entity.dart';

/// Estados del formulario de Bovino
abstract class BovinoFormState extends Equatable {
  const BovinoFormState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class BovinoFormInitial extends BovinoFormState {
  const BovinoFormInitial();
}

/// Estado de carga (guardando)
class BovinoFormLoading extends BovinoFormState {
  const BovinoFormLoading();
}

/// Estado de éxito (crear/editar)
class BovinoFormSuccess extends BovinoFormState {
  final BovineEntity bovine;
  final bool isEdit; // true si fue edición, false si fue creación

  const BovinoFormSuccess({
    required this.bovine,
    required this.isEdit,
  });

  @override
  List<Object?> get props => [bovine, isEdit];
}

/// Estado de éxito al eliminar
class BovinoFormDeleted extends BovinoFormState {
  final String message;

  const BovinoFormDeleted({this.message = 'Bovino eliminado exitosamente'});

  @override
  List<Object?> get props => [message];
}

/// Estado de error
class BovinoFormError extends BovinoFormState {
  final String message;

  const BovinoFormError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Estado con datos pre-cargados (para edición)
class BovinoFormLoaded extends BovinoFormState {
  final BovineEntity bovine;

  const BovinoFormLoaded(this.bovine);

  @override
  List<Object?> get props => [bovine];
}

