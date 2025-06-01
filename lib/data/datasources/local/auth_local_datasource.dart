// lib/data/datasources/local/auth_local_datasource.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/constants/storage_constants.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheAuthToken(String token);
  Future<String?> getAuthToken();
  Future<void> cacheUserId(int id);
  Future<int?> getUserId();
  Future<void> cacheUserEmail(String email);
  Future<String?> getUserEmail();
  Future<void> cacheUserName(String name);
  Future<String?> getUserName();
  Future<void> cacheUserRole(String role);
  Future<String?> getUserRole();
  Future<void> clearAuthData();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage _secureStorage;

  AuthLocalDataSourceImpl({required FlutterSecureStorage secureStorage}) : _secureStorage = secureStorage;

  @override
  Future<void> cacheAuthToken(String token) async {
    await _secureStorage.write(key: StorageConstants.authToken, value: token);
  }

  @override
  Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: StorageConstants.authToken);
  }

  @override
  Future<void> cacheUserId(int id) async {
    await _secureStorage.write(key: StorageConstants.userId, value: id.toString());
  }

  @override
  Future<int?> getUserId() async {
    final value = await _secureStorage.read(key: StorageConstants.userId);
    return value != null ? int.tryParse(value) : null;
  }

  @override
  Future<void> cacheUserEmail(String email) async {
    await _secureStorage.write(key: StorageConstants.userEmail, value: email);
  }

  @override
  Future<String?> getUserEmail() async {
    return await _secureStorage.read(key: StorageConstants.userEmail);
  }

  @override
  Future<void> cacheUserName(String name) async {
    await _secureStorage.write(key: StorageConstants.userName, value: name);
  }

  @override
  Future<String?> getUserName() async {
    return await _secureStorage.read(key: StorageConstants.userName);
  }

  @override
  Future<void> cacheUserRole(String role) async {
    await _secureStorage.write(key: StorageConstants.userRole, value: role);
  }

  @override
  Future<String?> getUserRole() async {
    return await _secureStorage.read(key: StorageConstants.userRole);
  }

  @override
  Future<void> clearAuthData() async {
    await _secureStorage.deleteAll();
  }
}
