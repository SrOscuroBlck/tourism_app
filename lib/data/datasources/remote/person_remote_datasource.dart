// lib/data/datasources/remote/person_remote_datasource.dart
import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../models/person_model.dart';
import '../../../core/network/api_client.dart';

abstract class PersonRemoteDataSource {
  Future<List<PersonModel>> getAllPeople({int? countryId, int? cityId, String? category, String? search});
  Future<PersonModel> getPersonById(int id);
  Future<List<Map<String, dynamic>>> getPeopleByCategory({int? countryId});
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

  PersonRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<List<PersonModel>> getAllPeople({int? countryId, int? cityId, String? category, String? search}) async {
    final query = <String, dynamic>{};
    if (countryId != null) query['country_id'] = countryId;
    if (cityId != null) query['city_id'] = cityId;
    if (category != null && category.isNotEmpty) query['category'] = category;
    if (search != null && search.isNotEmpty) query['search'] = search;
    final response = await _apiClient.get(ApiConstants.people, queryParameters: query);
    final List list = response.data['people'];
    return list.map((json) => PersonModel.fromJson(json)).toList();
  }

  @override
  Future<PersonModel> getPersonById(int id) async {
    final response = await _apiClient.get(ApiConstants.personById(id));
    final data = response.data['person'];
    return PersonModel.fromJson(data);
  }

  @override
  Future<List<Map<String, dynamic>>> getPeopleByCategory({int? countryId}) async {
    final query = <String, dynamic>{};
    if (countryId != null) query['country_id'] = countryId;
    final response = await _apiClient.get(ApiConstants.peopleByCategory, queryParameters: query);
    final List list = response.data['categories'];
    return List<Map<String, dynamic>>.from(list);
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
    final response = await _apiClient.post(ApiConstants.people, data: {
      'name': name,
      'city_id': cityId,
      'country_id': countryId,
      'category': category,
      if (birthDate != null) 'birth_date': birthDate,
      if (biography != null) 'biography': biography,
      if (imageUrl != null) 'image_url': imageUrl,
    });
    final data = response.data['person'];
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
    final response = await _apiClient.put(ApiConstants.personById(id), data: {
      if (name != null) 'name': name,
      if (cityId != null) 'city_id': cityId,
      if (countryId != null) 'country_id': countryId,
      if (category != null) 'category': category,
      if (birthDate != null) 'birth_date': birthDate,
      if (biography != null) 'biography': biography,
      if (imageUrl != null) 'image_url': imageUrl,
    });
    final data = response.data['person'];
    return PersonModel.fromJson(data);
  }

  @override
  Future<void> deletePerson(int id) async {
    await _apiClient.delete(ApiConstants.personById(id));
  }
}
