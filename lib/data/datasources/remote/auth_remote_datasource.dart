// lib/data/datasources/remote/auth_remote_datasource.dart
import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../models/user_model.dart';
import '../../../core/network/api_client.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> register({required String email, required String password, required String name});
  Future<UserModel> getProfile();
  Future<UserModel> updateProfile({required String name});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<UserModel> login({required String email, required String password}) async {
    final response = await _apiClient.post(ApiConstants.login, data: {
      'email': email,
      'password': password,
    });
    final data = response.data['user'];
    final token = response.data['token'];
    return UserModel.fromJson({
      ...data,
      'token': token,
    });
  }

  @override
  Future<UserModel> register({required String email, required String password, required String name}) async {
    final response = await _apiClient.post(ApiConstants.register, data: {
      'email': email,
      'password': password,
      'name': name,
    });
    final data = response.data['user'];
    final token = response.data['token'];
    return UserModel.fromJson({
      ...data,
      'token': token,
    });
  }

  @override
  Future<UserModel> getProfile() async {
    final response = await _apiClient.get(ApiConstants.profile);
    final data = response.data['user'];
    return UserModel.fromJson(data);
  }

  @override
  Future<UserModel> updateProfile({required String name}) async {
    final response = await _apiClient.put(ApiConstants.profile, data: {
      'name': name,
    });
    final data = response.data['user'];
    return UserModel.fromJson(data);
  }
}
