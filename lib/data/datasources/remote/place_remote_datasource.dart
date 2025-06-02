// lib/data/datasources/remote/place_remote_datasource.dart
import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../models/place_model.dart';
import '../../../core/network/api_client.dart';

abstract class PlaceRemoteDataSource {
  Future<List<PlaceModel>> getAllPlaces({int? countryId, int? cityId, String? type, String? search});
  Future<PlaceModel> getPlaceById(int id);
  Future<PlaceModel> toggleFavorite(int id);
  Future<List<PlaceModel>> getTopVisitedPlaces({int? countryId, int limit});
  Future<PlaceModel> createPlace({
    required String name,
    required int cityId,
    required int countryId,
    required String type,
    String? address,
    double? latitude,
    double? longitude,
    String? description,
    String? imageUrl,
  });
  Future<PlaceModel> updatePlace({
    required int id,
    String? name,
    int? cityId,
    int? countryId,
    String? type,
    String? address,
    double? latitude,
    double? longitude,
    String? description,
    String? imageUrl,
  });
  Future<void> deletePlace(int id);
}

class PlaceRemoteDataSourceImpl implements PlaceRemoteDataSource {
  final ApiClient _apiClient;

  PlaceRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<List<PlaceModel>> getAllPlaces({int? countryId, int? cityId, String? type, String? search}) async {
    final query = <String, dynamic>{};
    if (countryId != null) query['country_id'] = countryId;
    if (cityId != null) query['city_id'] = cityId;
    if (type != null && type.isNotEmpty) query['type'] = type;
    if (search != null && search.isNotEmpty) query['search'] = search;
    final response = await _apiClient.get(ApiConstants.places, queryParameters: query);
    final List list = response.data['places'];
    return list.map((json) => PlaceModel.fromJson(json)).toList();
  }

  @override
  Future<PlaceModel> getPlaceById(int id) async {
    final response = await _apiClient.get(ApiConstants.placeById(id));
    final data = response.data['place'];
    return PlaceModel.fromJson(data);
  }

  @override
  Future<PlaceModel> toggleFavorite(int id) async {
    final response = await _apiClient.post(ApiConstants.toggleFavorite(id));
    final data = response.data;

    // FIXED: Handle the backend response properly
    // Backend returns: {"message": "...", "isFavorite": true/false}
    // We need to return a minimal place with just the ID and favorite status

    if (data['place'] != null) {
      // If backend sends full place data, use it
      return PlaceModel.fromJson(data['place']);
    } else {
      // If backend only sends favorite status, create minimal place object
      final bool isFavorite = data['isFavorite'] ?? false;

      // Create a minimal place model with just the essential data
      // The bloc will merge this with the existing place data
      return PlaceModel(
        id: id,
        name: '', // Will be overridden by bloc
        cityId: 0, // Will be overridden by bloc
        countryId: 0, // Will be overridden by bloc
        type: '', // Will be overridden by bloc
        isFavorite: isFavorite, // This is the important field
      );
    }
  }

  @override
  Future<List<PlaceModel>> getTopVisitedPlaces({int? countryId, int limit = 10}) async {
    final query = <String, dynamic>{'limit': limit};
    if (countryId != null) query['country_id'] = countryId;
    final response = await _apiClient.get(ApiConstants.topVisitedPlaces, queryParameters: query);
    final List list = response.data['places'];
    return list.map((json) => PlaceModel.fromJson(json)).toList();
  }

  @override
  Future<PlaceModel> createPlace({
    required String name,
    required int cityId,
    required int countryId,
    required String type,
    String? address,
    double? latitude,
    double? longitude,
    String? description,
    String? imageUrl,
  }) async {
    final response = await _apiClient.post(ApiConstants.places, data: {
      'name': name,
      'city_id': cityId,
      'country_id': countryId,
      'type': type,
      if (address != null) 'address': address,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (description != null) 'description': description,
      if (imageUrl != null) 'image_url': imageUrl,
    });
    final data = response.data['place'];
    return PlaceModel.fromJson(data);
  }

  @override
  Future<PlaceModel> updatePlace({
    required int id,
    String? name,
    int? cityId,
    int? countryId,
    String? type,
    String? address,
    double? latitude,
    double? longitude,
    String? description,
    String? imageUrl,
  }) async {
    final response = await _apiClient.put(ApiConstants.placeById(id), data: {
      if (name != null) 'name': name,
      if (cityId != null) 'city_id': cityId,
      if (countryId != null) 'country_id': countryId,
      if (type != null) 'type': type,
      if (address != null) 'address': address,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (description != null) 'description': description,
      if (imageUrl != null) 'image_url': imageUrl,
    });
    final data = response.data['place'];
    return PlaceModel.fromJson(data);
  }

  @override
  Future<void> deletePlace(int id) async {
    await _apiClient.delete(ApiConstants.placeById(id));
  }
}