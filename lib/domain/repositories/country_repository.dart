// lib/domain/repositories/country_repository.dart
import 'package:dartz/dartz.dart';
import '../entities/country.dart';
import '../../core/errors/failures.dart';

abstract class CountryRepository {
  Future<Either<Failure, List<Country>>> getAllCountries();
  Future<Either<Failure, Country>> getCountryById(int id);
  Future<Either<Failure, Country>> createCountry({
    required String name,
    int? population,
    required String continent,
  });
  Future<Either<Failure, Country>> updateCountry({
    required int id,
    String? name,
    int? population,
    String? continent,
  });
  Future<Either<Failure, void>> deleteCountry(int id);
}
