// lib/domain/repositories/auth_repository.dart
import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import '../../core/errors/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login({required String email, required String password});
  Future<Either<Failure, User>> register({required String email, required String password, required String name});
  Future<Either<Failure, User>> getProfile();
  Future<Either<Failure, User>> updateProfile({required String name});
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, String?>> getAuthToken();
}
