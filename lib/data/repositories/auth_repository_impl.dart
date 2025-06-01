// lib/data/repositories/auth_repository_impl.dart
import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../data/datasources/local/auth_local_datasource.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await _remoteDataSource.login(
        email: email,
        password: password,
      );
      // cache token and user info locally
      final token = userModel.token;
      if (token != null) {
        await _localDataSource.cacheAuthToken(token);
      }
      await _localDataSource.cacheUserId(userModel.id);
      await _localDataSource.cacheUserEmail(userModel.email);
      await _localDataSource.cacheUserName(userModel.name);
      await _localDataSource.cacheUserRole(userModel.role);
      return Right(userModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final userModel = await _remoteDataSource.register(
        email: email,
        password: password,
        name: name,
      );
      final token = userModel.token;
      if (token != null) {
        await _localDataSource.cacheAuthToken(token);
      }
      await _localDataSource.cacheUserId(userModel.id);
      await _localDataSource.cacheUserEmail(userModel.email);
      await _localDataSource.cacheUserName(userModel.name);
      await _localDataSource.cacheUserRole(userModel.role);
      return Right(userModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, User>> getProfile() async {
    try {
      final userModel = await _remoteDataSource.getProfile();
      return Right(userModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile({required String name}) async {
    try {
      final userModel = await _remoteDataSource.updateProfile(name: name);
      await _localDataSource.cacheUserName(userModel.name);
      return Right(userModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _localDataSource.clearAuthData();
      return const Right(null);
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, String?>> getAuthToken() async {
    try {
      final token = await _localDataSource.getAuthToken();
      return Right(token);
    } catch (_) {
      return const Left(CacheFailure());
    }
  }
}
