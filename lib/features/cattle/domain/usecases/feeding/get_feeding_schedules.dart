import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../../repositories/feeding_repository.dart';
import '../../entities/feeding_schedule.dart';

class GetFeedingSchedules {
  final FeedingRepository repository;

  GetFeedingSchedules(this.repository);

  Future<Either<Failure, List<FeedingSchedule>>> call(String bovineId) async {
    return await repository.getFeedingSchedules(bovineId);
  }
}
