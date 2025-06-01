import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../entities/visit.dart';
import '../../repositories/visit_repository.dart';

/// No parameters needed; fetch all visits for the current user.
class GetUserVisitsUseCase {
  final VisitRepository _repository;

  GetUserVisitsUseCase(this._repository);

  Future<Either<Failure, List<Visit>>> call() {
    return _repository.getUserVisits();
  }
}
