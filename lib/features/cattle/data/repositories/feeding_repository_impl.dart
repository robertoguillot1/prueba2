import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/feeding_repository.dart';
import '../../domain/entities/feeding_schedule.dart';
import '../../domain/entities/nutritional_alert.dart';
import '../datasources/feeding_local_datasource.dart';
import '../models/feeding_schedule_model.dart';

class FeedingRepositoryImpl implements FeedingRepository {
  final FeedingLocalDataSource localDataSource;

  FeedingRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<FeedingSchedule>>> getFeedingSchedules(String bovineId) async {
    try {
      final models = await localDataSource.getFeedingSchedules(bovineId);
      return Right(models);
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, FeedingSchedule>> saveFeedingSchedule(FeedingSchedule schedule) async {
    try {
      final model = FeedingScheduleModel.fromEntity(schedule);
      await localDataSource.saveFeedingSchedule(model);
      return Right(schedule);
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteFeedingSchedule(String scheduleId) async {
    try {
      await localDataSource.deleteFeedingSchedule(scheduleId);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, List<NutritionalAlert>>> getNutritionalAlerts(String bovineId) async {
    try {
      final models = await localDataSource.getNutritionalAlerts(bovineId);
      return Right(models);
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> calculateNutritionalRequirements(String bovineId) async {
    // This logic would heavily depend on the specific nutritional requirements of the cattle
    // For now, we'll return a basic calculation placeholder
    return const Right({
      'energy_mcal': 15.5,
      'protein_g': 900,
      'fiber_g': 3500,
      'status': 'Optimal'
    });
  }
}
