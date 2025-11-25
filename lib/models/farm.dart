import 'package:flutter/material.dart';
import 'dart:ui' show Color;
import 'worker.dart';
import 'payment.dart';
import 'loan.dart';
import 'expense.dart';
import 'pig.dart';
import 'food_purchase.dart';
import 'weight_record.dart';
import 'feeding_alert.dart';
import 'cattle.dart';
import 'cattle_vaccine.dart';
import 'cattle_weight_record.dart';
import 'cattle_transfer.dart';
import 'cattle_trip.dart';
import 'milk_production.dart';
import 'reproduction_event.dart';
import 'goat_sheep.dart';
import 'pig_vaccine.dart';
import 'goat_sheep_vaccine.dart';
import 'broiler_batch.dart';
import 'layer_batch.dart';
import 'layer_production_record.dart';
import 'batch_expense.dart';
import 'batch_sale.dart';

class Farm {
  final String id;
  final String name;
  final String? location;
  final String? description;
  final String? imageUrl;
  final DateTime createdAt;
  final Color primaryColor;
  final List<Worker> workers;
  final List<Payment> payments;
  final List<Loan> loans;
  final List<Expense> expenses;
  final List<Pig> pigs;
  final List<FoodPurchase> foodPurchases;
  final List<WeightRecord> weightRecords;
  final List<FeedingAlert> feedingAlerts;
  final List<Cattle> cattle;
  final List<CattleVaccine> cattleVaccines;
  final List<CattleWeightRecord> cattleWeightRecords;
  final List<CattleTransfer> cattleTransfers;
  final List<CattleTrip> cattleTrips;
  final List<MilkProduction> milkProductionRecords;
  final List<ReproductionEvent> reproductionEvents;
  final List<GoatSheep> goatSheep;
  final List<PigVaccine> pigVaccines;
  final List<GoatSheepVaccine> goatSheepVaccines;
  final List<BroilerBatch> broilerBatches;
  final List<LayerBatch> layerBatches;
  final List<LayerProductionRecord> layerProductionRecords;
  final List<BatchExpense> batchExpenses;
  final List<BatchSale> batchSales;

  Farm({
    required this.id,
    required this.name,
    this.location,
    this.description,
    this.imageUrl,
    required this.createdAt,
    required this.primaryColor,
    List<Worker>? workers,
    List<Payment>? payments,
    List<Loan>? loans,
    List<Expense>? expenses,
    List<Pig>? pigs,
    List<FoodPurchase>? foodPurchases,
    List<WeightRecord>? weightRecords,
    List<FeedingAlert>? feedingAlerts,
    List<Cattle>? cattle,
    List<CattleVaccine>? cattleVaccines,
    List<CattleWeightRecord>? cattleWeightRecords,
    List<CattleTransfer>? cattleTransfers,
    List<CattleTrip>? cattleTrips,
    List<MilkProduction>? milkProductionRecords,
    List<ReproductionEvent>? reproductionEvents,
    List<GoatSheep>? goatSheep,
    List<PigVaccine>? pigVaccines,
    List<GoatSheepVaccine>? goatSheepVaccines,
    List<BroilerBatch>? broilerBatches,
    List<LayerBatch>? layerBatches,
    List<LayerProductionRecord>? layerProductionRecords,
    List<BatchExpense>? batchExpenses,
    List<BatchSale>? batchSales,
  })  : workers = workers ?? [],
        payments = payments ?? [],
        loans = loans ?? [],
        expenses = expenses ?? [],
        pigs = pigs ?? [],
        foodPurchases = foodPurchases ?? [],
        weightRecords = weightRecords ?? [],
        feedingAlerts = feedingAlerts ?? [],
        cattle = cattle ?? [],
        cattleVaccines = cattleVaccines ?? [],
        cattleWeightRecords = cattleWeightRecords ?? [],
        cattleTransfers = cattleTransfers ?? [],
        cattleTrips = cattleTrips ?? [],
        milkProductionRecords = milkProductionRecords ?? [],
        reproductionEvents = reproductionEvents ?? [],
        goatSheep = goatSheep ?? [],
        pigVaccines = pigVaccines ?? [],
        goatSheepVaccines = goatSheepVaccines ?? [],
        broilerBatches = broilerBatches ?? [],
        layerBatches = layerBatches ?? [],
        layerProductionRecords = layerProductionRecords ?? [],
        batchExpenses = batchExpenses ?? [],
        batchSales = batchSales ?? [];

  Farm copyWith({
    String? id,
    String? name,
    String? location,
    String? description,
    String? imageUrl,
    DateTime? createdAt,
    Color? primaryColor,
    List<Worker>? workers,
    List<Payment>? payments,
    List<Loan>? loans,
    List<Expense>? expenses,
    List<Pig>? pigs,
    List<FoodPurchase>? foodPurchases,
    List<WeightRecord>? weightRecords,
    List<FeedingAlert>? feedingAlerts,
    List<Cattle>? cattle,
    List<CattleVaccine>? cattleVaccines,
    List<CattleWeightRecord>? cattleWeightRecords,
    List<CattleTransfer>? cattleTransfers,
    List<CattleTrip>? cattleTrips,
    List<MilkProduction>? milkProductionRecords,
    List<ReproductionEvent>? reproductionEvents,
    List<GoatSheep>? goatSheep,
    List<PigVaccine>? pigVaccines,
    List<GoatSheepVaccine>? goatSheepVaccines,
    List<BroilerBatch>? broilerBatches,
    List<LayerBatch>? layerBatches,
    List<LayerProductionRecord>? layerProductionRecords,
    List<BatchExpense>? batchExpenses,
    List<BatchSale>? batchSales,
  }) {
    return Farm(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      primaryColor: primaryColor ?? this.primaryColor,
      workers: workers ?? this.workers,
      payments: payments ?? this.payments,
      loans: loans ?? this.loans,
      expenses: expenses ?? this.expenses,
      pigs: pigs ?? this.pigs,
      foodPurchases: foodPurchases ?? this.foodPurchases,
      weightRecords: weightRecords ?? this.weightRecords,
      feedingAlerts: feedingAlerts ?? this.feedingAlerts,
      cattle: cattle ?? this.cattle,
      cattleVaccines: cattleVaccines ?? this.cattleVaccines,
      cattleWeightRecords: cattleWeightRecords ?? this.cattleWeightRecords,
      cattleTransfers: cattleTransfers ?? this.cattleTransfers,
      cattleTrips: cattleTrips ?? this.cattleTrips,
      milkProductionRecords: milkProductionRecords ?? this.milkProductionRecords,
      reproductionEvents: reproductionEvents ?? this.reproductionEvents,
      goatSheep: goatSheep ?? this.goatSheep,
      pigVaccines: pigVaccines ?? this.pigVaccines,
      goatSheepVaccines: goatSheepVaccines ?? this.goatSheepVaccines,
      broilerBatches: broilerBatches ?? this.broilerBatches,
      layerBatches: layerBatches ?? this.layerBatches,
      layerProductionRecords: layerProductionRecords ?? this.layerProductionRecords,
      batchExpenses: batchExpenses ?? this.batchExpenses,
      batchSales: batchSales ?? this.batchSales,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'description': description,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'primaryColor': primaryColor.value,
      'workers': workers.map((w) => w.toJson()).toList(),
      'payments': payments.map((p) => p.toJson()).toList(),
      'loans': loans.map((l) => l.toJson()).toList(),
      'expenses': expenses.map((e) => e.toJson()).toList(),
      'pigs': pigs.map((p) => p.toJson()).toList(),
      'foodPurchases': foodPurchases.map((f) => f.toJson()).toList(),
      'weightRecords': weightRecords.map((w) => w.toJson()).toList(),
      'feedingAlerts': feedingAlerts.map((f) => f.toJson()).toList(),
      'cattle': cattle.map((c) => c.toJson()).toList(),
      'cattleVaccines': cattleVaccines.map((c) => c.toJson()).toList(),
      'cattleWeightRecords': cattleWeightRecords.map((c) => c.toJson()).toList(),
      'cattleTransfers': cattleTransfers.map((c) => c.toJson()).toList(),
      'cattleTrips': cattleTrips.map((c) => c.toJson()).toList(),
      'milkProductionRecords': milkProductionRecords.map((m) => m.toJson()).toList(),
      'reproductionEvents': reproductionEvents.map((r) => r.toJson()).toList(),
      'goatSheep': goatSheep.map((g) => g.toJson()).toList(),
      'pigVaccines': pigVaccines.map((v) => v.toJson()).toList(),
      'goatSheepVaccines': goatSheepVaccines.map((v) => v.toJson()).toList(),
      'broilerBatches': broilerBatches.map((b) => b.toJson()).toList(),
      'layerBatches': layerBatches.map((l) => l.toJson()).toList(),
      'layerProductionRecords': layerProductionRecords.map((r) => r.toJson()).toList(),
      'batchExpenses': batchExpenses.map((e) => e.toJson()).toList(),
      'batchSales': batchSales.map((s) => s.toJson()).toList(),
    };
  }

  factory Farm.fromJson(Map<String, dynamic> json) {
    return Farm(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String?,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      primaryColor: Color(json['primaryColor'] as int),
      workers: (json['workers'] as List<dynamic>?)
              ?.map((w) => Worker.fromJson(w as Map<String, dynamic>))
              .toList() ??
          [],
      payments: (json['payments'] as List<dynamic>?)
              ?.map((p) => Payment.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      loans: (json['loans'] as List<dynamic>?)
              ?.map((l) => Loan.fromJson(l as Map<String, dynamic>))
              .toList() ??
          [],
      expenses: (json['expenses'] as List<dynamic>?)
              ?.map((e) => Expense.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      pigs: (json['pigs'] as List<dynamic>?)
              ?.map((p) => Pig.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      foodPurchases: (json['foodPurchases'] as List<dynamic>?)
              ?.map((f) => FoodPurchase.fromJson(f as Map<String, dynamic>))
              .toList() ??
          [],
      weightRecords: (json['weightRecords'] as List<dynamic>?)
              ?.map((w) => WeightRecord.fromJson(w as Map<String, dynamic>))
              .toList() ??
          [],
      feedingAlerts: (json['feedingAlerts'] as List<dynamic>?)
              ?.map((f) => FeedingAlert.fromJson(f as Map<String, dynamic>))
              .toList() ??
          [],
      cattle: (json['cattle'] as List<dynamic>?)
              ?.map((c) => Cattle.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      cattleVaccines: (json['cattleVaccines'] as List<dynamic>?)
              ?.map((c) => CattleVaccine.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      cattleWeightRecords: (json['cattleWeightRecords'] as List<dynamic>?)
              ?.map((c) => CattleWeightRecord.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      cattleTransfers: (json['cattleTransfers'] as List<dynamic>?)
              ?.map((c) => CattleTransfer.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      cattleTrips: (json['cattleTrips'] as List<dynamic>?)
              ?.map((c) => CattleTrip.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      milkProductionRecords: (json['milkProductionRecords'] as List<dynamic>?)
              ?.map((m) => MilkProduction.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      reproductionEvents: (json['reproductionEvents'] as List<dynamic>?)
              ?.map((r) => ReproductionEvent.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
      goatSheep: (json['goatSheep'] as List<dynamic>?)
              ?.map((g) => GoatSheep.fromJson(g as Map<String, dynamic>))
              .toList() ??
          [],
      pigVaccines: (json['pigVaccines'] as List<dynamic>?)
              ?.map((v) => PigVaccine.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
      goatSheepVaccines: (json['goatSheepVaccines'] as List<dynamic>?)
              ?.map((v) => GoatSheepVaccine.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
      broilerBatches: (json['broilerBatches'] as List<dynamic>?)
              ?.map((b) => BroilerBatch.fromJson(b as Map<String, dynamic>))
              .toList() ??
          [],
      layerBatches: (json['layerBatches'] as List<dynamic>?)
              ?.map((l) => LayerBatch.fromJson(l as Map<String, dynamic>))
              .toList() ??
          [],
      layerProductionRecords: (json['layerProductionRecords'] as List<dynamic>?)
              ?.map((r) => LayerProductionRecord.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
      batchExpenses: (json['batchExpenses'] as List<dynamic>?)
              ?.map((e) => BatchExpense.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      batchSales: (json['batchSales'] as List<dynamic>?)
              ?.map((s) => BatchSale.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  List<Worker> get activeWorkers => workers.where((w) => w.isActive).toList();
  int get activeWorkersCount => activeWorkers.length;

  // Calcular días hasta que se acabe el alimento
  double? get daysUntilFoodRunsOut {
    if (pigs.isEmpty || foodPurchases.isEmpty) return null;
    
    // Calcular consumo diario promedio por cerdo (estimado)
    const double dailyConsumptionPerPig = 2.5; // kg por día
    final totalPigs = pigs.length;
    final dailyConsumption = totalPigs * dailyConsumptionPerPig;
    
    if (dailyConsumption <= 0) return null;
    
    // Calcular cantidad total de alimento disponible
    final now = DateTime.now();
    final totalFood = foodPurchases
        .where((purchase) => purchase.date.isBefore(now) || purchase.date.isAtSameMomentAs(now))
        .fold<double>(0.0, (sum, purchase) {
          // Convertir a kg si es necesario
          double quantity = purchase.quantity;
          final unit = purchase.unit.toLowerCase();
          if (unit == 'toneladas' || unit == 'ton') {
            quantity = quantity * 1000;
          } else if (unit == 'gramos' || unit == 'g') {
            quantity = quantity / 1000;
          }
          return sum + quantity;
        });
    
    if (totalFood <= 0) return null;
    
    // Calcular días restantes
    final daysLeft = totalFood / dailyConsumption;
    return daysLeft;
  }

  // Getters calculados para ganado
  int get cattleCount => cattle.length;
  double get totalCattleWeight => cattle.fold(0.0, (sum, c) => sum + c.currentWeight);
  int get maleCattleCount => cattle.where((c) => c.gender == CattleGender.male).length;
  int get femaleCattleCount => cattle.where((c) => c.gender == CattleGender.female).length;
  double get averageCattleWeight => cattleCount > 0 ? totalCattleWeight / cattleCount : 0.0;

  // Getters calculados para cerdos
  int get pigsCount => pigs.length;
  double get totalPigsWeight => pigs.fold(0.0, (sum, p) => sum + p.currentWeight);
  double get averagePigWeight => pigsCount > 0 ? totalPigsWeight / pigsCount : 0.0;
  double get totalDailyFeedingConsumption => pigs.fold(0.0, (sum, p) => sum + p.estimatedDailyConsumption);

  // Getters calculados para alimento
  double get totalFoodInventory {
    final now = DateTime.now();
    return foodPurchases
        .where((purchase) => purchase.date.isBefore(now) || purchase.date.isAtSameMomentAs(now))
        .fold<double>(0.0, (sum, purchase) {
          double quantity = purchase.quantity;
          final unit = purchase.unit.toLowerCase();
          if (unit == 'toneladas' || unit == 'ton') {
            quantity = quantity * 1000;
          } else if (unit == 'gramos' || unit == 'g') {
            quantity = quantity / 1000;
          }
          return sum + quantity;
        });
  }

  double get totalFoodCost => foodPurchases.fold(0.0, (sum, purchase) => sum + purchase.totalCost);

  // Getters calculados para préstamos
  int get totalPendingLoans => loans.where((l) => l.status == LoanStatus.pending).length;
  double get totalLoaned => loans.fold(0.0, (sum, loan) => sum + loan.amount);

  // Getters calculados para pagos
  double get totalPaidThisMonth {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    return payments
        .where((p) => p.date.isAfter(firstDayOfMonth.subtract(const Duration(days: 1))))
        .fold(0.0, (sum, p) => sum + p.amount);
  }

  // Getters calculados para gastos
  double get totalExpensesThisMonth {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    return expenses
        .where((e) => e.date.isAfter(firstDayOfMonth.subtract(const Duration(days: 1))))
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  // Getters calculados para chivos/ovejas
  int get goatSheepCount => goatSheep.length;
}

