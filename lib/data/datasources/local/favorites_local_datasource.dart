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
    print("📱 [LocalFavorites] getFavoriteRoutes called");
    final jsonString = _sharedPreferences.getString(StorageConstants.favoriteRoutes);
    print("📱 [LocalFavorites] Raw JSON string: $jsonString");

    if (jsonString == null) {
      print("📱 [LocalFavorites] No favorites found, returning empty list");
      return [];
    }

    final List<dynamic> list = json.decode(jsonString);
    final result = list.map((e) => e as int).toList();
    print("📱 [LocalFavorites] Decoded favorites: $result");
    return result;
  }

  @override
  Future<void> addFavoriteRoute(int placeId) async {
    print("📱 [LocalFavorites] addFavoriteRoute called for place $placeId");
    final list = await getFavoriteRoutes();
    print("📱 [LocalFavorites] Current favorites before add: $list");

    if (!list.contains(placeId)) {
      list.add(placeId);
      print("📱 [LocalFavorites] Added place $placeId, new list: $list");
      final jsonString = json.encode(list);
      print("📱 [LocalFavorites] Saving JSON: $jsonString");
      await _sharedPreferences.setString(StorageConstants.favoriteRoutes, jsonString);
      print("📱 [LocalFavorites] Saved to SharedPreferences successfully");
    } else {
      print("📱 [LocalFavorites] Place $placeId already in favorites");
    }
  }

  @override
  Future<void> removeFavoriteRoute(int placeId) async {
    print("📱 [LocalFavorites] removeFavoriteRoute called for place $placeId");
    final list = await getFavoriteRoutes();
    print("📱 [LocalFavorites] Current favorites before remove: $list");

    if (list.contains(placeId)) {
      list.remove(placeId);
      print("📱 [LocalFavorites] Removed place $placeId, new list: $list");
      await _sharedPreferences.setString(StorageConstants.favoriteRoutes, json.encode(list));
      print("📱 [LocalFavorites] Saved to SharedPreferences successfully");
    } else {
      print("📱 [LocalFavorites] Place $placeId not found in favorites");
    }
  }

  @override
  Future<void> clearFavorites() async {
    print("📱 [LocalFavorites] clearFavorites called");
    await _sharedPreferences.remove(StorageConstants.favoriteRoutes);
    print("📱 [LocalFavorites] Cleared all favorites");
  }
}