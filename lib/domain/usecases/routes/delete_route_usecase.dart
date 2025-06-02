// lib/domain/usecases/routes/delete_route_usecase.dart

import '../../repositories/route_repository.dart';

/// Use‐case: delete a route by name.
class DeleteRouteUseCase {
  final RouteRepository _repo;
  DeleteRouteUseCase(this._repo);

  Future<void> call(String name) {
    return _repo.deleteRoute(name);
  }
}
