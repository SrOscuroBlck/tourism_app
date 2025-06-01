// lib/data/repositories/visit_repository_impl.dart
import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../data/datasources/remote/visit_remote_datasource.dart';
import '../../data/models/visit_model.dart';
import '../../domain/entities/visit.dart';
import '../../domain/repositories/visit_repository.dart';

class VisitRepositoryImpl implements VisitRepository {
  final VisitRemoteDataSource _remoteDataSource;

  VisitRepositoryImpl({required VisitRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<Visit>>> getUserVisits() async {
    try {
      final models = await _remoteDataSource.getUserVisits();
      return Right(models);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (_) {
      return Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, Visit>> getVisitById(int id) async {
    try {
      final model = await _remoteDataSource.getVisitById(id);
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (_) {
      return Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getVisitStats() async {
    try {
      final stats = await _remoteDataSource.getVisitStats();
      return Right(stats);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (_) {
      return Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, Visit>> createVisit({
    required int placeId,
    double? latitude,
    double? longitude,
    String? photoUrl,
  }) async {
    try {
      final model = await _remoteDataSource.createVisit(
        placeId: placeId,
        latitude: latitude,
        longitude: longitude,
        photoUrl: photoUrl,
      );
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (_) {
      return Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteVisit(int id) async {
    try {
      await _remoteDataSource.deleteVisit(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (_) {
      return Left(UnknownFailure());
    }
  }
}
