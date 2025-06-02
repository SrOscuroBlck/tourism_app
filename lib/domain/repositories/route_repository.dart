// lib/domain/repositories/route_repository.dart

import '../entities/route.dart';

/// Abstract contract for storing and retrieving named routes.
abstract class RouteRepository {
  /// Returns all saved routes (may be empty).
  Future<List<RoutePlan>> getRoutes();

  /// Saves (or overwrites) a route with this name.
  Future<void> saveRoute(RoutePlan route);

  /// Deletes the route with this name (if it exists).
  Future<void> deleteRoute(String name);
}
