import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/feeding_schedule.dart';
import '../entities/nutritional_alert.dart';

abstract class FeedingRepository {
  Future<Either<Failure, List<FeedingSchedule>>> getFeedingSchedules(String bovineId);
  Future<Either<Failure, FeedingSchedule>> saveFeedingSchedule(FeedingSchedule schedule);
  Future<Either<Failure, void>> deleteFeedingSchedule(String scheduleId);
  
  Future<Either<Failure, List<NutritionalAlert>>> getNutritionalAlerts(String bovineId);
  Future<Either<Failure, Map<String, dynamic>>> calculateNutritionalRequirements(String bovineId);
}
