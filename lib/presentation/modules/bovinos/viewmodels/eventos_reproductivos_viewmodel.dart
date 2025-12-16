import 'package:flutter/foundation.dart';
import '../../../../core/utils/result.dart' show Result, Success, Error;
import '../../../../core/errors/failures.dart';
import '../../../../domain/entities/bovinos/evento_reproductivo.dart';
import '../../../../domain/usecases/bovinos/create_evento_reproductivo.dart';
import '../../../../domain/usecases/bovinos/registrar_parto_con_cria.dart';
import '../../base/base_viewmodel.dart';

/// ViewModel para gestión de Eventos Reproductivos
class EventosReproductivosViewModel extends BaseViewModel {
  final CreateEventoReproductivo createEvento;
  final RegistrarPartoConCria? registrarPartoConCria; // Opcional: sistema legacy eliminado

  EventosReproductivosViewModel({
    required this.createEvento,
    this.registrarPartoConCria, // Opcional
  });

  // Estado
  List<EventoReproductivo> _eventos = [];
  EventoReproductivo? _selectedEvento;

  // Getters
  List<EventoReproductivo> get eventos => _eventos;
  EventoReproductivo? get selectedEvento => _selectedEvento;

  /// Crea un nuevo evento reproductivo
  Future<bool> createEventoReproductivo(EventoReproductivo evento) async {
    setLoading(true);
    clearError();

    final result = await createEvento(evento);

    return switch (result) {
      Success<EventoReproductivo>(:final data) => () {
        _eventos.add(data);
        _eventos.sort((a, b) => b.fecha.compareTo(a.fecha));
        setLoading(false);
        return true;
      }(),
      Error<EventoReproductivo>(:final failure) => () {
        setError(getErrorMessage(failure));
        setLoading(false);
        return false;
      }(),
    };
  }

  /// Registra un parto y opcionalmente crea la cría
  Future<Map<String, dynamic>?> registrarParto({
    required EventoReproductivo eventoParto,
    required bool crearCria,
    Map<String, dynamic>? datosCria,
  }) async {
    setLoading(true);
    clearError();

    // Si registrarPartoConCria no está disponible, solo registrar el evento
    if (registrarPartoConCria == null) {
      final eventoResult = await createEvento(eventoParto);
      return switch (eventoResult) {
        Success<EventoReproductivo>(:final data) => () {
          _eventos.add(data);
          _eventos.sort((a, b) => b.fecha.compareTo(a.fecha));
          setLoading(false);
          return {'evento': data, 'cria': null};
        }(),
        Error<EventoReproductivo>(:final failure) => () {
          setError(getErrorMessage(failure));
          setLoading(false);
          return null;
        }(),
      };
    }

    final result = await registrarPartoConCria!(
      eventoParto: eventoParto,
      crearCria: crearCria,
      datosCria: datosCria,
    );

    return switch (result) {
      Success<Map<String, dynamic>>(:final data) => () {
        _eventos.add(data['evento'] as EventoReproductivo);
        _eventos.sort((a, b) => b.fecha.compareTo(a.fecha));
        setLoading(false);
        return data;
      }(),
      Error<Map<String, dynamic>>(:final failure) => () {
        setError(getErrorMessage(failure));
        setLoading(false);
        return null;
      }(),
    };
  }

  /// Limpia la lista y el estado
  void clearList() {
    _eventos = [];
    _selectedEvento = null;
    clearState();
  }
}

