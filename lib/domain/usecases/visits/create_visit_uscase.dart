import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../entities/visit.dart';
import '../../repositories/visit_repository.dart';

/// Parameters for creating a new visit.
class CreateVisitParams {
  final int placeId;
  final double? latitude;
  final double? longitude;
  final String? photoUrl;

  const CreateVisitParams({
    required this.placeId,
    this.latitude,
    this.longitude,
    this.photoUrl,
  });
}

class CreateVisitUseCase {
  final VisitRepository _repository;

  CreateVisitUseCase(this._repository);

  Future<Either<Failure, Visit>> call(CreateVisitParams params) {
    return _repository.createVisit(
      placeId: params.placeId,
      latitude: params.latitude,
      longitude: params.longitude,
      photoUrl: params.photoUrl,
    );
  }
}
