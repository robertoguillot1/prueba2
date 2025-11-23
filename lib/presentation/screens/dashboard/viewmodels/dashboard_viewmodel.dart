import 'package:flutter/foundation.dart';
import '../../../../core/utils/result.dart';
import '../../../../domain/entities/bovinos/bovino.dart';
import '../../../../domain/entities/porcinos/cerdo.dart';
import '../../../../domain/entities/ovinos/oveja.dart';
import '../../../../domain/entities/avicultura/gallina.dart';
import '../../../../domain/entities/trabajadores/trabajador.dart';
import '../../../../domain/usecases/bovinos/get_all_bovinos.dart';
import '../../../../domain/usecases/porcinos/get_all_cerdos.dart';
import '../../../../domain/usecases/ovinos/get_all_ovejas.dart';
import '../../../../domain/usecases/avicultura/get_all_gallinas.dart';
import '../../../../domain/usecases/trabajadores/get_all_trabajadores.dart';
import '../../../modules/base/base_viewmodel.dart';
import '../models/dashboard_alert.dart';
import '../models/inventory_summary.dart';

/// ViewModel para el Dashboard Operativo
class DashboardViewModel extends BaseViewModel {
  final GetAllBovinos getAllBovinos;
  final GetAllCerdos getAllCerdos;
  final GetAllOvejas getAllOvejas;
  final GetAllGallinas getAllGallinas;
  final GetAllTrabajadores getAllTrabajadores;

  DashboardViewModel({
    required this.getAllBovinos,
    required this.getAllCerdos,
    required this.getAllOvejas,
    required this.getAllGallinas,
    required this.getAllTrabajadores,
  });

  // Estado
  List<Bovino> _bovinos = [];
  List<Cerdo> _cerdos = [];
  List<Oveja> _ovejas = [];
  List<Gallina> _gallinas = [];
  List<Trabajador> _trabajadores = [];
  List<DashboardAlert> _alerts = [];
  InventorySummary? _summary;

  // Getters
  List<Bovino> get bovinos => _bovinos;
  List<Cerdo> get cerdos => _cerdos;
  List<Oveja> get ovejas => _ovejas;
  List<Gallina> get gallinas => _gallinas;
  List<Trabajador> get trabajadores => _trabajadores;
  List<DashboardAlert> get alerts => _alerts;
  InventorySummary? get summary => _summary;

  /// Carga todos los datos del dashboard
  Future<void> loadDashboardData(String farmId) async {
    setLoading(true);
    clearError();

    try {
      // Cargar todos los datos en paralelo
      final results = await Future.wait([
        getAllBovinos(farmId),
        getAllCerdos(farmId),
        getAllOvejas(farmId),
        getAllGallinas(farmId),
        getAllTrabajadores(farmId),
      ]);

      // Procesar resultados
      final bovinosResult = results[0] as Result<List<Bovino>>;
      switch (bovinosResult) {
        case Success<List<Bovino>>(:final data):
          _bovinos = data;
        case Error<List<Bovino>>(:final failure):
          setError('Error al cargar bovinos: ${failure.message}');
      }

      final cerdosResult = results[1] as Result<List<Cerdo>>;
      switch (cerdosResult) {
        case Success<List<Cerdo>>(:final data):
          _cerdos = data;
        case Error<List<Cerdo>>():
          // Continuar aunque falle
          break;
      }

      final ovejasResult = results[2] as Result<List<Oveja>>;
      switch (ovejasResult) {
        case Success<List<Oveja>>(:final data):
          _ovejas = data;
        case Error<List<Oveja>>():
          break;
      }

      final gallinasResult = results[3] as Result<List<Gallina>>;
      switch (gallinasResult) {
        case Success<List<Gallina>>(:final data):
          _gallinas = data;
        case Error<List<Gallina>>():
          break;
      }

      final trabajadoresResult = results[4] as Result<List<Trabajador>>;
      switch (trabajadoresResult) {
        case Success<List<Trabajador>>(:final data):
          _trabajadores = data;
        case Error<List<Trabajador>>():
          break;
      }

      // Calcular resumen y alertas
      _calculateSummary();
      _calculateAlerts();

      setLoading(false);
    } catch (e) {
      setError('Error al cargar datos del dashboard: $e');
      setLoading(false);
    }
  }

  /// Calcula el resumen de inventario
  void _calculateSummary() {
    final vacasEnOrdeno = _bovinos.where((b) =>
      b.category == BovinoCategory.vaca &&
      b.productionStage == ProductionStage.produccion &&
      b.gender == BovinoGender.female
    ).length;

    final trabajadoresActivos = _trabajadores.where((t) => t.isActive).length;

    _summary = InventorySummary(
      totalBovinos: _bovinos.length,
      vacasEnOrdeno: vacasEnOrdeno,
      totalCerdos: _cerdos.length,
      totalAves: _gallinas.length,
      totalOvinos: _ovejas.length,
      trabajadoresActivos: trabajadoresActivos,
    );
  }

  /// Calcula las alertas dinámicas
  void _calculateAlerts() {
    _alerts = [];

    final now = DateTime.now();
    final sieteDias = now.add(const Duration(days: 7));
    final hoy = DateTime(now.year, now.month, now.day);
    final manana = hoy.add(const Duration(days: 1));

    // Alertas de Bovinos
    for (final bovino in _bovinos) {
      // Partos probables esta semana
      if (bovino.expectedCalvingDate != null) {
        final fechaParto = bovino.expectedCalvingDate!;
        final diasRestantes = fechaParto.difference(now).inDays;
        
        if (diasRestantes >= 0 && diasRestantes <= 7) {
          _alerts.add(DashboardAlert(
            tipo: AlertType.partoBovino,
            titulo: 'Parto próximo',
            mensaje: '${bovino.name ?? bovino.identification} tiene parto estimado en $diasRestantes días',
            severidad: diasRestantes <= 3 ? AlertSeverity.critica : AlertSeverity.media,
            fecha: fechaParto,
          ));
        }
      }

      // Secado (si hay fecha de secado calculada)
      // Nota: Necesitaríamos agregar fechaSecado a la entidad Bovino si no existe
      // Por ahora, usamos expectedCalvingDate - 60 días como aproximación
      if (bovino.expectedCalvingDate != null && 
          bovino.productionStage == ProductionStage.produccion) {
        final fechaSecado = bovino.expectedCalvingDate!.subtract(const Duration(days: 60));
        final diasHastaSecado = fechaSecado.difference(now).inDays;
        
        if (diasHastaSecado >= 0 && diasHastaSecado <= 7) {
          _alerts.add(DashboardAlert(
            tipo: AlertType.secadoBovino,
            titulo: 'Secado próximo',
            mensaje: '${bovino.name ?? bovino.identification} debe secarse en $diasHastaSecado días',
            severidad: diasHastaSecado <= 3 ? AlertSeverity.critica : AlertSeverity.media,
            fecha: fechaSecado,
          ));
        }
      }
    }

    // Alertas de Ovinos/Cerdos - Partos estimados
    for (final oveja in _ovejas) {
      if (oveja.fechaProbableParto != null) {
        final fechaParto = DateTime(
          oveja.fechaProbableParto!.year,
          oveja.fechaProbableParto!.month,
          oveja.fechaProbableParto!.day,
        );
        
        if (fechaParto == hoy || fechaParto == manana) {
          _alerts.add(DashboardAlert(
            tipo: AlertType.partoOvino,
            titulo: 'Parto hoy/manana',
            mensaje: '${oveja.name ?? oveja.identification} tiene parto estimado ${fechaParto == hoy ? "hoy" : "manana"}',
            severidad: AlertSeverity.critica,
            fecha: fechaParto,
          ));
        }
      }
    }

    // Alertas de Trabajadores - Contratos próximos a vencer
    for (final trabajador in _trabajadores) {
      if (trabajador.isActive && trabajador.workerType == WorkerType.porLabor) {
        // Para trabajadores por labor, verificar si hay fecha de fin de contrato
        // Por ahora, asumimos que si no hay fecha de fin, el contrato es indefinido
        // Esto requeriría agregar un campo fechaFinContrato a la entidad Trabajador
      }
    }

    // Ordenar alertas por severidad y fecha
    _alerts.sort((a, b) {
      if (a.severidad != b.severidad) {
        return a.severidad.index.compareTo(b.severidad.index);
      }
      return a.fecha.compareTo(b.fecha);
    });
  }

  /// Refresca los datos del dashboard
  Future<void> refresh(String farmId) async {
    await loadDashboardData(farmId);
  }
}

