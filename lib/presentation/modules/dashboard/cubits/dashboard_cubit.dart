import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/bovinos/bovino.dart' as old;
import '../../../../domain/entities/porcinos/cerdo.dart';
import '../../../../domain/entities/ovinos/oveja.dart';
import '../../../../domain/entities/avicultura/gallina.dart';
import '../../../../domain/entities/trabajadores/trabajador.dart';
import '../../../../domain/usecases/bovinos/get_bovinos_stream.dart';
import '../../../../domain/usecases/porcinos/get_cerdos_stream.dart';
import '../../../../domain/usecases/ovinos/get_ovejas_stream.dart';
import '../../../../domain/usecases/avicultura/get_gallinas_stream.dart';
import '../../../../domain/usecases/trabajadores/get_trabajadores_stream.dart';
import '../../../../features/cattle/domain/entities/bovine_entity.dart';
import '../../../../features/cattle/domain/repositories/cattle_repository.dart';
import 'dashboard_state.dart';
import '../models/dashboard_alert.dart';

/// Cubit para manejar el estado del Dashboard
class DashboardCubit extends Cubit<DashboardState> {
  final String farmId; // ID de la finca actual
  final GetBovinosStream getBovinosStream;
  final GetCerdosStream getCerdosStream;
  final GetOvejasStream getOvejasStream;
  final GetGallinasStream getGallinasStream;
  final GetTrabajadoresStream getTrabajadoresStream;
  final CattleRepository cattleRepository; // Para obtener bovinos del nuevo sistema

  // Stream subscriptions
  StreamSubscription<List<old.Bovino>>? _bovinosSubscription;
  StreamSubscription<List<Cerdo>>? _cerdosSubscription;
  StreamSubscription<List<Oveja>>? _ovejasSubscription;
  StreamSubscription<List<Gallina>>? _gallinasSubscription;
  StreamSubscription<List<Trabajador>>? _trabajadoresSubscription;
  StreamSubscription<List<BovineEntity>>? _cattleSubscription; // Para el nuevo sistema

  // Datos actuales
  List<old.Bovino> _bovinos = [];
  List<Cerdo> _cerdos = [];
  List<Oveja> _ovejas = [];
  List<Gallina> _gallinas = [];
  List<Trabajador> _trabajadores = [];
  List<BovineEntity> _cattle = []; // Bovinos del nuevo sistema

  DashboardCubit({
    required this.farmId,
    required this.getBovinosStream,
    required this.getCerdosStream,
    required this.getOvejasStream,
    required this.getGallinasStream,
    required this.getTrabajadoresStream,
    required this.cattleRepository,
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

    // Suscribirse al stream de bovinos del nuevo sistema (Clean Architecture)
    _cattleSubscription = cattleRepository.getCattleListStream(farmId).listen(
      (cattle) {
        _cattle = cattle;
        _recalculateState();
      },
      onError: (error) {
        emit(DashboardError('Error al cargar ganado: $error'));
      },
    );
  }

  /// Recalcula el estado completo del dashboard
  void _recalculateState() {
    // Calcular totales (usando ambos sistemas: viejo y nuevo)
    final totalBovinos = _bovinos.length + _cattle.length;
    final totalCerdos = _cerdos.length;
    final totalOvejas = _ovejas.length;
    final totalGallinas = _gallinas.length;
    final totalTrabajadores = _trabajadores.where((t) => t.isActive).length;

    // Generar alertas inteligentes
    final alerts = <DashboardAlert>[];

    // ============================================
    // ALERTAS DE BOVINOS (SISTEMA VIEJO)
    // ============================================
    // Alertas de Bovinos: Secado de vacas gestantes
    for (final bovino in _bovinos) {
      if (bovino.gender == old.BovinoGender.female &&
          bovino.breedingStatus == old.BreedingStatus.prenada &&
          bovino.expectedCalvingDate != null) {
        final now = DateTime.now();
        final fechaSecado = bovino.expectedCalvingDate!
            .subtract(const Duration(days: 60));
        final diasHastaSecado = fechaSecado.difference(now).inDays;

        // Si faltan menos de 7 días para el secado ideal (67 días antes del parto)
        if (diasHastaSecado >= 0 && diasHastaSecado < 7) {
          final nombre = bovino.name ?? bovino.identification ?? 'Sin nombre';
          alerts.add(DashboardAlert(
            title: 'Secado Pendiente',
            message: 'Vaca $nombre debe ser secada en $diasHastaSecado días',
            type: AlertType.warning,
            route: '/bovinos/detalle',
            routeArguments: {'bovinoId': bovino.id},
          ));
        }
      }
    }

    // ============================================
    // ALERTAS DE BOVINOS (SISTEMA NUEVO - CLEAN ARCHITECTURE)
    // ============================================
    for (final bovine in _cattle) {
      // ALERTA CRÍTICA: Bajo Peso en Bovinos Activos
      // Si el bovino está activo y tiene peso menor a 180kg -> Alerta crítica
      if (bovine.status == BovineStatus.active && bovine.weight != null && bovine.weight! < 180.0) {
        alerts.add(DashboardAlert(
          title: 'Bajo Peso Crítico',
          message: '${bovine.identifier} (${bovine.name ?? 'Sin nombre'}) tiene solo ${bovine.weight?.toStringAsFixed(1)}kg',
          type: AlertType.critical,
          route: '/cattle/detail',
          routeArguments: {'bovineId': bovine.id},
        ));
      }

      // ALERTA DE ADVERTENCIA: Peso bajo pero no crítico (entre 180kg y 250kg)
      if (bovine.status == BovineStatus.active && 
          bovine.weight != null && 
          bovine.weight! >= 180.0 && 
          bovine.weight! < 250.0) {
        alerts.add(DashboardAlert(
          title: 'Monitorear Peso',
          message: '${bovine.identifier} tiene ${bovine.weight?.toStringAsFixed(1)}kg. Considere mejorar alimentación',
          type: AlertType.warning,
          route: '/cattle/detail',
          routeArguments: {'bovineId': bovine.id},
        ));
      }

      // ALERTA INFORMATIVA: Bovinos próximos a edad de venta (> 2 años y > 400kg)
      if (bovine.status == BovineStatus.active && 
          bovine.age >= 2 && 
          bovine.weight != null && 
          bovine.weight! >= 400.0) {
        alerts.add(DashboardAlert(
          title: 'Listo para Venta',
          message: '${bovine.identifier} tiene ${bovine.age} años y ${bovine.weight?.toStringAsFixed(1)}kg',
          type: AlertType.info,
          route: '/cattle/detail',
          routeArguments: {'bovineId': bovine.id},
        ));
      }
    }

    // ============================================
    // ALERTAS GENERALES
    // ============================================
    
    // Si no hay animales en la finca
    if (totalBovinos == 0 && totalCerdos == 0 && totalOvejas == 0 && totalGallinas == 0) {
      alerts.add(const DashboardAlert(
        title: 'Finca Sin Animales',
        message: 'No hay animales registrados. Comience agregando su ganado.',
        type: AlertType.info,
      ));
    }

    // Si no hay trabajadores activos
    if (totalTrabajadores == 0) {
      alerts.add(const DashboardAlert(
        title: 'Sin Trabajadores',
        message: 'No hay trabajadores activos registrados en la finca.',
        type: AlertType.warning,
      ));
    }

    // Emitir el nuevo estado
    emit(DashboardLoaded(
      totalBovinos: totalBovinos,
      totalCerdos: totalCerdos,
      totalOvejas: totalOvejas,
      totalGallinas: totalGallinas,
      totalTrabajadores: totalTrabajadores,
      alerts: alerts,
    ));
  }

  @override
  Future<void> close() {
    _bovinosSubscription?.cancel();
    _cerdosSubscription?.cancel();
    _ovejasSubscription?.cancel();
    _gallinasSubscription?.cancel();
    _trabajadoresSubscription?.cancel();
    _cattleSubscription?.cancel();
    return super.close();
  }
}

