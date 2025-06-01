import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../entities/place.dart';
import '../../repositories/place_repository.dart';

/// Parameter for fetching a single place’s details.
class PlaceIdParams {
  final int id;

  const PlaceIdParams({ required this.id });
}

class GetPlaceDetailUseCase {
  final PlaceRepository _repository;

  GetPlaceDetailUseCase(this._repository);

  Future<Either<Failure, Place>> call(PlaceIdParams params) {
    return _repository.getPlaceById(params.id);
  }
}
