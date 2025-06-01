// lib/data/datasources/remote/dish_remote_datasource.dart
import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../models/dish_model.dart';
import '../../../core/network/api_client.dart';

abstract class DishRemoteDataSource {
  Future<List<DishModel>> getAllDishes({int? countryId, int? placeId, String? search, double? minPrice, double? maxPrice});
  Future<DishModel> getDishById(int id);
  Future<List<DishModel>> getDishesByCountry(int countryId);
  Future<DishModel> createDish({
    required String name,
    required int countryId,
    required int placeId,
    String? description,
    required double price,
    String? imageUrl,
  });
  Future<DishModel> updateDish({
    required int id,
    String? name,
    int? countryId,
    int? placeId,
    String? description,
    double? price,
    String? imageUrl,
  });
  Future<void> deleteDish(int id);
}

class DishRemoteDataSourceImpl implements DishRemoteDataSource {
  final ApiClient _apiClient;

  DishRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<List<DishModel>> getAllDishes({int? countryId, int? placeId, String? search, double? minPrice, double? maxPrice}) async {
    final query = <String, dynamic>{};
    if (countryId != null) query['country_id'] = countryId;
    if (placeId != null) query['place_id'] = placeId;
    if (search != null && search.isNotEmpty) query['search'] = search;
    if (minPrice != null) query['min_price'] = minPrice;
    if (maxPrice != null) query['max_price'] = maxPrice;
    final response = await _apiClient.get(ApiConstants.dishes, queryParameters: query);
    final List list = response.data['dishes'];
    return list.map((json) => DishModel.fromJson(json)).toList();
  }

  @override
  Future<DishModel> getDishById(int id) async {
    final response = await _apiClient.get(ApiConstants.dishById(id));
    final data = response.data['dish'];
    return DishModel.fromJson(data);
  }

  @override
  Future<List<DishModel>> getDishesByCountry(int countryId) async {
    final response = await _apiClient.get(ApiConstants.dishesByCountry(countryId));
    final List list = response.data['dishes'];
    return list.map((json) => DishModel.fromJson(json)).toList();
  }

  @override
  Future<DishModel> createDish({
    required String name,
    required int countryId,
    required int placeId,
    String? description,
    required double price,
    String? imageUrl,
  }) async {
    final response = await _apiClient.post(ApiConstants.dishes, data: {
      'name': name,
      'country_id': countryId,
      'place_id': placeId,
      if (description != null) 'description': description,
      'price': price,
      if (imageUrl != null) 'image_url': imageUrl,
    });
    final data = response.data['dish'];
    return DishModel.fromJson(data);
  }

  @override
  Future<DishModel> updateDish({
    required int id,
    String? name,
    int? countryId,
    int? placeId,
    String? description,
    double? price,
    String? imageUrl,
  }) async {
    final response = await _apiClient.put(ApiConstants.dishById(id), data: {
      if (name != null) 'name': name,
      if (countryId != null) 'country_id': countryId,
      if (placeId != null) 'place_id': placeId,
      if (description != null) 'description': description,
      if (price != null) 'price': price,
      if (imageUrl != null) 'image_url': imageUrl,
    });
    final data = response.data['dish'];
    return DishModel.fromJson(data);
  }

  @override
  Future<void> deleteDish(int id) async {
    await _apiClient.delete(ApiConstants.dishById(id));
  }
}
