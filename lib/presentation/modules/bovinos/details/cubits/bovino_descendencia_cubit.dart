import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../../domain/entities/bovinos/bovino.dart';
import '../../../../../domain/usecases/bovinos/get_bovinos_stream.dart';

// --- ESTADOS ---
abstract class BovinoDescendenciaState extends Equatable {
  const BovinoDescendenciaState();

  @override
  List<Object?> get props => [];
}

class BovinoDescendenciaInitial extends BovinoDescendenciaState {}

class BovinoDescendenciaLoading extends BovinoDescendenciaState {}

class BovinoDescendenciaLoaded extends BovinoDescendenciaState {
  final List<Bovino> hijos;

  const BovinoDescendenciaLoaded(this.hijos);

  @override
  List<Object?> get props => [hijos];
}

class BovinoDescendenciaError extends BovinoDescendenciaState {
  final String message;

  const BovinoDescendenciaError(this.message);

  @override
  List<Object?> get props => [message];
}

// --- CUBIT ---
class BovinoDescendenciaCubit extends Cubit<BovinoDescendenciaState> {
  final GetBovinosStream _getBovinos;
  StreamSubscription<List<Bovino>>? _bovinosSubscription;

  BovinoDescendenciaCubit({
    required GetBovinosStream getBovinos,
  })  : _getBovinos = getBovinos,
        super(BovinoDescendenciaInitial());

  void cargarDescendencia(String bovinoId) {
    _bovinosSubscription?.cancel();
    emit(BovinoDescendenciaLoading());

    // Suscribirse al Stream general de bovinos
    _bovinosSubscription = _getBovinos().listen(
      (todosLosBovinos) {
        try {
          // Filtrar: ¿Quién tiene a este bovino como padre O madre?
          final hijos = todosLosBovinos.where((b) {
            return b.idPadre == bovinoId || b.idMadre == bovinoId;
          }).toList();

          // Ordenar por fecha de nacimiento descendente
          hijos.sort((a, b) => b.birthDate.compareTo(a.birthDate));

          emit(BovinoDescendenciaLoaded(hijos));
        } catch (e) {
          emit(BovinoDescendenciaError("Error filtrando hijos: ${e.toString()}"));
        }
      },
      onError: (error) {
        emit(BovinoDescendenciaError(error.toString()));
      },
    );
  }

  @override
  Future<void> close() {
    _bovinosSubscription?.cancel();
    return super.close();
  }
}

