// lib/data/datasources/remote/person_remote_datasource.dart

import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../models/person_model.dart';
import '../../../core/network/api_client.dart';

abstract class PersonRemoteDataSource {
  Future<List<PersonModel>> getAllPeople({
    int? countryId,
    int? cityId,
    String? category,
    String? search,
  });

  Future<PersonModel> getPersonById(int id);

  Future<List<Map<String, dynamic>>> getPeopleByCategory({
    int? countryId,
  });

  Future<PersonModel> createPerson({
    required String name,
    required int cityId,
    required int countryId,
    required String category,
    String? birthDate,
    String? biography,
    String? imageUrl,
  });

  Future<PersonModel> updatePerson({
    required int id,
    String? name,
    int? cityId,
    int? countryId,
    String? category,
    String? birthDate,
    String? biography,
    String? imageUrl,
  });

  Future<void> deletePerson(int id);
}

class PersonRemoteDataSourceImpl implements PersonRemoteDataSource {
  final ApiClient _apiClient;

  PersonRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<PersonModel>> getAllPeople({
    int? countryId,
    int? cityId,
    String? category,
    String? search,
  }) async {
    final query = <String, dynamic>{};
    if (countryId != null) query['country_id'] = countryId;
    if (cityId != null) query['city_id'] = cityId;
    if (category != null && category.isNotEmpty) query['category'] = category;
    if (search != null && search.isNotEmpty) query['search'] = search;

    final response = await _apiClient.get(
      ApiConstants.people,
      queryParameters: query,
    );

    // 1) Log the raw JSON so we can inspect it.
    print("🏷️ [PersonRemoteDataSource] raw response.data = ${response.data}");

    final rawData = response.data;
    if (rawData is! Map<String, dynamic> || rawData['people'] is! List) {
      // If shape is not what we expect, log a warning and return an empty list.
      print(
          "⚠️ [PersonRemoteDataSource] Unexpected JSON shape: expected a Map with key 'people', got: $rawData");
      return <PersonModel>[];
    }

    final List<dynamic> list = rawData['people'] as List<dynamic>;
    final List<PersonModel> parsed = <PersonModel>[];

    for (final item in list) {
      try {
        final map = item as Map<String, dynamic>;
        parsed.add(PersonModel.fromJson(map));
      } catch (e, stack) {
        print("❌ [PersonParsing] Failed to parse one person JSON: $item");
        print("    Exception: $e");
        print("    Stack: $stack");
        // Decide if you want to continue or rethrow. Here we continue.
      }
    }

    return parsed;
  }

  @override
  Future<PersonModel> getPersonById(int id) async {
    final response = await _apiClient.get(ApiConstants.personById(id));
    final data = response.data['person'];
    return PersonModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<List<Map<String, dynamic>>> getPeopleByCategory({
    int? countryId,
  }) async {
    final query = <String, dynamic>{};
    if (countryId != null) query['country_id'] = countryId;

    final response = await _apiClient.get(
      ApiConstants.peopleByCategory,
      queryParameters: query,
    );

    // We expect something like: { "categories": [ { "category": "Actor", ... }, ... ] }
    final raw = response.data;
    if (raw is! Map<String, dynamic> || raw['categories'] is! List) {
      print(
          "⚠️ [PersonRemoteDataSource.getPeopleByCategory] Unexpected JSON shape: $raw");
      return <Map<String, dynamic>>[];
    }

    // Cast each element to Map<String, dynamic>
    final List<dynamic> list = raw['categories'] as List<dynamic>;
    return list
        .map((e) => e as Map<String, dynamic>)
        .toList(growable: false);
  }

  @override
  Future<PersonModel> createPerson({
    required String name,
    required int cityId,
    required int countryId,
    required String category,
    String? birthDate,
    String? biography,
    String? imageUrl,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.people,
      data: {
        'name': name,
        'city_id': cityId,
        'country_id': countryId,
        'category': category,
        if (birthDate != null) 'birth_date': birthDate,
        if (biography != null) 'biography': biography,
        if (imageUrl != null) 'image_url': imageUrl,
      },
    );
    final data = response.data['person'] as Map<String, dynamic>;
    return PersonModel.fromJson(data);
  }

  @override
  Future<PersonModel> updatePerson({
    required int id,
    String? name,
    int? cityId,
    int? countryId,
    String? category,
    String? birthDate,
    String? biography,
    String? imageUrl,
  }) async {
    final response = await _apiClient.put(
      ApiConstants.personById(id),
      data: {
        if (name != null) 'name': name,
        if (cityId != null) 'city_id': cityId,
        if (countryId != null) 'country_id': countryId,
        if (category != null) 'category': category,
        if (birthDate != null) 'birth_date': birthDate,
        if (biography != null) 'biography': biography,
        if (imageUrl != null) 'image_url': imageUrl,
      },
    );
    final data = response.data['person'] as Map<String, dynamic>;
    return PersonModel.fromJson(data);
  }

  @override
  Future<void> deletePerson(int id) async {
    await _apiClient.delete(ApiConstants.personById(id));
  }
}
