import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../../domain/entities/bovinos/evento_reproductivo.dart';
import '../../../../../domain/usecases/bovinos/get_eventos_reproductivos_by_bovino.dart';

// --- ESTADOS ---
abstract class BovinoPartosState extends Equatable {
  const BovinoPartosState();

  @override
  List<Object?> get props => [];
}

class BovinoPartosInitial extends BovinoPartosState {}

class BovinoPartosLoading extends BovinoPartosState {}

class BovinoPartosLoaded extends BovinoPartosState {
  final List<EventoReproductivo> partos;

  const BovinoPartosLoaded(this.partos);

  @override
  List<Object?> get props => [partos];
}

class BovinoPartosError extends BovinoPartosState {
  final String message;

  const BovinoPartosError(this.message);

  @override
  List<Object?> get props => [message];
}

// --- CUBIT ---
class BovinoPartosCubit extends Cubit<BovinoPartosState> {
  final GetEventosReproductivosByBovino _getEventos;
  StreamSubscription<List<EventoReproductivo>>? _eventosSubscription;

  BovinoPartosCubit({
    required GetEventosReproductivosByBovino getEventos,
  })  : _getEventos = getEventos,
        super(BovinoPartosInitial());

  void cargarPartos(String bovinoId) {
    _eventosSubscription?.cancel(); // Cancelar suscripción previa
    emit(BovinoPartosLoading());

    // Suscribirse al Stream
    _eventosSubscription = _getEventos(bovinoId).listen(
      (eventos) {
        try {
          // Filtrar solo los eventos tipo Parto
          final partos = eventos
              .where((e) => e.tipo == TipoEventoReproductivo.parto)
              .toList();

          // Ordenar descendente (más reciente primero)
          partos.sort((a, b) => b.fecha.compareTo(a.fecha));

          emit(BovinoPartosLoaded(partos));
        } catch (e) {
          emit(BovinoPartosError("Error al procesar partos: ${e.toString()}"));
        }
      },
      onError: (error) {
        emit(BovinoPartosError(error.toString()));
      },
    );
  }

  @override
  Future<void> close() {
    _eventosSubscription?.cancel(); // Importante: limpiar memoria
    return super.close();
  }
}

