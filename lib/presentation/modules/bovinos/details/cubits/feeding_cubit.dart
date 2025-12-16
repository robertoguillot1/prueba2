import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../../features/cattle/domain/entities/feeding_schedule.dart';
import '../../../../../features/cattle/domain/usecases/feeding/get_feeding_schedules.dart';
import '../../../../../features/cattle/domain/usecases/feeding/save_feeding_schedule.dart';
import '../../../../../features/cattle/domain/usecases/feeding/calculate_nutritional_requirements.dart';

// States
abstract class FeedingState extends Equatable {
  const FeedingState();

  @override
  List<Object?> get props => [];
}

class FeedingInitial extends FeedingState {}

class FeedingLoading extends FeedingState {}

class FeedingLoaded extends FeedingState {
  final List<FeedingSchedule> schedules;
  final Map<String, dynamic> nutritionalStats;

  const FeedingLoaded(this.schedules, this.nutritionalStats);

  @override
  List<Object?> get props => [schedules, nutritionalStats];
}

class FeedingError extends FeedingState {
  final String message;

  const FeedingError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class FeedingCubit extends Cubit<FeedingState> {
  final GetFeedingSchedules getSchedules;
  final SaveFeedingSchedule saveSchedule;
  final CalculateNutritionalRequirements calculateRequirements;

  FeedingCubit({
    required this.getSchedules,
    required this.saveSchedule,
    required this.calculateRequirements,
  }) : super(FeedingInitial());

  Future<void> loadFeedingData(String bovineId) async {
    emit(FeedingLoading());
    try {
      final schedulesResult = await getSchedules(bovineId);
      final statsResult = await calculateRequirements(bovineId);

      schedulesResult.fold(
        (failure) => emit(const FeedingError("Error cargando programas de alimentación")),
        (schedules) {
          statsResult.fold(
            (failure) => emit(FeedingLoaded(schedules, const {})),
            (stats) => emit(FeedingLoaded(schedules, stats)),
          );
        },
      );
    } catch (e) {
      emit(FeedingError(e.toString()));
    }
  }

  Future<void> addSchedule(FeedingSchedule schedule) async {
    // Optimistic update or reload could work. For simplicity, we reload.
    // Ideally we'd emit a loading state or append first.
    final result = await saveSchedule(schedule);
    
    result.fold(
      (failure) => emit(const FeedingError("Error guardando programa")),
      (_) => loadFeedingData(schedule.bovineId),
    );
  }
}
