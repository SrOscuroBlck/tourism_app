// lib/domain/usecases/routes/get_routes_usecase.dart

import '../../entities/route.dart';
import '../../repositories/route_repository.dart';

/// Use‐case: fetch all saved routes.
class GetRoutesUseCase {
  final RouteRepository _repo;
  GetRoutesUseCase(this._repo);

  Future<List<RoutePlan>> call() {
    return _repo.getRoutes();
  }
}
