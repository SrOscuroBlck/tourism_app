// lib/data/datasources/local/route_local_datasource.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/storage_constants.dart';
import '../../../domain/entities/route.dart' as entity;

/// Abstract contract for storing and retrieving named routes.
abstract class RouteLocalDataSource {
  /// Returns all saved routes (may be empty).
  Future<List<entity.RoutePlan>> getSavedRoutes();

  /// Saves (or overwrites) a route with this name.
  Future<void> saveRoute(entity.RoutePlan route);

  /// Deletes the route with this name (if it exists).
  Future<void> deleteRoute(String name);
}

/// Implementation that uses SharedPreferences under the hood.
class RouteLocalDataSourceImpl implements RouteLocalDataSource {
  final SharedPreferences _prefs;

  RouteLocalDataSourceImpl({required SharedPreferences prefs})
      : _prefs = prefs;

  static const String _key = StorageConstants.savedRoutes;

  @override
  Future<List<entity.RoutePlan>> getSavedRoutes() async {
    final rawJson = _prefs.getString(_key);
    if (rawJson == null) return [];

    final List<dynamic> decodedList = json.decode(rawJson);
    return decodedList
        .map((map) => entity.RoutePlan.fromJson(map as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveRoute(entity.RoutePlan route) async {
    final existing = await getSavedRoutes();
    // If a route with the same name already exists, overwrite it:
    final idx = existing.indexWhere((r) => r.name == route.name);
    if (idx >= 0) {
      existing[idx] = route;
    } else {
      existing.add(route);
    }

    final toStore =
    existing.map((r) => r.toJson()).toList(growable: false);
    final raw = json.encode(toStore);
    await _prefs.setString(_key, raw);
  }

  @override
  Future<void> deleteRoute(String name) async {
    final existing = await getSavedRoutes();
    existing.removeWhere((r) => r.name == name);

    final toStore =
    existing.map((r) => r.toJson()).toList(growable: false);
    final raw = json.encode(toStore);
    await _prefs.setString(_key, raw);
  }
}
