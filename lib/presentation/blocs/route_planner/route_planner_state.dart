// lib/presentation/blocs/route_planner/route_planner_state.dart

/// A single saved route (for display in the “Saved Routes” list).
class SavedRoute {
  final String name;
  final List<int> placeIds;
  const SavedRoute({
    required this.name,
    required this.placeIds,
  });
}

/// Base class for the bloc’s state.
abstract class RoutePlannerState {}

/// Loading state (initial).
class RoutePlannerLoading extends RoutePlannerState {}

/// Error state.
class RoutePlannerError extends RoutePlannerState {
  final String message;
  RoutePlannerError(this.message);
}

/// Everything is loaded successfully:
///  • [savedRoutes]: all saved routes from storage
///  • [workingPlaceIds]: the “current” list of place IDs being built/reordered
class RoutePlannerLoaded extends RoutePlannerState {
  final List<SavedRoute> savedRoutes;
  final List<int> workingPlaceIds;

  RoutePlannerLoaded({
    required this.savedRoutes,
    required this.workingPlaceIds,
  });
}
