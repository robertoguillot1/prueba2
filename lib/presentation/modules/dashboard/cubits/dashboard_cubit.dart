import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/bovinos/bovino.dart';
import '../../../../domain/entities/porcinos/cerdo.dart';
import '../../../../domain/entities/ovinos/oveja.dart';
import '../../../../domain/entities/avicultura/gallina.dart';
import '../../../../domain/entities/trabajadores/trabajador.dart';
import '../../../../domain/usecases/bovinos/get_bovinos_stream.dart';
import '../../../../domain/usecases/porcinos/get_cerdos_stream.dart';
import '../../../../domain/usecases/ovinos/get_ovejas_stream.dart';
import '../../../../domain/usecases/avicultura/get_gallinas_stream.dart';
import '../../../../domain/usecases/trabajadores/get_trabajadores_stream.dart';
import 'dashboard_state.dart';

/// Cubit para manejar el estado del Dashboard
class DashboardCubit extends Cubit<DashboardState> {
  final GetBovinosStream getBovinosStream;
  final GetCerdosStream getCerdosStream;
  final GetOvejasStream getOvejasStream;
  final GetGallinasStream getGallinasStream;
  final GetTrabajadoresStream getTrabajadoresStream;

  // Stream subscriptions
  StreamSubscription<List<Bovino>>? _bovinosSubscription;
  StreamSubscription<List<Cerdo>>? _cerdosSubscription;
  StreamSubscription<List<Oveja>>? _ovejasSubscription;
  StreamSubscription<List<Gallina>>? _gallinasSubscription;
  StreamSubscription<List<Trabajador>>? _trabajadoresSubscription;

  // Datos actuales
  List<Bovino> _bovinos = [];
  List<Cerdo> _cerdos = [];
  List<Oveja> _ovejas = [];
  List<Gallina> _gallinas = [];
  List<Trabajador> _trabajadores = [];

  DashboardCubit({
    required this.getBovinosStream,
    required this.getCerdosStream,
    required this.getOvejasStream,
    required this.getGallinasStream,
    required this.getTrabajadoresStream,
  }) : super(DashboardInitial());

  /// Inicia la carga de datos del dashboard
  void loadDashboardData() {
    emit(DashboardLoading());

    // Suscribirse a todos los streams
    _bovinosSubscription = getBovinosStream().listen(
      (bovinos) {
        _bovinos = bovinos;
        _recalculateState();
      },
      onError: (error) {
        emit(DashboardError('Error al cargar bovinos: $error'));
      },
    );

    _cerdosSubscription = getCerdosStream().listen(
      (cerdos) {
        _cerdos = cerdos;
        _recalculateState();
      },
      onError: (error) {
        emit(DashboardError('Error al cargar cerdos: $error'));
      },
    );

    _ovejasSubscription = getOvejasStream().listen(
      (ovejas) {
        _ovejas = ovejas;
        _recalculateState();
      },
      onError: (error) {
        emit(DashboardError('Error al cargar ovejas: $error'));
      },
    );

    _gallinasSubscription = getGallinasStream().listen(
      (gallinas) {
        _gallinas = gallinas;
        _recalculateState();
      },
      onError: (error) {
        emit(DashboardError('Error al cargar gallinas: $error'));
      },
    );

    _trabajadoresSubscription = getTrabajadoresStream().listen(
      (trabajadores) {
        _trabajadores = trabajadores;
        _recalculateState();
      },
      onError: (error) {
        emit(DashboardError('Error al cargar trabajadores: $error'));
      },
    );
  }

  /// Recalcula el estado completo del dashboard
  void _recalculateState() {
    // Calcular totales
    final totalBovinos = _bovinos.length;
    final totalCerdos = _cerdos.length;
    final totalOvejas = _ovejas.length;
    final totalGallinas = _gallinas.length;
    final totalTrabajadores = _trabajadores.where((t) => t.isActive).length;

    // Generar alertas
    final alertas = <String>[];

    // Alertas de Bovinos: Secado de vacas gestantes
    for (final bovino in _bovinos) {
      if (bovino.gender == BovinoGender.female &&
          bovino.breedingStatus == BreedingStatus.prenada &&
          bovino.expectedCalvingDate != null) {
        final now = DateTime.now();
        final fechaSecado = bovino.expectedCalvingDate!
            .subtract(const Duration(days: 60));
        final diasHastaSecado = fechaSecado.difference(now).inDays;

        // Si faltan menos de 7 días para el secado ideal (67 días antes del parto)
        if (diasHastaSecado >= 0 && diasHastaSecado < 7) {
          final nombre = bovino.name ?? bovino.identification ?? 'Sin nombre';
          alertas.add('Secar Vaca $nombre (${diasHastaSecado} días restantes)');
        }
      }
    }

    // Alertas de Avicultura: Stock bajo de alimento
    // Nota: Por ahora usamos gallinas, pero en el futuro podríamos tener lotes
    // Si hay lotes con stockAlimento < 50kg, agregar alerta
    // Por ahora, omitimos esta alerta hasta tener repositorio de lotes

    // Alertas de Trabajadores: Contratos próximos a vencer
    // Nota: La entidad Trabajador no tiene fecha de fin de contrato
    // Por ahora, omitimos esta alerta

    // Emitir el nuevo estado
    emit(DashboardLoaded(
      totalBovinos: totalBovinos,
      totalCerdos: totalCerdos,
      totalOvejas: totalOvejas,
      totalGallinas: totalGallinas,
      totalTrabajadores: totalTrabajadores,
      alertas: alertas,
    ));
  }

  @override
  Future<void> close() {
    _bovinosSubscription?.cancel();
    _cerdosSubscription?.cancel();
    _ovejasSubscription?.cancel();
    _gallinasSubscription?.cancel();
    _trabajadoresSubscription?.cancel();
    return super.close();
  }
}

