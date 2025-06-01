// lib/data/datasources/remote/visit_remote_datasource.dart
import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../models/visit_model.dart';
import '../../../core/network/api_client.dart';

abstract class VisitRemoteDataSource {
  Future<List<VisitModel>> getUserVisits();
  Future<VisitModel> getVisitById(int id);
  Future<Map<String, dynamic>> getVisitStats();
  Future<VisitModel> createVisit({
    required int placeId,
    double? latitude,
    double? longitude,
    String? photoUrl,
  });
  Future<void> deleteVisit(int id);
}

class VisitRemoteDataSourceImpl implements VisitRemoteDataSource {
  final ApiClient _apiClient;

  VisitRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<List<VisitModel>> getUserVisits() async {
    final response = await _apiClient.get(ApiConstants.visits);
    final List list = response.data['visits'];
    return list.map((json) => VisitModel.fromJson(json)).toList();
  }

  @override
  Future<VisitModel> getVisitById(int id) async {
    final response = await _apiClient.get(ApiConstants.visitById(id));
    final data = response.data['visit'];
    return VisitModel.fromJson(data);
  }

  @override
  Future<Map<String, dynamic>> getVisitStats() async {
    final response = await _apiClient.get(ApiConstants.visitStats);
    return Map<String, dynamic>.from(response.data['stats']);
  }

  @override
  Future<VisitModel> createVisit({
    required int placeId,
    double? latitude,
    double? longitude,
    String? photoUrl,
  }) async {
    final response = await _apiClient.post(ApiConstants.visits, data: {
      'place_id': placeId,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (photoUrl != null) 'photo_url': photoUrl,
    });
    final data = response.data['visit'];
    return VisitModel.fromJson(data);
  }

  @override
  Future<void> deleteVisit(int id) async {
    await _apiClient.delete(ApiConstants.visitById(id));
  }
}
