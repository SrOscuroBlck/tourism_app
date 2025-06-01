// lib/data/repositories/country_repository_impl.dart
import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../data/datasources/remote/country_remote_datasource.dart';
import '../../data/models/country_model.dart';
import '../../domain/entities/country.dart';
import '../../domain/repositories/country_repository.dart';

class CountryRepositoryImpl implements CountryRepository {
  final CountryRemoteDataSource _remoteDataSource;

  CountryRepositoryImpl({required CountryRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<Country>>> getAllCountries() async {
    try {
      final models = await _remoteDataSource.getAllCountries();
      return Right(models);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (_) {
      return Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, Country>> getCountryById(int id) async {
    try {
      final model = await _remoteDataSource.getCountryById(id);
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (_) {
      return Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, Country>> createCountry({
    required String name,
    int? population,
    required String continent,
  }) async {
    try {
      final model = await _remoteDataSource.createCountry(
        name: name,
        population: population,
        continent: continent,
      );
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (_) {
      return Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, Country>> updateCountry({
    required int id,
    String? name,
    int? population,
    String? continent,
  }) async {
    try {
      final model = await _remoteDataSource.updateCountry(
        id: id,
        name: name,
        population: population,
        continent: continent,
      );
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (_) {
      return Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteCountry(int id) async {
    try {
      await _remoteDataSource.deleteCountry(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (_) {
      return Left(UnknownFailure());
    }
  }
}
