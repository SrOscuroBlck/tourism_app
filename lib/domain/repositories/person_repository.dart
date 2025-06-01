// lib/domain/repositories/person_repository.dart
import 'package:dartz/dartz.dart';
import '../entities/person.dart';
import '../../core/errors/failures.dart';

abstract class PersonRepository {
  Future<Either<Failure, List<Person>>> getAllPeople({
    int? countryId,
    int? cityId,
    String? category,
    String? search,
  });
  Future<Either<Failure, Person>> getPersonById(int id);
  Future<Either<Failure, List<Map<String, dynamic>>>> getPeopleByCategory({int? countryId});
  Future<Either<Failure, Person>> createPerson({
    required String name,
    required int cityId,
    required int countryId,
    required String category,
    String? birthDate,
    String? biography,
    String? imageUrl,
  });
  Future<Either<Failure, Person>> updatePerson({
    required int id,
    String? name,
    int? cityId,
    int? countryId,
    String? category,
    String? birthDate,
    String? biography,
    String? imageUrl,
  });
  Future<Either<Failure, void>> deletePerson(int id);
}
