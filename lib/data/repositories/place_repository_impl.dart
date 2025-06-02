// lib/data/repositories/place_repository_impl.dart

import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../data/datasources/remote/place_remote_datasource.dart';
import '../../data/models/place_model.dart';
import '../../domain/entities/place.dart';
import '../../domain/repositories/place_repository.dart';

class PlaceRepositoryImpl implements PlaceRepository {
  final PlaceRemoteDataSource _remoteDataSource;

  PlaceRepositoryImpl({required PlaceRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<Place>>> getAllPlaces({
    int? countryId,
    int? cityId,
    String? type,
    String? search,
  }) async {
    try {
      final models = await _remoteDataSource.getAllPlaces(
        countryId: countryId,
        cityId: cityId,
        type: type,
        search: search,
      );
      return Right(models);
    } on ServerException catch (e) {
      // Propagate the server exception's message
      return Left(ServerFailure(message: e.message));
    } catch (e, stack) {
      // Catch any other exception and wrap its text into a ServerFailure
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Place>> getPlaceById(int id) async {
    try {
      final model = await _remoteDataSource.getPlaceById(id);
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e, stack) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Place>> toggleFavorite(int id) async {
    try {
      final model = await _remoteDataSource.toggleFavorite(id);
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e, stack) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Place>>> getTopVisitedPlaces({
    int? countryId,
    int limit = 10,
  }) async {
    try {
      final models = await _remoteDataSource.getTopVisitedPlaces(
        countryId: countryId,
        limit: limit,
      );
      return Right(models);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e, stack) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
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
  }) async {
    try {
      final model = await _remoteDataSource.createPlace(
        name: name,
        cityId: cityId,
        countryId: countryId,
        type: type,
        address: address,
        latitude: latitude,
        longitude: longitude,
        description: description,
        imageUrl: imageUrl,
      );
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e, stack) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
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
  }) async {
    try {
      final model = await _remoteDataSource.updatePlace(
        id: id,
        name: name,
        cityId: cityId,
        countryId: countryId,
        type: type,
        address: address,
        latitude: latitude,
        longitude: longitude,
        description: description,
        imageUrl: imageUrl,
      );
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e, stack) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePlace(int id) async {
    try {
      await _remoteDataSource.deletePlace(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e, stack) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
