// lib/domain/repositories/place_repository.dart
import 'package:dartz/dartz.dart';
import '../entities/place.dart';
import '../../core/errors/failures.dart';

abstract class PlaceRepository {
  Future<Either<Failure, List<Place>>> getAllPlaces({
    int? countryId,
    int? cityId,
    String? type,
    String? search,
  });
  Future<Either<Failure, Place>> getPlaceById(int id);
  Future<Either<Failure, Place>> toggleFavorite(int id);
  Future<Either<Failure, List<Place>>> getTopVisitedPlaces({
    int? countryId,
    int limit,
  });
  Future<Either<Failure, Place>> createPlace({
    required String name,
    required int cityId,
    required int countryId,
    required String type,
    String? address,
    double? latitude,
    double? longitude,
    String? description,
    String? imageUrl,
  });
  Future<Either<Failure, Place>> updatePlace({
    required int id,
    String? name,
    int? cityId,
    int? countryId,
    String? type,
    String? address,
    double? latitude,
    double? longitude,
    String? description,
    String? imageUrl,
  });
  Future<Either<Failure, void>> deletePlace(int id);

  Future<Either<Failure, bool>> checkIsFavorite(int id);
}