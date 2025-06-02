// lib/data/datasources/remote/dish_remote_datasource.dart

import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../models/dish_model.dart';
import '../../../core/network/api_client.dart';

abstract class DishRemoteDataSource {
  Future<List<DishModel>> getAllDishes({
    int? countryId,
    int? placeId,
    String? search,
    double? minPrice,
    double? maxPrice,
  });

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

  DishRemoteDataSourceImpl({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  @override
  Future<List<DishModel>> getAllDishes({
    int? countryId,
    int? placeId,
    String? search,
    double? minPrice,
    double? maxPrice,
  }) async {
    final query = <String, dynamic>{};
    if (countryId != null) query['country_id'] = countryId;
    if (placeId != null) query['place_id'] = placeId;
    if (search != null && search.isNotEmpty) query['search'] = search;
    if (minPrice != null) query['min_price'] = minPrice;
    if (maxPrice != null) query['max_price'] = maxPrice;

    final response = await _apiClient.get(
      ApiConstants.dishes,
      queryParameters: query,
    );
    final List list = response.data['dishes'] as List;
    return list.map((json) => DishModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<DishModel> getDishById(int id) async {
    final response = await _apiClient.get(ApiConstants.dishById(id));
    final data = response.data['dish'] as Map<String, dynamic>;
    return DishModel.fromJson(data);
  }

  @override
  Future<List<DishModel>> getDishesByCountry(int countryId) async {
    final response = await _apiClient.get(
      ApiConstants.dishes,
      queryParameters: { 'country_id': countryId },
    );

    // 1) Log the raw JSON so we know exactly what it's giving us:
    print("🏷️ [DishRemoteDataSource] raw response.data = ${response.data}");

    // 2) Grab the array under "dishes":
    final raw = response.data;
    if (raw is! Map<String, dynamic> || raw['dishes'] is! List) {
      // If for some reason the payload isn't what we expect, return empty:
      print("⚠️ Unexpected shape: expected a Map with key 'dishes', got: $raw");
      return <DishModel>[];
    }

    final List<dynamic> list = raw['dishes'] as List<dynamic>;
    final List<DishModel> parsed = <DishModel>[];

    for (final item in list) {
      try {
        // Try to cast to Map<String, dynamic> and feed it to the DishModel factory
        final map = item as Map<String, dynamic>;
        parsed.add(DishModel.fromJson(map));
      } catch (e, stack) {
        // Print exactly which JSON chunk and which exception occurred:
        print("❌ [DishParsing] Failed to parse one dish JSON: $item");
        print("    Exception: $e");
        print("    Stack: $stack");
        // (If you want, continue on to the next dish instead of bailing out completely.)
      }
    }

    return parsed;
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
    final response = await _apiClient.post(
      ApiConstants.dishes,
      data: {
        'name': name,
        'country_id': countryId,
        'place_id': placeId,
        if (description != null) 'description': description,
        'price': price,
        if (imageUrl != null) 'image_url': imageUrl,
      },
    );
    final data = response.data['dish'] as Map<String, dynamic>;
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
    final response = await _apiClient.put(
      ApiConstants.dishById(id),
      data: {
        if (name != null) 'name': name,
        if (countryId != null) 'country_id': countryId,
        if (placeId != null) 'place_id': placeId,
        if (description != null) 'description': description,
        if (price != null) 'price': price,
        if (imageUrl != null) 'image_url': imageUrl,
      },
    );
    final data = response.data['dish'] as Map<String, dynamic>;
    return DishModel.fromJson(data);
  }

  @override
  Future<void> deleteDish(int id) async {
    await _apiClient.delete(ApiConstants.dishById(id));
  }
}
