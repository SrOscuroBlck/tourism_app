import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../entities/place.dart';
import '../../repositories/place_repository.dart';

/// Parameters for fetching a list of places, optionally filtered.
class PlacesParams {
  final int? countryId;
  final int? cityId;
  final String? type;
  final String? search;

  const PlacesParams({
    this.countryId,
    this.cityId,
    this.type,
    this.search,
  });
}

class GetPlacesUseCase {
  final PlaceRepository _repository;

  GetPlacesUseCase(this._repository);

  Future<Either<Failure, List<Place>>> call(PlacesParams params) {
    return _repository.getAllPlaces(
      countryId: params.countryId,
      cityId: params.cityId,
      type: params.type,
      search: params.search,
    );
  }
}
