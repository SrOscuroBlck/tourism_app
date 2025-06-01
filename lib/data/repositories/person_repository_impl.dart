// lib/data/repositories/person_repository_impl.dart
import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../data/datasources/remote/person_remote_datasource.dart';
import '../../data/models/person_model.dart';
import '../../domain/entities/person.dart';
import '../../domain/repositories/person_repository.dart';

class PersonRepositoryImpl implements PersonRepository {
  final PersonRemoteDataSource _remoteDataSource;

  PersonRepositoryImpl({required PersonRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<Person>>> getAllPeople({
    int? countryId,
    int? cityId,
    String? category,
    String? search,
  }) async {
    try {
      final models = await _remoteDataSource.getAllPeople(
        countryId: countryId,
        cityId: cityId,
        category: category,
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
  Future<Either<Failure, Person>> getPersonById(int id) async {
    try {
      final model = await _remoteDataSource.getPersonById(id);
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (_) {
      return Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getPeopleByCategory({int? countryId}) async {
    try {
      final categories = await _remoteDataSource.getPeopleByCategory(countryId: countryId);
      return Right(categories);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (_) {
      return Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, Person>> createPerson({
    required String name,
    required int cityId,
    required int countryId,
    required String category,
    String? birthDate,
    String? biography,
    String? imageUrl,
  }) async {
    try {
      final model = await _remoteDataSource.createPerson(
        name: name,
        cityId: cityId,
        countryId: countryId,
        category: category,
        birthDate: birthDate,
        biography: biography,
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
  Future<Either<Failure, Person>> updatePerson({
    required int id,
    String? name,
    int? cityId,
    int? countryId,
    String? category,
    String? birthDate,
    String? biography,
    String? imageUrl,
  }) async {
    try {
      final model = await _remoteDataSource.updatePerson(
        id: id,
        name: name,
        cityId: cityId,
        countryId: countryId,
        category: category,
        birthDate: birthDate,
        biography: biography,
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
  Future<Either<Failure, void>> deletePerson(int id) async {
    try {
      await _remoteDataSource.deletePerson(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (_) {
      return Left(UnknownFailure());
    }
  }
}
