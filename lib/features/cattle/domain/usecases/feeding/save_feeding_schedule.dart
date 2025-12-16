import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../../repositories/feeding_repository.dart';
import '../../entities/feeding_schedule.dart';

class SaveFeedingSchedule {
  final FeedingRepository repository;

  SaveFeedingSchedule(this.repository);

  Future<Either<Failure, FeedingSchedule>> call(FeedingSchedule schedule) async {
    return await repository.saveFeedingSchedule(schedule);
  }
}
