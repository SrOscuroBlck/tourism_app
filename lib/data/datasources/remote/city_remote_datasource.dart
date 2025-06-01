// lib/data/datasources/remote/city_remote_datasource.dart
import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../models/city_model.dart';
import '../../../core/network/api_client.dart';

abstract class CityRemoteDataSource {
  Future<List<CityModel>> getAllCities({int? countryId, String? search});
  Future<CityModel> getCityById(int id);
  Future<CityModel> createCity({required String name, required int countryId, int? population, double? latitude, double? longitude});
  Future<CityModel> updateCity({required int id, String? name, int? countryId, int? population, double? latitude, double? longitude});
  Future<void> deleteCity(int id);
}

class CityRemoteDataSourceImpl implements CityRemoteDataSource {
  final ApiClient _apiClient;

  CityRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<List<CityModel>> getAllCities({int? countryId, String? search}) async {
    final query = <String, dynamic>{};
    if (countryId != null) query['country_id'] = countryId;
    if (search != null && search.isNotEmpty) query['search'] = search;
    final response = await _apiClient.get(ApiConstants.cities, queryParameters: query);
    final List list = response.data['cities'];
    return list.map((json) => CityModel.fromJson(json)).toList();
  }

  @override
  Future<CityModel> getCityById(int id) async {
    final response = await _apiClient.get(ApiConstants.cityById(id));
    final data = response.data['city'];
    return CityModel.fromJson(data);
  }

  @override
  Future<CityModel> createCity({
    required String name,
    required int countryId,
    int? population,
    double? latitude,
    double? longitude,
  }) async {
    final response = await _apiClient.post(ApiConstants.cities, data: {
      'name': name,
      'country_id': countryId,
      if (population != null) 'population': population,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    });
    final data = response.data['city'];
    return CityModel.fromJson(data);
  }

  @override
  Future<CityModel> updateCity({
    required int id,
    String? name,
    int? countryId,
    int? population,
    double? latitude,
    double? longitude,
  }) async {
    final response = await _apiClient.put(ApiConstants.cityById(id), data: {
      if (name != null) 'name': name,
      if (countryId != null) 'country_id': countryId,
      if (population != null) 'population': population,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    });
    final data = response.data['city'];
    return CityModel.fromJson(data);
  }

  @override
  Future<void> deleteCity(int id) async {
    await _apiClient.delete(ApiConstants.cityById(id));
  }
}
