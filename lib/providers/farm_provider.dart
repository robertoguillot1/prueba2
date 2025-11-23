import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/logger.dart';
import '../models/farm.dart';
import '../models/worker.dart';
import '../models/payment.dart';
import '../models/loan.dart';
import '../models/expense.dart';
import '../models/pig.dart';
import '../models/food_purchase.dart';
import '../models/weight_record.dart';
import '../models/feeding_alert.dart';
import '../models/cattle.dart';
import '../models/cattle_vaccine.dart';
import '../models/cattle_weight_record.dart';
import '../models/cattle_transfer.dart';
import '../models/cattle_trip.dart';
import '../models/milk_production.dart';
import '../models/reproduction_event.dart';
import '../models/module_item.dart';
import '../models/goat_sheep.dart';
import '../models/pig_vaccine.dart';
import '../models/goat_sheep_vaccine.dart';
import '../models/broiler_batch.dart';
import '../models/layer_batch.dart';
import '../models/layer_production_record.dart';
import '../models/batch_expense.dart';
import '../models/batch_sale.dart';
// Temporalmente desactivado: import '../services/firestore_service.dart';

class FarmProvider with ChangeNotifier {
  List<Farm> _farms = [];
  Farm? _currentFarm;
  bool _isLoading = false;
  String? _userId;
  // Temporalmente desactivado: final FirestoreService _firestoreService = FirestoreService();
  // Temporalmente desactivado: StreamSubscription<List<Farm>>? _farmsSubscription;
  // Temporalmente desactivado: StreamSubscription<String?>? _currentFarmIdSubscription;
  
  // Métodos para obtener claves específicas por usuario
  String _getFarmsKey() => _userId != null ? 'farms_data_$_userId' : 'farms_data';
  String _getCurrentFarmKey() => _userId != null ? 'current_farm_id_$_userId' : 'current_farm_id';
  String _getModulesOrderKey() => _userId != null ? 'modules_order_$_userId' : 'modules_order';

  List<Farm> get farms => _farms;
  Farm? get currentFarm => _currentFarm;
  bool get isLoading => _isLoading;
  String? get userId => _userId;


  // Actualizar userId y recargar datos
  Future<void> setUserId(String? userId) async {
    if (_userId != userId) {
      // Temporalmente desactivado: Cancelar suscripciones anteriores
      // await _farmsSubscription?.cancel();
      // await _currentFarmIdSubscription?.cancel();
      
      _userId = userId;
      // Limpiar datos actuales antes de cargar nuevos
      _farms = [];
      _currentFarm = null;
      
      if (userId != null) {
        await loadFarms();
        // Temporalmente desactivado: _setupListeners();
      }
    }
  }

  // Temporalmente desactivado: Configurar listeners para actualizaciones en tiempo real
  // void _setupListeners() {
  //   if (_userId == null) return;
  //   ...
  // }

  @override
  void dispose() {
    // Temporalmente desactivado: _farmsSubscription?.cancel();
    // Temporalmente desactivado: _currentFarmIdSubscription?.cancel();
    super.dispose();
  }

  // Load all farms from SharedPreferences (Firestore temporalmente desactivado)
  Future<void> loadFarms() async {
    if (_userId == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final farmsJson = prefs.getString(_getFarmsKey());
      
      if (farmsJson != null) {
        final List<dynamic> farmsList = json.decode(farmsJson);
        _farms = farmsList.map((farmJson) => Farm.fromJson(farmJson)).toList();
      } else {
        _farms = [];
      }

      // Load current farm
      final currentFarmId = prefs.getString(_getCurrentFarmKey());
      if (currentFarmId != null && _farms.isNotEmpty) {
        try {
          _currentFarm = _farms.firstWhere((farm) => farm.id == currentFarmId);
        } catch (e) {
          _currentFarm = _farms.isNotEmpty ? _farms.first : null;
        }
      } else {
        _currentFarm = _farms.isNotEmpty ? _farms.first : null;
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error loading farms', e, stackTrace);
      _farms = [];
      _currentFarm = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Save all farms to SharedPreferences (Firestore temporalmente desactivado)
  Future<void> _saveFarms() async {
    if (_userId == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final farmsJson = json.encode(_farms.map((farm) => farm.toJson()).toList());
      await prefs.setString(_getFarmsKey(), farmsJson);
    } catch (e, stackTrace) {
      AppLogger.error('Error saving farms', e, stackTrace);
    }
  }

  // Add new farm
  Future<void> addFarm(Farm farm) async {
    if (_userId == null) {
      throw Exception('Usuario no autenticado');
    }
    // Ensure the farm has empty lists for workers, payments, loans, and expenses
    final newFarm = Farm(
      id: farm.id,
      name: farm.name,
      location: farm.location,
      description: farm.description,
      imageUrl: farm.imageUrl,
      createdAt: farm.createdAt,
      primaryColor: farm.primaryColor,
      workers: [], // Ensure empty list
      payments: [], // Ensure empty list
      loans: [], // Ensure empty list
      expenses: [], // Ensure empty list
      pigs: [], // Ensure empty list
      foodPurchases: [], // Ensure empty list
      weightRecords: [], // Ensure empty list
      feedingAlerts: [], // Ensure empty list
      cattle: [], // Ensure empty list
      cattleVaccines: [], // Ensure empty list
      cattleWeightRecords: [], // Ensure empty list
      cattleTransfers: [], // Ensure empty list
      cattleTrips: [], // Ensure empty list
      milkProductionRecords: [], // Ensure empty list
      reproductionEvents: [], // Ensure empty list
    );
    
    _farms.add(newFarm);
    await _saveFarms();
    
    // Set as current farm if it's the first one
    if (_farms.length == 1) {
      await setCurrentFarm(newFarm.id);
    }
    
    notifyListeners();
  }

  // Update farm
  Future<void> updateFarm(Farm farm) async {
    try {
      if (_userId == null) {
        AppLogger.error('Error updating farm: User ID is null', 
            Exception('Cannot update farm without user ID'), StackTrace.current);
        throw Exception('No se puede actualizar la finca. Por favor, inicia sesión nuevamente.');
      }
      
      final index = _farms.indexWhere((f) => f.id == farm.id);
      if (index == -1) {
        AppLogger.error('Error updating farm: Farm not found', 
            Exception('Farm with id ${farm.id} not found'), StackTrace.current);
        throw Exception('No se encontró la finca para actualizar. ID: ${farm.id}');
      }
      
      // Actualizar la finca en la lista
      _farms[index] = farm;
      
      // Guardar
      await _saveFarms();
      
      // Actualizar la finca actual si es la misma
      if (_currentFarm?.id == farm.id) {
        _currentFarm = farm;
      }
      
      // Notificar listeners de forma síncrona DESPUÉS de guardar
      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.error('Error updating farm', e, stackTrace);
      rethrow;
    }
  }

  // Delete farm
  Future<void> deleteFarm(String farmId) async {
    if (_userId == null) return;
    
    _farms.removeWhere((farm) => farm.id == farmId);
    await _saveFarms();
    
    if (_currentFarm?.id == farmId) {
      _currentFarm = _farms.isNotEmpty ? _farms.first : null;
      if (_currentFarm != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_getCurrentFarmKey(), _currentFarm!.id);
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_getCurrentFarmKey());
      }
    }
    
    notifyListeners();
  }

  // Set current farm
  Future<void> setCurrentFarm(String farmId) async {
    if (_userId == null) return;
    
    try {
      _currentFarm = _farms.firstWhere((farm) => farm.id == farmId);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_getCurrentFarmKey(), farmId);
      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.error('Error setting current farm', e, stackTrace);
    }
  }

  // Clear all data (for debugging)
  Future<void> clearAllData() async {
    if (_userId == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_getFarmsKey());
      await prefs.remove(_getCurrentFarmKey());
      await prefs.remove(_getModulesOrderKey());
      _farms.clear();
      _currentFarm = null;
      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.error('Error clearing data', e, stackTrace);
    }
  }

  // Worker management
  Future<void> addWorker(Worker worker, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    final updatedWorkers = List<Worker>.from(farm.workers);
    updatedWorkers.add(worker);
    
    final updatedFarm = farm.copyWith(workers: updatedWorkers);
    await updateFarm(updatedFarm);
  }

  Future<void> updateWorker(Worker worker, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    final updatedWorkers = List<Worker>.from(farm.workers);
    final index = updatedWorkers.indexWhere((w) => w.id == worker.id);
    
    if (index != -1) {
      updatedWorkers[index] = worker;
      final updatedFarm = farm.copyWith(workers: updatedWorkers);
      await updateFarm(updatedFarm);
    }
  }

  Future<void> deleteWorker(String workerId, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    final updatedWorkers = farm.workers.where((w) => w.id != workerId).toList();
    final updatedFarm = farm.copyWith(workers: updatedWorkers);
    await updateFarm(updatedFarm);
  }

  // Payment management
  Future<void> addPayment(Payment payment, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    final updatedPayments = List<Payment>.from(farm.payments);
    updatedPayments.add(payment);
    
    final updatedFarm = farm.copyWith(payments: updatedPayments);
    await updateFarm(updatedFarm);
  }

  Future<void> updatePayment(Payment payment, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    final updatedPayments = List<Payment>.from(farm.payments);
    final index = updatedPayments.indexWhere((p) => p.id == payment.id);
    
    if (index != -1) {
      updatedPayments[index] = payment;
      final updatedFarm = farm.copyWith(payments: updatedPayments);
      await updateFarm(updatedFarm);
    }
  }

  Future<void> deletePayment(String paymentId, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    final updatedPayments = farm.payments.where((p) => p.id != paymentId).toList();
    final updatedFarm = farm.copyWith(payments: updatedPayments);
    await updateFarm(updatedFarm);
  }

  // Loan management
  Future<void> addLoan(Loan loan, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    final updatedLoans = List<Loan>.from(farm.loans);
    updatedLoans.add(loan);
    
    final updatedFarm = farm.copyWith(loans: updatedLoans);
    await updateFarm(updatedFarm);
  }

  Future<void> updateLoan(Loan loan, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    final updatedLoans = List<Loan>.from(farm.loans);
    final index = updatedLoans.indexWhere((l) => l.id == loan.id);
    
    if (index != -1) {
      updatedLoans[index] = loan;
      final updatedFarm = farm.copyWith(loans: updatedLoans);
      await updateFarm(updatedFarm);
    }
  }

  Future<void> deleteLoan(String loanId, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    final updatedLoans = farm.loans.where((l) => l.id != loanId).toList();
    final updatedFarm = farm.copyWith(loans: updatedLoans);
    await updateFarm(updatedFarm);
  }

  // Expense management
  Future<void> addExpense(Expense expense, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    final updatedExpenses = List<Expense>.from(farm.expenses);
    updatedExpenses.add(expense);
    
    final updatedFarm = farm.copyWith(expenses: updatedExpenses);
    await updateFarm(updatedFarm);
  }

  Future<void> updateExpense(Expense expense, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    final updatedExpenses = List<Expense>.from(farm.expenses);
    final index = updatedExpenses.indexWhere((e) => e.id == expense.id);
    
    if (index != -1) {
      updatedExpenses[index] = expense;
      final updatedFarm = farm.copyWith(expenses: updatedExpenses);
      await updateFarm(updatedFarm);
    }
  }

  Future<void> deleteExpense(String expenseId, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    final updatedExpenses = farm.expenses.where((e) => e.id != expenseId).toList();
    final updatedFarm = farm.copyWith(expenses: updatedExpenses);
    await updateFarm(updatedFarm);
  }

  // Helper methods
  Worker? getWorkerById(String workerId, {String? farmId}) {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return null;
    
    try {
      final farm = _farms.firstWhere((f) => f.id == targetFarmId);
      return farm.workers.firstWhere((w) => w.id == workerId);
    } catch (e) {
      return null;
    }
  }

  List<Payment> getPaymentsByWorker(String workerId, {String? farmId}) {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return [];
    
    try {
      final farm = _farms.firstWhere((f) => f.id == targetFarmId);
      return farm.payments
          .where((p) => p.workerId == workerId)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      return [];
    }
  }

  List<Loan> getLoansByWorker(String workerId, {String? farmId}) {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return [];
    
    try {
      final farm = _farms.firstWhere((f) => f.id == targetFarmId);
      return farm.loans
          .where((l) => l.workerId == workerId)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      return [];
    }
  }

  double getWorkerTotalPaid(String workerId, {String? farmId}) {
    return getPaymentsByWorker(workerId, farmId: farmId)
        .fold(0.0, (sum, payment) => sum + payment.amount);
  }

  double getWorkerPendingLoans(String workerId, {String? farmId}) {
    return getLoansByWorker(workerId, farmId: farmId)
        .where((loan) => loan.status == LoanStatus.pending)
        .fold(0.0, (sum, loan) => sum + loan.amount);
  }

  double getWorkerNetSalary(String workerId, {String? farmId}) {
    final worker = getWorkerById(workerId, farmId: farmId);
    if (worker == null) return 0.0;
    
    // Salario neto = Salario del mes - Préstamos pendientes - Pagos ya realizados
    return worker.salary - getWorkerPendingLoans(workerId, farmId: farmId) - getWorkerTotalPaid(workerId, farmId: farmId);
  }

  // Search methods
  List<Worker> searchWorkers(String query) {
    if (_currentFarm == null) return [];
    
    if (query.isEmpty) return _currentFarm!.activeWorkers;
    
    return _currentFarm!.activeWorkers.where((worker) {
      return worker.fullName.toLowerCase().contains(query.toLowerCase()) ||
             (worker.identification.isNotEmpty && worker.identification.toLowerCase().contains(query.toLowerCase())) ||
             worker.position.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // ==================== PORCICULTURA MANAGEMENT ====================
  
  // Pig management
  Future<void> addPig(Pig pig, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    final updatedPigs = List<Pig>.from(farm.pigs);
    updatedPigs.add(pig);
    
    final updatedFarm = farm.copyWith(pigs: updatedPigs);
    await updateFarm(updatedFarm);
    
    // Verificar alertas de alimentación después de agregar cerdo
    await _checkFeedingAlerts(updatedFarm);
  }

  Future<void> updatePig(Pig pig, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    final updatedPigs = List<Pig>.from(farm.pigs);
    final index = updatedPigs.indexWhere((p) => p.id == pig.id);
    
    if (index != -1) {
      updatedPigs[index] = pig;
      final updatedFarm = farm.copyWith(pigs: updatedPigs);
      await updateFarm(updatedFarm);
      
      // Verificar alertas
      await _checkFeedingAlerts(updatedFarm);
    }
  }

  Future<void> deletePig(String pigId, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    final updatedPigs = farm.pigs.where((p) => p.id != pigId).toList();
    final updatedFarm = farm.copyWith(pigs: updatedPigs);
    await updateFarm(updatedFarm);
    
    // Eliminar registros de peso asociados
    final updatedRecords = farm.weightRecords.where((r) => r.pigId != pigId).toList();
    await updateFarm(updatedFarm.copyWith(weightRecords: updatedRecords));
    
    // Verificar alertas
    _checkFeedingAlerts(updatedFarm);
  }

  // Food Purchase management
  Future<void> addFoodPurchase(FoodPurchase purchase, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    final updatedPurchases = List<FoodPurchase>.from(farm.foodPurchases);
    updatedPurchases.add(purchase);
    
    final updatedFarm = farm.copyWith(foodPurchases: updatedPurchases);
    await updateFarm(updatedFarm);
    
    // Verificar alertas
    _checkFeedingAlerts(updatedFarm);
  }

  Future<void> deleteFoodPurchase(String purchaseId, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    final updatedPurchases = farm.foodPurchases.where((p) => p.id != purchaseId).toList();
    final updatedFarm = farm.copyWith(foodPurchases: updatedPurchases);
    await updateFarm(updatedFarm);
    
    // Verificar alertas
    _checkFeedingAlerts(updatedFarm);
  }

  // Weight Record management
  Future<void> addWeightRecord(WeightRecord record, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    final updatedRecords = List<WeightRecord>.from(farm.weightRecords);
    updatedRecords.add(record);
    
    final updatedFarm = farm.copyWith(weightRecords: updatedRecords);
    await updateFarm(updatedFarm);
  }

  Future<void> updateWeightRecord(WeightRecord record, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    final updatedRecords = List<WeightRecord>.from(farm.weightRecords);
    final index = updatedRecords.indexWhere((r) => r.id == record.id);
    
    if (index != -1) {
      updatedRecords[index] = record;
      final updatedFarm = farm.copyWith(weightRecords: updatedRecords);
      await updateFarm(updatedFarm);
    }
  }

  Future<void> deleteWeightRecord(String recordId, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    final updatedRecords = farm.weightRecords.where((r) => r.id != recordId).toList();
    final updatedFarm = farm.copyWith(weightRecords: updatedRecords);
    await updateFarm(updatedFarm);
  }

  // Feeding Alert management
  Future<void> markAlertAsRead(String alertId, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    final updatedAlerts = farm.feedingAlerts.map((alert) {
      if (alert.id == alertId) {
        return FeedingAlert(
          id: alert.id,
          farmId: alert.farmId,
          pigId: alert.pigId,
          alertDate: alert.alertDate,
          message: alert.message,
          level: alert.level,
          createdAt: alert.createdAt,
          isRead: true,
        );
      }
      return alert;
    }).toList();
    
    final updatedFarm = farm.copyWith(feedingAlerts: updatedAlerts);
    await updateFarm(updatedFarm);
  }

  // Verificar y generar alertas de alimentación
  Future<void> _checkFeedingAlerts(Farm farm) async {
    final newAlerts = <FeedingAlert>[];
    final daysLeft = farm.daysUntilFoodRunsOut;
    
    if (daysLeft != null && daysLeft < 10) {
      FeedingAlert alert;
      final now = DateTime.now();
      if (daysLeft <= 2) {
        alert = FeedingAlert(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          farmId: farm.id,
          pigId: null,
          alertDate: now,
          message: '⚠️ Alerta crítica: El alimento se acabará en ${daysLeft.toStringAsFixed(1)} días',
          level: AlertLevel.critical,
        );
      } else if (daysLeft <= 5) {
        alert = FeedingAlert(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          farmId: farm.id,
          pigId: null,
          alertDate: now,
          message: '⚠️ Advertencia: El alimento se acabará en ${daysLeft.toStringAsFixed(1)} días',
          level: AlertLevel.warning,
        );
      } else {
        alert = FeedingAlert(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          farmId: farm.id,
          pigId: null,
          alertDate: now,
          message: 'El alimento durará ${daysLeft.toStringAsFixed(1)} días más',
          level: AlertLevel.low,
        );
      }
      newAlerts.add(alert);
    }
    
    // Agregar alertas si es necesario
    if (newAlerts.isNotEmpty) {
      final updatedAlerts = List<FeedingAlert>.from(farm.feedingAlerts);
      updatedAlerts.addAll(newAlerts);
      
      final updatedFarm = farm.copyWith(feedingAlerts: updatedAlerts);
      // No llamar updateFarm aquí para evitar recursión
      final index = _farms.indexWhere((f) => f.id == updatedFarm.id);
      if (index != -1) {
        _farms[index] = updatedFarm;
        if (_currentFarm?.id == updatedFarm.id) {
          _currentFarm = updatedFarm;
        }
        await _saveFarms();
        notifyListeners();
      }
    }
  }

  // Helper methods for pigs
  List<WeightRecord> getWeightRecordsForPig(String pigId, {String? farmId}) {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return [];
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    return farm.weightRecords
        .where((r) => r.pigId == pigId)
        .toList()
      ..sort((a, b) => a.recordDate.compareTo(b.recordDate));
  }

  // ==================== GANADERÍA MANAGEMENT ====================
  
  // Cattle management
  Future<void> addCattle(Cattle cattle, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) {
      AppLogger.error('Error adding cattle: No farm ID provided', 
          Exception('Farm ID is null'), StackTrace.current);
      throw Exception('No se pudo determinar la finca. Por favor, selecciona una finca primero.');
    }
    
    print('=== DEBUG ADD CATTLE ===');
    print('Cattle ID: ${cattle.id}');
    print('Target Farm ID: $targetFarmId');
    print('Total fincas antes: ${_farms.length}');
    
    try {
      final farmIndex = _farms.indexWhere((f) => f.id == targetFarmId);
      if (farmIndex == -1) {
        print('ERROR: Finca no encontrada con ID: $targetFarmId');
        print('Fincas disponibles: ${_farms.map((f) => f.id).join(", ")}');
        throw Exception('Finca no encontrada');
      }
      
      final farm = _farms[farmIndex];
      print('Finca encontrada: ${farm.name}, Ganado actual: ${farm.cattle.length}');
      
      final updatedCattle = List<Cattle>.from(farm.cattle);
      updatedCattle.add(cattle);
      print('Ganado después de agregar: ${updatedCattle.length}');
      
      // Crear una nueva instancia de la finca con todas las listas actualizadas
      final updatedFarm = Farm(
        id: farm.id,
        name: farm.name,
        location: farm.location,
        description: farm.description,
        imageUrl: farm.imageUrl,
        createdAt: farm.createdAt,
        primaryColor: farm.primaryColor,
        workers: farm.workers,
        payments: farm.payments,
        loans: farm.loans,
        expenses: farm.expenses,
        pigs: farm.pigs,
        foodPurchases: farm.foodPurchases,
        weightRecords: farm.weightRecords,
        feedingAlerts: farm.feedingAlerts,
        cattle: updatedCattle,
        cattleVaccines: farm.cattleVaccines,
        cattleWeightRecords: farm.cattleWeightRecords,
        cattleTransfers: farm.cattleTransfers,
        cattleTrips: farm.cattleTrips,
        milkProductionRecords: farm.milkProductionRecords,
        reproductionEvents: farm.reproductionEvents,
      );
      
      print('Ganado en nueva finca: ${updatedFarm.cattle.length}');
      
      await updateFarm(updatedFarm);
      
      // Verificar que se guardó correctamente
      final verificationIndex = _farms.indexWhere((f) => f.id == targetFarmId);
      if (verificationIndex != -1) {
        final verifiedFarm = _farms[verificationIndex];
        print('Verificación: Ganado en finca después de guardar: ${verifiedFarm.cattle.length}');
        print('IDs de ganado guardados: ${verifiedFarm.cattle.map((c) => c.id).join(", ")}');
      }
      
      AppLogger.info('Cattle added successfully', {'cattleId': cattle.id, 'farmId': targetFarmId});
      print('=== FIN DEBUG ADD CATTLE ===');
    } catch (e, stackTrace) {
      print('ERROR en addCattle: $e');
      AppLogger.error('Error adding cattle', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateCattle(Cattle cattle, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    final farmIndex = _farms.indexWhere((f) => f.id == targetFarmId);
    if (farmIndex == -1) return;
    
    final farm = _farms[farmIndex];
    final updatedCattle = List<Cattle>.from(farm.cattle);
    final index = updatedCattle.indexWhere((c) => c.id == cattle.id);
    
    if (index != -1) {
      updatedCattle[index] = cattle;
      
      // Crear una nueva instancia de la finca con todas las listas actualizadas
      final updatedFarm = Farm(
        id: farm.id,
        name: farm.name,
        location: farm.location,
        description: farm.description,
        imageUrl: farm.imageUrl,
        createdAt: farm.createdAt,
        primaryColor: farm.primaryColor,
        workers: farm.workers,
        payments: farm.payments,
        loans: farm.loans,
        expenses: farm.expenses,
        pigs: farm.pigs,
        foodPurchases: farm.foodPurchases,
        weightRecords: farm.weightRecords,
        feedingAlerts: farm.feedingAlerts,
        cattle: updatedCattle,
        cattleVaccines: farm.cattleVaccines,
        cattleWeightRecords: farm.cattleWeightRecords,
        cattleTransfers: farm.cattleTransfers,
        cattleTrips: farm.cattleTrips,
        milkProductionRecords: farm.milkProductionRecords,
        reproductionEvents: farm.reproductionEvents,
      );
      
      await updateFarm(updatedFarm);
    }
  }

  Future<void> deleteCattle(String cattleId, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    final farmIndex = _farms.indexWhere((f) => f.id == targetFarmId);
    if (farmIndex == -1) return;
    
    final farm = _farms[farmIndex];
    
    // Eliminar el ganado y registros relacionados
    final updatedCattle = farm.cattle.where((c) => c.id != cattleId).toList();
    final updatedRecords = farm.cattleWeightRecords.where((r) => r.cattleId != cattleId).toList();
    final updatedVaccines = farm.cattleVaccines.where((v) => v.cattleId != cattleId).toList();
    
    // Crear una nueva instancia de la finca con todas las listas actualizadas
    final updatedFarm = Farm(
      id: farm.id,
      name: farm.name,
      location: farm.location,
      description: farm.description,
      imageUrl: farm.imageUrl,
      createdAt: farm.createdAt,
      primaryColor: farm.primaryColor,
      workers: farm.workers,
      payments: farm.payments,
      loans: farm.loans,
      expenses: farm.expenses,
      pigs: farm.pigs,
      foodPurchases: farm.foodPurchases,
      weightRecords: farm.weightRecords,
      feedingAlerts: farm.feedingAlerts,
      cattle: updatedCattle,
      cattleVaccines: updatedVaccines,
      cattleWeightRecords: updatedRecords,
      cattleTransfers: farm.cattleTransfers,
      cattleTrips: farm.cattleTrips,
      milkProductionRecords: farm.milkProductionRecords,
      reproductionEvents: farm.reproductionEvents,
    );
    
    await updateFarm(updatedFarm);
  }

  // Cattle Vaccine management
  Future<void> addCattleVaccine(CattleVaccine vaccine, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    final updatedVaccines = List<CattleVaccine>.from(farm.cattleVaccines);
    updatedVaccines.add(vaccine);
    
    final updatedFarm = farm.copyWith(cattleVaccines: updatedVaccines);
    await updateFarm(updatedFarm);
  }

  Future<void> deleteCattleVaccine(String vaccineId, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    final updatedVaccines = farm.cattleVaccines.where((v) => v.id != vaccineId).toList();
    final updatedFarm = farm.copyWith(cattleVaccines: updatedVaccines);
    await updateFarm(updatedFarm);
  }

  // Pig Vaccine management
  Future<void> addPigVaccine(PigVaccine vaccine, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    final updatedVaccines = List<PigVaccine>.from(farm.pigVaccines);
    updatedVaccines.add(vaccine);
    
    final updatedFarm = farm.copyWith(pigVaccines: updatedVaccines);
    await updateFarm(updatedFarm);
  }

  Future<void> updatePigVaccine(PigVaccine vaccine, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    final updatedVaccines = List<PigVaccine>.from(farm.pigVaccines);
    final index = updatedVaccines.indexWhere((v) => v.id == vaccine.id);
    
    if (index != -1) {
      updatedVaccines[index] = vaccine;
      final updatedFarm = farm.copyWith(pigVaccines: updatedVaccines);
      await updateFarm(updatedFarm);
    }
  }

  Future<void> deletePigVaccine(String vaccineId, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    final updatedVaccines = farm.pigVaccines.where((v) => v.id != vaccineId).toList();
    final updatedFarm = farm.copyWith(pigVaccines: updatedVaccines);
    await updateFarm(updatedFarm);
  }

  List<PigVaccine> getPigVaccines(String pigId, {String? farmId}) {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return [];
    
    try {
      final farm = _farms.firstWhere((f) => f.id == targetFarmId);
      return farm.pigVaccines
          .where((v) => v.pigId == pigId)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      return [];
    }
  }

  // GoatSheep Vaccine management
  Future<void> addGoatSheepVaccine(GoatSheepVaccine vaccine, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    final updatedVaccines = List<GoatSheepVaccine>.from(farm.goatSheepVaccines);
    updatedVaccines.add(vaccine);
    
    final updatedFarm = farm.copyWith(goatSheepVaccines: updatedVaccines);
    await updateFarm(updatedFarm);
  }

  Future<void> updateGoatSheepVaccine(GoatSheepVaccine vaccine, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    final updatedVaccines = List<GoatSheepVaccine>.from(farm.goatSheepVaccines);
    final index = updatedVaccines.indexWhere((v) => v.id == vaccine.id);
    
    if (index != -1) {
      updatedVaccines[index] = vaccine;
      final updatedFarm = farm.copyWith(goatSheepVaccines: updatedVaccines);
      await updateFarm(updatedFarm);
    }
  }

  Future<void> deleteGoatSheepVaccine(String vaccineId, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    final updatedVaccines = farm.goatSheepVaccines.where((v) => v.id != vaccineId).toList();
    final updatedFarm = farm.copyWith(goatSheepVaccines: updatedVaccines);
    await updateFarm(updatedFarm);
  }

  List<GoatSheepVaccine> getGoatSheepVaccines(String animalId, {String? farmId}) {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return [];
    
    try {
      final farm = _farms.firstWhere((f) => f.id == targetFarmId);
      return farm.goatSheepVaccines
          .where((v) => v.animalId == animalId)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      return [];
    }
  }

  // Cattle Weight Record management
  Future<void> addCattleWeightRecord(CattleWeightRecord record, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    final updatedRecords = List<CattleWeightRecord>.from(farm.cattleWeightRecords);
    updatedRecords.add(record);
    
    final updatedFarm = farm.copyWith(cattleWeightRecords: updatedRecords);
    await updateFarm(updatedFarm);
  }

  Future<void> deleteCattleWeightRecord(String recordId, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    final updatedRecords = farm.cattleWeightRecords.where((r) => r.id != recordId).toList();
    final updatedFarm = farm.copyWith(cattleWeightRecords: updatedRecords);
    await updateFarm(updatedFarm);
  }

  // Cattle Transfer management
  Future<void> addCattleTransfer(CattleTransfer transfer, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    try {
      final farm = _farms.firstWhere((f) => f.id == targetFarmId);
      final updatedTransfers = List<CattleTransfer>.from(farm.cattleTransfers);
      updatedTransfers.add(transfer);
      
      // Mover el animal a la finca destino
      final cattleIndex = farm.cattle.indexWhere((c) => c.id == transfer.cattleId);
      if (cattleIndex == -1) {
        throw Exception('Animal no encontrado en la finca');
      }
      
      final cattle = farm.cattle[cattleIndex];
      final updatedCattle = farm.cattle.where((c) => c.id != transfer.cattleId).toList();
      
      // Encontrar finca destino y agregar el animal
      final destFarmIndex = _farms.indexWhere((f) => f.id == transfer.toFarmId);
      if (destFarmIndex == -1) {
        throw Exception('Finca destino no encontrada');
      }
      
      final destFarm = _farms[destFarmIndex];
      final destCattle = List<Cattle>.from(destFarm.cattle);
      
      // Crear copia del animal con nueva finca
      final transferredCattle = Cattle(
        id: cattle.id,
        farmId: transfer.toFarmId ?? transfer.farmId,
        identification: cattle.identification,
        name: cattle.name,
        category: cattle.category,
        gender: cattle.gender,
        currentWeight: cattle.currentWeight,
        birthDate: cattle.birthDate,
        productionStage: cattle.productionStage,
        healthStatus: cattle.healthStatus,
        breedingStatus: cattle.breedingStatus,
        lastHeatDate: cattle.lastHeatDate,
        inseminationDate: cattle.inseminationDate,
        expectedCalvingDate: cattle.expectedCalvingDate,
        previousCalvings: cattle.previousCalvings,
        notes: cattle.notes,
        photoUrl: cattle.photoUrl,
        createdAt: cattle.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      destCattle.add(transferredCattle);
      
      final updatedFarm = farm.copyWith(cattle: updatedCattle, cattleTransfers: updatedTransfers);
      final updatedDestFarm = destFarm.copyWith(cattle: destCattle);
      
      await updateFarm(updatedFarm);
      await updateFarm(updatedDestFarm);
    } catch (e, stackTrace) {
      AppLogger.error('Error en transferencia', e, stackTrace);
      rethrow;
    }
  }

  // Helper methods for cattle
  List<CattleWeightRecord> getCattleWeightRecords(String cattleId, {String? farmId}) {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return [];
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    return farm.cattleWeightRecords
        .where((r) => r.cattleId == cattleId)
        .toList()
      ..sort((a, b) => a.recordDate.compareTo(b.recordDate));
  }

  List<CattleVaccine> getCattleVaccines(String cattleId, {String? farmId}) {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return [];
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    return farm.cattleVaccines
        .where((v) => v.cattleId == cattleId)
        .toList()
      ..sort((a, b) => b.applicationDate.compareTo(a.applicationDate));
  }

  // Cattle Trip management
  Future<void> addCattleTrip(CattleTrip trip, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    try {
      final farm = _farms.firstWhere((f) => f.id == targetFarmId);
      final updatedTrips = List<CattleTrip>.from(farm.cattleTrips);
      updatedTrips.add(trip);
      
      // Mover los animales a la finca destino
      final updatedCattle = List<Cattle>.from(farm.cattle);
      final cattleToTransfer = <Cattle>[];
      
      // Encontrar los animales que se van a transferir
      for (final cattleId in trip.cattleIds) {
        final cattleIndex = updatedCattle.indexWhere((c) => c.id == cattleId);
        if (cattleIndex == -1) {
          throw Exception('Animal no encontrado: $cattleId');
        }
        cattleToTransfer.add(updatedCattle[cattleIndex]);
        updatedCattle.removeAt(cattleIndex);
      }
      
      // Encontrar finca destino y agregar los animales
      final destFarmIndex = _farms.indexWhere((f) => f.id == trip.toFarmId);
      if (destFarmIndex == -1) {
        throw Exception('Finca destino no encontrada');
      }
      
      final destFarm = _farms[destFarmIndex];
      final destCattle = List<Cattle>.from(destFarm.cattle);
      
      // Crear copias de los animales con nueva finca
      for (final cattle in cattleToTransfer) {
        final transferredCattle = Cattle(
          id: cattle.id,
          farmId: trip.toFarmId ?? trip.farmId,
          identification: cattle.identification,
          name: cattle.name,
          category: cattle.category,
          gender: cattle.gender,
          currentWeight: cattle.currentWeight,
          birthDate: cattle.birthDate,
          productionStage: cattle.productionStage,
          healthStatus: cattle.healthStatus,
          breedingStatus: cattle.breedingStatus,
          lastHeatDate: cattle.lastHeatDate,
          inseminationDate: cattle.inseminationDate,
          expectedCalvingDate: cattle.expectedCalvingDate,
          previousCalvings: cattle.previousCalvings,
          notes: cattle.notes,
          photoUrl: cattle.photoUrl,
          createdAt: cattle.createdAt,
          updatedAt: DateTime.now(),
        );
        
        destCattle.add(transferredCattle);
      }
      
      final updatedFarm = farm.copyWith(cattle: updatedCattle, cattleTrips: updatedTrips);
      final updatedDestFarm = destFarm.copyWith(cattle: destCattle);
      
      await updateFarm(updatedFarm);
      await updateFarm(updatedDestFarm);
      
      // Los transfers individuales ya se crean automáticamente durante el proceso anterior
      // No es necesario llamar a addCattleTransfer aquí ya que los animales ya fueron movidos
    } catch (e, stackTrace) {
      AppLogger.error('Error en viaje', e, stackTrace);
      rethrow;
    }
  }

  List<CattleTrip> getCattleTrips({String? farmId}) {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return [];
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    return farm.cattleTrips
      ..sort((a, b) => b.tripDate.compareTo(a.tripDate));
  }

  // Milk Production management
  Future<void> addMilkProductionRecord(MilkProduction record, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    final updatedRecords = List<MilkProduction>.from(farm.milkProductionRecords);
    updatedRecords.add(record);
    
    final updatedFarm = farm.copyWith(milkProductionRecords: updatedRecords);
    await updateFarm(updatedFarm);
  }

  Future<void> updateMilkProductionRecord(MilkProduction record, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    final updatedRecords = List<MilkProduction>.from(farm.milkProductionRecords);
    final index = updatedRecords.indexWhere((r) => r.id == record.id);
    
    if (index != -1) {
      updatedRecords[index] = record;
      final updatedFarm = farm.copyWith(milkProductionRecords: updatedRecords);
      await updateFarm(updatedFarm);
    }
  }

  Future<void> deleteMilkProductionRecord(String recordId, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    final updatedRecords = farm.milkProductionRecords.where((r) => r.id != recordId).toList();
    final updatedFarm = farm.copyWith(milkProductionRecords: updatedRecords);
    await updateFarm(updatedFarm);
  }

  List<MilkProduction> getMilkProductionRecords(String cattleId, {String? farmId}) {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return [];
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    return farm.milkProductionRecords
        .where((r) => r.cattleId == cattleId)
        .toList()
      ..sort((a, b) => b.recordDate.compareTo(a.recordDate));
  }

  // Reproduction Event management
  Future<void> addReproductionEvent(ReproductionEvent event, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    final updatedEvents = List<ReproductionEvent>.from(farm.reproductionEvents);
    updatedEvents.add(event);
    
    final updatedFarm = farm.copyWith(reproductionEvents: updatedEvents);
    await updateFarm(updatedFarm);
  }

  Future<void> deleteReproductionEvent(String eventId, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    final updatedEvents = farm.reproductionEvents.where((e) => e.id != eventId).toList();
    final updatedFarm = farm.copyWith(reproductionEvents: updatedEvents);
    await updateFarm(updatedFarm);
  }

  List<ReproductionEvent> getReproductionEvents(String cattleId, {String? farmId}) {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return [];
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    return farm.reproductionEvents
        .where((e) => e.cattleId == cattleId)
        .toList()
      ..sort((a, b) => b.eventDate.compareTo(a.eventDate));
  }

  // ==================== EXPORT/IMPORT DATA ====================
  
  /// Exporta todos los datos de la aplicación a un archivo JSON
  /// Retorna la ruta del archivo exportado
  Future<String?> exportAllData() async {
    try {
      final dataToExport = {
        'version': '1.0',
        'exportDate': DateTime.now().toIso8601String(),
        'farms': _farms.map((farm) => farm.toJson()).toList(),
        'currentFarmId': _currentFarm?.id,
      };
      
      final jsonString = json.encode(dataToExport);
      
      // Obtener directorio temporal
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }
      
      if (directory == null) return null;
      
      // Crear archivo con timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'ganaderia_backup_$timestamp.json';
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsString(jsonString);
      
      return file.path;
    } catch (e, stackTrace) {
      AppLogger.error('Error exporting data', e, stackTrace);
      return null;
    }
  }
  
  /// Importa datos desde un archivo JSON
  /// Retorna true si la importación fue exitosa
  Future<bool> importAllData(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        AppLogger.warning('File does not exist', filePath);
        return false;
      }
      
      final jsonString = await file.readAsString();
      final data = json.decode(jsonString) as Map<String, dynamic>;
      
      // Validar versión
      final version = data['version'] as String?;
      if (version == null) {
        AppLogger.warning('Invalid backup file: missing version');
        return false;
      }
      
      // Importar fincas
      final farmsList = data['farms'] as List<dynamic>;
      _farms = farmsList.map((farmJson) => Farm.fromJson(farmJson)).toList();
      
      // Restaurar finca actual
      final currentFarmId = data['currentFarmId'] as String?;
      if (currentFarmId != null && _farms.isNotEmpty) {
        try {
          _currentFarm = _farms.firstWhere((farm) => farm.id == currentFarmId);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_getCurrentFarmKey(), currentFarmId);
        } catch (e) {
          _currentFarm = _farms.isNotEmpty ? _farms.first : null;
        }
      }
      
      // Guardar todas las fincas
      await _saveFarms();
      notifyListeners();
      
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Error importing data', e, stackTrace);
      return false;
    }
  }

  // ==================== MODULE ORDER MANAGEMENT ====================
  
  /// Carga el orden personalizado de módulos
  Future<List<ModuleItem>> getModulesOrder() async {
    if (_userId == null) return ModuleItem.getDefaultModules();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final modulesJson = prefs.getString(_getModulesOrderKey());
      
      if (modulesJson == null) {
        return ModuleItem.getDefaultModules();
      }
      
      final List<dynamic> modulesList = json.decode(modulesJson);
      return modulesList.map((moduleJson) => ModuleItem.fromJson(moduleJson)).toList()
        ..sort((a, b) => a.order.compareTo(b.order));
    } catch (e, stackTrace) {
      AppLogger.error('Error loading modules order', e, stackTrace);
      return ModuleItem.getDefaultModules();
    }
  }
  
  /// Guarda el orden personalizado de módulos
  Future<void> saveModulesOrder(List<ModuleItem> modules) async {
    if (_userId == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final modulesJson = json.encode(modules.map((m) => m.toJson()).toList());
      await prefs.setString(_getModulesOrderKey(), modulesJson);
      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.error('Error saving modules order', e, stackTrace);
    }
  }
  
  /// Restablece el orden de módulos al predeterminado
  Future<void> resetModulesOrder() async {
    if (_userId == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_getModulesOrderKey());
      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.error('Error resetting modules order', e, stackTrace);
    }
  }

  // ==================== CONTROL CHIVOS/OVEJAS MANAGEMENT ====================
  
  // GoatSheep management
  Future<void> addGoatSheep(GoatSheep animal, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    final updatedGoatSheep = List<GoatSheep>.from(farm.goatSheep);
    updatedGoatSheep.add(animal);
    
    final updatedFarm = farm.copyWith(goatSheep: updatedGoatSheep);
    await updateFarm(updatedFarm);
  }

  Future<void> updateGoatSheep(GoatSheep animal, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    final updatedGoatSheep = List<GoatSheep>.from(farm.goatSheep);
    final index = updatedGoatSheep.indexWhere((a) => a.id == animal.id);
    
    if (index != -1) {
      updatedGoatSheep[index] = animal;
      final updatedFarm = farm.copyWith(goatSheep: updatedGoatSheep);
      await updateFarm(updatedFarm);
    }
  }

  Future<void> deleteGoatSheep(String animalId, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    final updatedGoatSheep = farm.goatSheep.where((a) => a.id != animalId).toList();
    final updatedFarm = farm.copyWith(goatSheep: updatedGoatSheep);
    await updateFarm(updatedFarm);
  }

  GoatSheep? getGoatSheepById(String animalId, {String? farmId}) {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return null;
    
    try {
      final farm = _farms.firstWhere((f) => f.id == targetFarmId);
      return farm.goatSheep.firstWhere((a) => a.id == animalId);
    } catch (e) {
      return null;
    }
  }

  // BroilerBatch management
  Future<void> addBroilerBatch(BroilerBatch batch, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    final updatedBatches = List<BroilerBatch>.from(farm.broilerBatches);
    updatedBatches.add(batch);
    
    final updatedFarm = farm.copyWith(broilerBatches: updatedBatches);
    await updateFarm(updatedFarm);
  }

  Future<void> updateBroilerBatch(BroilerBatch batch, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    final updatedBatches = List<BroilerBatch>.from(farm.broilerBatches);
    final index = updatedBatches.indexWhere((b) => b.id == batch.id);
    
    if (index != -1) {
      updatedBatches[index] = batch;
      final updatedFarm = farm.copyWith(broilerBatches: updatedBatches);
      await updateFarm(updatedFarm);
    }
  }

  Future<void> deleteBroilerBatch(String batchId, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    final updatedBatches = farm.broilerBatches.where((b) => b.id != batchId).toList();
    final updatedFarm = farm.copyWith(broilerBatches: updatedBatches);
    await updateFarm(updatedFarm);
  }

  BroilerBatch? getBroilerBatchById(String batchId, {String? farmId}) {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return null;
    
    try {
      final farm = _farms.firstWhere((f) => f.id == targetFarmId);
      final batch = farm.broilerBatches.firstWhere((b) => b.id == batchId);
      
      // Si el batch está activo y tiene stock, actualizar automáticamente el stock
      if (batch.estado == BatchStatus.activo && batch.ultimaActualizacionStock != null) {
        final stockActualizado = batch.stockAlimentoActualKg;
        // Solo actualizar si hay diferencia significativa (más de 0.1kg)
        if ((batch.stockAlimentoKg - stockActualizado).abs() > 0.1) {
          final batchActualizado = batch.copyWith(
            stockAlimentoKg: stockActualizado,
            ultimaActualizacionStock: DateTime.now(),
          );
          // Actualizar en memoria sin guardar (para no hacer persistencia en cada lectura)
          final updatedBatches = List<BroilerBatch>.from(farm.broilerBatches);
          final index = updatedBatches.indexWhere((b) => b.id == batchId);
          if (index != -1) {
            updatedBatches[index] = batchActualizado;
            final updatedFarm = farm.copyWith(broilerBatches: updatedBatches);
            _farms[_farms.indexWhere((f) => f.id == targetFarmId)] = updatedFarm;
            notifyListeners();
          }
          return batchActualizado;
        }
      }
      
      return batch;
    } catch (e) {
      return null;
    }
  }

  // LayerBatch management
  Future<void> addLayerBatch(LayerBatch batch, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    final updatedBatches = List<LayerBatch>.from(farm.layerBatches);
    updatedBatches.add(batch);
    
    final updatedFarm = farm.copyWith(layerBatches: updatedBatches);
    await updateFarm(updatedFarm);
  }

  Future<void> updateLayerBatch(LayerBatch batch, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    final updatedBatches = List<LayerBatch>.from(farm.layerBatches);
    final index = updatedBatches.indexWhere((b) => b.id == batch.id);
    
    if (index != -1) {
      updatedBatches[index] = batch;
      final updatedFarm = farm.copyWith(layerBatches: updatedBatches);
      await updateFarm(updatedFarm);
    }
  }

  Future<void> deleteLayerBatch(String batchId, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    final updatedBatches = farm.layerBatches.where((b) => b.id != batchId).toList();
    final updatedFarm = farm.copyWith(layerBatches: updatedBatches);
    await updateFarm(updatedFarm);
    
    // Eliminar registros de producción asociados
    final updatedRecords = farm.layerProductionRecords
        .where((r) => r.layerBatchId != batchId)
        .toList();
    await updateFarm(updatedFarm.copyWith(layerProductionRecords: updatedRecords));
  }

  LayerBatch? getLayerBatchById(String batchId, {String? farmId}) {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return null;
    
    try {
      final farm = _farms.firstWhere((f) => f.id == targetFarmId);
      return farm.layerBatches.firstWhere((b) => b.id == batchId);
    } catch (e) {
      return null;
    }
  }

  // LayerProductionRecord management
  Future<void> addLayerProductionRecord(LayerProductionRecord record, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    final updatedRecords = List<LayerProductionRecord>.from(farm.layerProductionRecords);
    updatedRecords.add(record);
    
    final updatedFarm = farm.copyWith(layerProductionRecords: updatedRecords);
    await updateFarm(updatedFarm);
  }

  Future<void> updateLayerProductionRecord(LayerProductionRecord record, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    final updatedRecords = List<LayerProductionRecord>.from(farm.layerProductionRecords);
    final index = updatedRecords.indexWhere((r) => r.id == record.id);
    
    if (index != -1) {
      updatedRecords[index] = record;
      final updatedFarm = farm.copyWith(layerProductionRecords: updatedRecords);
      await updateFarm(updatedFarm);
    }
  }

  Future<void> deleteLayerProductionRecord(String recordId, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    final updatedRecords = farm.layerProductionRecords.where((r) => r.id != recordId).toList();
    final updatedFarm = farm.copyWith(layerProductionRecords: updatedRecords);
    await updateFarm(updatedFarm);
  }

  List<LayerProductionRecord> getLayerProductionRecordsByBatchId(String batchId, {String? farmId}) {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return [];
    
    try {
      final farm = _farms.firstWhere((f) => f.id == targetFarmId);
      return farm.layerProductionRecords
          .where((r) => r.layerBatchId == batchId)
          .toList()
        ..sort((a, b) => b.fecha.compareTo(a.fecha));
    } catch (e) {
      return [];
    }
  }

  // BatchExpense management
  Future<void> addBatchExpense(BatchExpense expense, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    final updatedExpenses = List<BatchExpense>.from(farm.batchExpenses);
    updatedExpenses.add(expense);
    
    final updatedFarm = farm.copyWith(batchExpenses: updatedExpenses);
    await updateFarm(updatedFarm);
  }

  Future<void> updateBatchExpense(BatchExpense expense, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    final updatedExpenses = List<BatchExpense>.from(farm.batchExpenses);
    final index = updatedExpenses.indexWhere((e) => e.id == expense.id);
    
    if (index != -1) {
      updatedExpenses[index] = expense;
      final updatedFarm = farm.copyWith(batchExpenses: updatedExpenses);
      await updateFarm(updatedFarm);
    }
  }

  Future<void> deleteBatchExpense(String expenseId, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    final updatedExpenses = farm.batchExpenses.where((e) => e.id != expenseId).toList();
    final updatedFarm = farm.copyWith(batchExpenses: updatedExpenses);
    await updateFarm(updatedFarm);
  }

  List<BatchExpense> getBatchExpensesByBatchId(String batchId, {String? farmId}) {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return [];
    
    try {
      final farm = _farms.firstWhere((f) => f.id == targetFarmId);
      return farm.batchExpenses
          .where((e) => e.batchId == batchId)
          .toList()
        ..sort((a, b) => b.fecha.compareTo(a.fecha));
    } catch (e) {
      return [];
    }
  }

  // BatchSale management
  Future<void> addBatchSale(BatchSale sale, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    final updatedSales = List<BatchSale>.from(farm.batchSales);
    updatedSales.add(sale);
    
    // Marcar el lote como cerrado
    final updatedBatches = List<BroilerBatch>.from(farm.broilerBatches);
    final batchIndex = updatedBatches.indexWhere((b) => b.id == sale.batchId);
    if (batchIndex != -1) {
      updatedBatches[batchIndex] = updatedBatches[batchIndex].copyWith(
        estado: BatchStatus.cerrado,
        updatedAt: DateTime.now(),
      );
    }
    
    final updatedFarm = farm.copyWith(
      batchSales: updatedSales,
      broilerBatches: updatedBatches,
    );
    await updateFarm(updatedFarm);
  }

  Future<void> updateBatchSale(BatchSale sale, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    final updatedSales = List<BatchSale>.from(farm.batchSales);
    final index = updatedSales.indexWhere((s) => s.id == sale.id);
    
    if (index != -1) {
      updatedSales[index] = sale;
      final updatedFarm = farm.copyWith(batchSales: updatedSales);
      await updateFarm(updatedFarm);
    }
  }

  Future<void> deleteBatchSale(String saleId, {String? farmId}) async {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return;
    
    final farm = _farms.firstWhere((f) => f.id == targetFarmId);
    final sale = farm.batchSales.firstWhere((s) => s.id == saleId);
    
    // Si se elimina la venta, reactivar el lote si no hay otras ventas
    final updatedSales = farm.batchSales.where((s) => s.id != saleId).toList();
    final otherSalesForBatch = updatedSales.where((s) => s.batchId == sale.batchId).isEmpty;
    
    final updatedBatches = List<BroilerBatch>.from(farm.broilerBatches);
    if (otherSalesForBatch) {
      final batchIndex = updatedBatches.indexWhere((b) => b.id == sale.batchId);
      if (batchIndex != -1) {
        updatedBatches[batchIndex] = updatedBatches[batchIndex].copyWith(
          estado: BatchStatus.activo,
          updatedAt: DateTime.now(),
        );
      }
    }
    
    final updatedFarm = farm.copyWith(
      batchSales: updatedSales,
      broilerBatches: updatedBatches,
    );
    await updateFarm(updatedFarm);
  }

  BatchSale? getBatchSaleByBatchId(String batchId, {String? farmId}) {
    final targetFarmId = farmId ?? _currentFarm?.id;
    if (targetFarmId == null) return null;
    
    try {
      final farm = _farms.firstWhere((f) => f.id == targetFarmId);
      return farm.batchSales.firstWhere((s) => s.batchId == batchId);
    } catch (e) {
      return null;
    }
  }
}