// lib/domain/repositories/city_repository.dart
import 'package:dartz/dartz.dart';
import '../entities/city.dart';
import '../../core/errors/failures.dart';

abstract class CityRepository {
  Future<Either<Failure, List<City>>> getAllCities({int? countryId, String? search});
  Future<Either<Failure, City>> getCityById(int id);
  Future<Either<Failure, City>> createCity({
    required String name,
    required int countryId,
    int? population,
    double? latitude,
    double? longitude,
  });
  Future<Either<Failure, City>> updateCity({
    required int id,
    String? name,
    int? countryId,
    int? population,
    double? latitude,
    double? longitude,
  });
  Future<Either<Failure, void>> deleteCity(int id);
}
