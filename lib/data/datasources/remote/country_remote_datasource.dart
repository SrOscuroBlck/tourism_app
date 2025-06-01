// lib/data/datasources/remote/country_remote_datasource.dart
import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../models/country_model.dart';
import '../../../core/network/api_client.dart';

abstract class CountryRemoteDataSource {
  Future<List<CountryModel>> getAllCountries();
  Future<CountryModel> getCountryById(int id);
  Future<CountryModel> createCountry({required String name, int? population, required String continent});
  Future<CountryModel> updateCountry({required int id, String? name, int? population, String? continent});
  Future<void> deleteCountry(int id);
}

class CountryRemoteDataSourceImpl implements CountryRemoteDataSource {
  final ApiClient _apiClient;

  CountryRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<List<CountryModel>> getAllCountries() async {
    final response = await _apiClient.get(ApiConstants.countries);
    final List list = response.data['countries'];
    return list.map((json) => CountryModel.fromJson(json)).toList();
  }

  @override
  Future<CountryModel> getCountryById(int id) async {
    final response = await _apiClient.get(ApiConstants.countryById(id));
    final data = response.data['country'];
    return CountryModel.fromJson(data);
  }

  @override
  Future<CountryModel> createCountry({required String name, int? population, required String continent}) async {
    final response = await _apiClient.post(ApiConstants.countries, data: {
      'name': name,
      if (population != null) 'population': population,
      'continent': continent,
    });
    final data = response.data['country'];
    return CountryModel.fromJson(data);
  }

  @override
  Future<CountryModel> updateCountry({required int id, String? name, int? population, String? continent}) async {
    final response = await _apiClient.put(ApiConstants.countryById(id), data: {
      if (name != null) 'name': name,
      if (population != null) 'population': population,
      if (continent != null) 'continent': continent,
    });
    final data = response.data['country'];
    return CountryModel.fromJson(data);
  }

  @override
  Future<void> deleteCountry(int id) async {
    await _apiClient.delete(ApiConstants.countryById(id));
  }
}
