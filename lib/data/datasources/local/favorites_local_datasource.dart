// lib/data/datasources/local/favorites_local_datasource.dart
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/storage_constants.dart';

abstract class FavoritesLocalDataSource {
  Future<List<int>> getFavoriteRoutes();
  Future<void> addFavoriteRoute(int placeId);
  Future<void> removeFavoriteRoute(int placeId);
  Future<void> clearFavorites();
}

class FavoritesLocalDataSourceImpl implements FavoritesLocalDataSource {
  final SharedPreferences _sharedPreferences;

  FavoritesLocalDataSourceImpl({required SharedPreferences sharedPreferences})
      : _sharedPreferences = sharedPreferences;

  @override
  Future<List<int>> getFavoriteRoutes() async {
    final jsonString = _sharedPreferences.getString(StorageConstants.favoriteRoutes);
    if (jsonString == null) return [];
    final List<dynamic> list = json.decode(jsonString);
    return list.map((e) => e as int).toList();
  }

  @override
  Future<void> addFavoriteRoute(int placeId) async {
    final list = await getFavoriteRoutes();
    if (!list.contains(placeId)) {
      list.add(placeId);
      await _sharedPreferences.setString(StorageConstants.favoriteRoutes, json.encode(list));
    }
  }

  @override
  Future<void> removeFavoriteRoute(int placeId) async {
    final list = await getFavoriteRoutes();
    if (list.contains(placeId)) {
      list.remove(placeId);
      await _sharedPreferences.setString(StorageConstants.favoriteRoutes, json.encode(list));
    }
  }

  @override
  Future<void> clearFavorites() async {
    await _sharedPreferences.remove(StorageConstants.favoriteRoutes);
  }
}
