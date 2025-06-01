// lib/data/repositories/city_repository_impl.dart
import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../data/datasources/remote/city_remote_datasource.dart';
import '../../data/models/city_model.dart';
import '../../domain/entities/city.dart';
import '../../domain/repositories/city_repository.dart';

class CityRepositoryImpl implements CityRepository {
  final CityRemoteDataSource _remoteDataSource;

  CityRepositoryImpl({required CityRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<City>>> getAllCities({
    int? countryId,
    String? search,
  }) async {
    try {
      final models = await _remoteDataSource.getAllCities(
        countryId: countryId,
        search: search,
      );
      return Right(models);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (_) {
      return Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, City>> getCityById(int id) async {
    try {
      final model = await _remoteDataSource.getCityById(id);
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (_) {
      return Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, City>> createCity({
    required String name,
    required int countryId,
    int? population,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final model = await _remoteDataSource.createCity(
        name: name,
        countryId: countryId,
        population: population,
        latitude: latitude,
        longitude: longitude,
      );
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (_) {
      return Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, City>> updateCity({
    required int id,
    String? name,
    int? countryId,
    int? population,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final model = await _remoteDataSource.updateCity(
        id: id,
        name: name,
        countryId: countryId,
        population: population,
        latitude: latitude,
        longitude: longitude,
      );
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (_) {
      return Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteCity(int id) async {
    try {
      await _remoteDataSource.deleteCity(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (_) {
      return Left(UnknownFailure());
    }
  }
}
