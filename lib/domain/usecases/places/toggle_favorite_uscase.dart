import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../entities/place.dart';
import '../../repositories/place_repository.dart';

/// Parameter for toggling favorite status on a place.
class ToggleFavoriteParams {
  final int id;

  const ToggleFavoriteParams({ required this.id });
}

class ToggleFavoriteUseCase {
  final PlaceRepository _repository;

  ToggleFavoriteUseCase(this._repository);

  Future<Either<Failure, Place>> call(ToggleFavoriteParams params) {
    return _repository.toggleFavorite(params.id);
  }
}
