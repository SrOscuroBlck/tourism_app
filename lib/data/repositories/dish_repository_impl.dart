// lib/data/repositories/dish_repository_impl.dart
import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../data/datasources/remote/dish_remote_datasource.dart';
import '../../data/models/dish_model.dart';
import '../../domain/entities/dish.dart';
import '../../domain/repositories/dish_repository.dart';

class DishRepositoryImpl implements DishRepository {
  final DishRemoteDataSource _remoteDataSource;

  DishRepositoryImpl({required DishRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<Dish>>> getAllDishes({
    int? countryId,
    int? placeId,
    String? search,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      final models = await _remoteDataSource.getAllDishes(
        countryId: countryId,
        placeId: placeId,
        search: search,
        minPrice: minPrice,
        maxPrice: maxPrice,
      );
      return Right(models);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (_) {
      return Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, Dish>> getDishById(int id) async {
    try {
      final model = await _remoteDataSource.getDishById(id);
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (_) {
      return Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, List<Dish>>> getDishesByCountry(int countryId) async {
    try {
      final models = await _remoteDataSource.getDishesByCountry(countryId);
      return Right(models);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (_) {
      return Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, Dish>> createDish({
    required String name,
    required int countryId,
    required int placeId,
    String? description,
    required double price,
    String? imageUrl,
  }) async {
    try {
      final model = await _remoteDataSource.createDish(
        name: name,
        countryId: countryId,
        placeId: placeId,
        description: description,
        price: price,
        imageUrl: imageUrl,
      );
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (_) {
      return Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, Dish>> updateDish({
    required int id,
    String? name,
    int? countryId,
    int? placeId,
    String? description,
    double? price,
    String? imageUrl,
  }) async {
    try {
      final model = await _remoteDataSource.updateDish(
        id: id,
        name: name,
        countryId: countryId,
        placeId: placeId,
        description: description,
        price: price,
        imageUrl: imageUrl,
      );
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (_) {
      return Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteDish(int id) async {
    try {
      await _remoteDataSource.deleteDish(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (_) {
      return Left(UnknownFailure());
    }
  }
}
