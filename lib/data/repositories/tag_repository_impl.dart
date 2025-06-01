// lib/data/repositories/tag_repository_impl.dart
import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../data/datasources/remote/tag_remote_datasource.dart';
import '../../data/models/tag_model.dart';
import '../../domain/entities/tag.dart';
import '../../domain/repositories/tag_repository.dart';

class TagRepositoryImpl implements TagRepository {
  final TagRemoteDataSource _remoteDataSource;

  TagRepositoryImpl({required TagRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<Tag>>> getUserTags() async {
    try {
      final models = await _remoteDataSource.getUserTags();
      return Right(models);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (_) {
      return Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, Tag>> getTagById(int id) async {
    try {
      final model = await _remoteDataSource.getTagById(id);
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (_) {
      return Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, List<Tag>>> getTagsByPerson(int personId) async {
    try {
      final models = await _remoteDataSource.getTagsByPerson(personId);
      return Right(models);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (_) {
      return Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, Tag>> createTag({
    required int personId,
    required String comment,
    String? photoUrl,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final model = await _remoteDataSource.createTag(
        personId: personId,
        comment: comment,
        photoUrl: photoUrl,
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
  Future<Either<Failure, Tag>> updateTag({
    required int id,
    String? comment,
    String? photoUrl,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final model = await _remoteDataSource.updateTag(
        id: id,
        comment: comment,
        photoUrl: photoUrl,
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
  Future<Either<Failure, void>> deleteTag(int id) async {
    try {
      await _remoteDataSource.deleteTag(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (_) {
      return Left(UnknownFailure());
    }
  }
}
