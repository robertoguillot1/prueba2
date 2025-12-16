import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../../repositories/feeding_repository.dart';

class CalculateNutritionalRequirements {
  final FeedingRepository repository;

  CalculateNutritionalRequirements(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(String bovineId) async {
    return await repository.calculateNutritionalRequirements(bovineId);
  }
}
