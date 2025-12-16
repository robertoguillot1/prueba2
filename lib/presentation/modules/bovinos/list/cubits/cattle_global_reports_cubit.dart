import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../../features/cattle/domain/entities/bovine_entity.dart';
import '../../../../../features/cattle/domain/usecases/get_cattle_list.dart';

// States
abstract class CattleGlobalReportsState extends Equatable {
  const CattleGlobalReportsState();

  @override
  List<Object?> get props => [];
}

class ReportsInitial extends CattleGlobalReportsState {}

class ReportsLoading extends CattleGlobalReportsState {}

class ReportsLoaded extends CattleGlobalReportsState {
  final int totalCattle;
  final int totalMilkCows;
  final double averageWeight;
  final Map<String, int> statusDistribution;
  final Map<String, int> categoryDistribution;

  const ReportsLoaded({
    required this.totalCattle,
    required this.totalMilkCows,
    required this.averageWeight,
    required this.statusDistribution,
    required this.categoryDistribution,
  });

  @override
  List<Object?> get props => [totalCattle, totalMilkCows, averageWeight, statusDistribution, categoryDistribution];
}

class ReportsError extends CattleGlobalReportsState {
  final String message;

  const ReportsError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class CattleGlobalReportsCubit extends Cubit<CattleGlobalReportsState> {
  final GetCattleList getCattleList;

  CattleGlobalReportsCubit(this.getCattleList) : super(ReportsInitial());

  Future<void> loadReports(String farmId) async {
    emit(ReportsLoading());
    try {
      final result = await getCattleList(GetCattleListParams(farmId: farmId));
      
      result.fold(
        (failure) => emit(const ReportsError("Error cargando datos para reportes")),
        (cattleList) {
          if (cattleList.isEmpty) {
             emit(const ReportsLoaded(
               totalCattle: 0,
               totalMilkCows: 0,
               averageWeight: 0,
               statusDistribution: {},
               categoryDistribution: {},
             ));
             return;
          }

          final total = cattleList.length;
          final milkCows = cattleList.where((c) => c.purpose == BovinePurpose.milk || c.purpose == BovinePurpose.dual).length;
          final totalWeight = cattleList.fold(0.0, (sum, c) => sum + c.weight);
          final avgWeight = totalWeight / total;

          final statusDist = <String, int>{};
          for (var c in cattleList) {
            final key = c.status.name; // Or a cleaner label
            statusDist[key] = (statusDist[key] ?? 0) + 1;
          }
          
          final categoryDist = <String, int>{};
          for (var c in cattleList) {
            final key = c.category.name; 
            categoryDist[key] = (categoryDist[key] ?? 0) + 1;
          }

          emit(ReportsLoaded(
            totalCattle: total,
            totalMilkCows: milkCows,
            averageWeight: avgWeight,
            statusDistribution: statusDist,
            categoryDistribution: categoryDist,
          ));
        },
      );
    } catch (e) {
      emit(ReportsError(e.toString()));
    }
  }
}
