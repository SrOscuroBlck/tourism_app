// lib/domain/repositories/dish_repository.dart
import 'package:dartz/dartz.dart';
import '../entities/dish.dart';
import '../../core/errors/failures.dart';

abstract class DishRepository {
  Future<Either<Failure, List<Dish>>> getAllDishes({
    int? countryId,
    int? placeId,
    String? search,
    double? minPrice,
    double? maxPrice,
  });
  Future<Either<Failure, Dish>> getDishById(int id);
  Future<Either<Failure, List<Dish>>> getDishesByCountry(int countryId);
  Future<Either<Failure, Dish>> createDish({
    required String name,
    required int countryId,
    required int placeId,
    String? description,
    required double price,
    String? imageUrl,
  });
  Future<Either<Failure, Dish>> updateDish({
    required int id,
    String? name,
    int? countryId,
    int? placeId,
    String? description,
    double? price,
    String? imageUrl,
  });
  Future<Either<Failure, void>> deleteDish(int id);
}
