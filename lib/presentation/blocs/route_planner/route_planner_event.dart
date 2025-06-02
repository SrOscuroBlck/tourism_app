// lib/presentation/blocs/route_planner/route_planner_event.dart

abstract class RoutePlannerEvent {}

/// Load all previously‐saved routes from local storage.
class LoadSavedRoutes extends RoutePlannerEvent {}

/// Add a place (by its ID) to the “working” route.
class AddPlaceToRoute extends RoutePlannerEvent {
  final int placeId;
  AddPlaceToRoute(this.placeId);
}

/// Remove a place (by index) from the “working” route.
class RemovePlaceFromRoute extends RoutePlannerEvent {
  final int index;
  RemovePlaceFromRoute(this.index);
}

/// Reorder the current route’s place list (drag & drop).
class ReorderRoutePlaces extends RoutePlannerEvent {
  final int oldIndex;
  final int newIndex;
  ReorderRoutePlaces(this.oldIndex, this.newIndex);
}

/// Save the current working route under a given name.
class SaveCurrentRoute extends RoutePlannerEvent {
  final String name;
  SaveCurrentRoute(this.name);
}

/// Delete a previously saved route by name.
class DeleteSavedRoute extends RoutePlannerEvent {
  final String name;
  DeleteSavedRoute(this.name);
}

/// Select a saved route (loads its placeIds into the “working” route for preview).
class SelectSavedRoute extends RoutePlannerEvent {
  final String name;
  SelectSavedRoute(this.name);
}

/// Clear the “working” route (empty the list, but do not delete saved routes).
class ClearWorkingRoute extends RoutePlannerEvent {}
