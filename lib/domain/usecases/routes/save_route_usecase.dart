// lib/domain/usecases/routes/save_route_usecase.dart

import '../../entities/route.dart';
import '../../repositories/route_repository.dart';

/// Use‐case: save or overwrite a named route.
class SaveRouteUseCase {
  final RouteRepository _repo;
  SaveRouteUseCase(this._repo);

  Future<void> call(RoutePlan route) {
    return _repo.saveRoute(route);
  }
}
