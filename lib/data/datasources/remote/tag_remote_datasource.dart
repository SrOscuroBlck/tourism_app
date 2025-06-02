// lib/data/datasources/remote/tag_remote_datasource.dart

import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../models/tag_model.dart';
import '../../../core/network/api_client.dart';

abstract class TagRemoteDataSource {
  Future<List<TagModel>> getUserTags();
  Future<TagModel> getTagById(int id);
  Future<List<TagModel>> getTagsByPerson(int personId);
  Future<TagModel> createTag({
    required int personId,
    required String comment,
    String? photoUrl,
    double? latitude,
    double? longitude,
  });
  Future<TagModel> updateTag({
    required int id,
    String? comment,
    String? photoUrl,
    double? latitude,
    double? longitude,
  });
  Future<void> deleteTag(int id);
}

class TagRemoteDataSourceImpl implements TagRemoteDataSource {
  final ApiClient _apiClient;

  TagRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<TagModel>> getUserTags() async {
    final response = await _apiClient.get(ApiConstants.tags);
    final List list = response.data['tags'];
    return list.map((json) => TagModel.fromJson(json)).toList();
  }

  @override
  Future<TagModel> getTagById(int id) async {
    final response = await _apiClient.get(ApiConstants.tagById(id));
    final data = response.data['tag'];
    return TagModel.fromJson(data);
  }

  @override
  Future<List<TagModel>> getTagsByPerson(int personId) async {
    final response = await _apiClient.get(ApiConstants.tagsByPerson(personId));

    // 1) Debug print the raw JSON (optional, remove in production)
    print("🏷️ [TagRemoteDataSource] raw response.data for person $personId = ${response.data}");

    // 2) Check that 'tags' exists and is a List
    final raw = response.data;
    if (raw is! Map<String, dynamic> || raw['tags'] is! List) {
      // If the server did not send a 'tags' array, just return an empty list
      return <TagModel>[];
    }

    final List<dynamic> list = raw['tags'] as List<dynamic>;
    final result = <TagModel>[];
    for (final item in list) {
      try {
        result.add(TagModel.fromJson(item as Map<String, dynamic>));
      } catch (e, stack) {
        // If one tag fails to parse, skip it and log the error:
        print("❌ [TagParsing] failed to parse one tag JSON: $item");
        print("    Exception: $e");
        print("    Stack: $stack");
      }
    }
    return result;
  }

  @override
  Future<TagModel> createTag({
    required int personId,
    required String comment,
    String? photoUrl,
    double? latitude,
    double? longitude,
  }) async {
    final response = await _apiClient.post(ApiConstants.tags, data: {
      'person_id': personId,
      'comment': comment,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    });
    final data = response.data['tag'];
    return TagModel.fromJson(data);
  }

  @override
  Future<TagModel> updateTag({
    required int id,
    String? comment,
    String? photoUrl,
    double? latitude,
    double? longitude,
  }) async {
    final response = await _apiClient.put(ApiConstants.tagById(id), data: {
      if (comment != null) 'comment': comment,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    });
    final data = response.data['tag'];
    return TagModel.fromJson(data);
  }

  @override
  Future<void> deleteTag(int id) async {
    await _apiClient.delete(ApiConstants.tagById(id));
  }
}
