// lib/domain/repositories/visit_repository.dart
import 'package:dartz/dartz.dart';
import '../entities/visit.dart';
import '../../core/errors/failures.dart';

abstract class VisitRepository {
  Future<Either<Failure, List<Visit>>> getUserVisits();
  Future<Either<Failure, Visit>> getVisitById(int id);
  Future<Either<Failure, Map<String, dynamic>>> getVisitStats();
  Future<Either<Failure, Visit>> createVisit({
    required int placeId,
    double? latitude,
    double? longitude,
    String? photoUrl,
  });
  Future<Either<Failure, void>> deleteVisit(int id);
}
