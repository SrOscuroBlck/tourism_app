// lib/data/repositories/route_repository_impl.dart

import '../../domain/entities/route.dart';
import '../../domain/repositories/route_repository.dart';
import '../datasources/local/route_local_datasource.dart';

class RouteRepositoryImpl implements RouteRepository {
  final RouteLocalDataSource _local;

  RouteRepositoryImpl({required RouteLocalDataSource localDataSource})
      : _local = localDataSource;

  @override
  Future<List<RoutePlan>> getRoutes() {
    return _local.getSavedRoutes();
  }

  @override
  Future<void> saveRoute(RoutePlan route) {
    return _local.saveRoute(route);
  }

  @override
  Future<void> deleteRoute(String name) {
    return _local.deleteRoute(name);
  }
}
