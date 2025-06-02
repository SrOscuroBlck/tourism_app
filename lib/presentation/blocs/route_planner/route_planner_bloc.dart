// lib/presentation/blocs/route_planner/route_planner_bloc.dart

import 'package:bloc/bloc.dart';
import '../../../domain/entities/route.dart';
import '../../../domain/usecases/routes/get_routes_usecase.dart';
import '../../../domain/usecases/routes/save_route_usecase.dart';
import '../../../domain/usecases/routes/delete_route_usecase.dart';
import 'route_planner_event.dart';
import 'route_planner_state.dart';

class RoutePlannerBloc extends Bloc<RoutePlannerEvent, RoutePlannerState> {
  final GetRoutesUseCase _getRoutes;
  final SaveRouteUseCase _saveRoute;
  final DeleteRouteUseCase _deleteRoute;

  /// The “working” (in‐memory) list of selected place IDs.
  final List<int> _workingIds = [];

  RoutePlannerBloc({
    required GetRoutesUseCase getRoutesUseCase,
    required SaveRouteUseCase saveRouteUseCase,
    required DeleteRouteUseCase deleteRouteUseCase,
  })  : _getRoutes = getRoutesUseCase,
        _saveRoute = saveRouteUseCase,
        _deleteRoute = deleteRouteUseCase,
        super(RoutePlannerLoading()) {
    on<LoadSavedRoutes>(_onLoadSavedRoutes);
    on<AddPlaceToRoute>(_onAddPlace);
    on<RemovePlaceFromRoute>(_onRemovePlace);
    on<ReorderRoutePlaces>(_onReorderPlaces);
    on<SaveCurrentRoute>(_onSaveRoute);
    on<DeleteSavedRoute>(_onDeleteRoute);
    on<SelectSavedRoute>(_onSelectSavedRoute);
    on<ClearWorkingRoute>(_onClearWorkingRoute);
  }

  Future<void> _onLoadSavedRoutes(
      LoadSavedRoutes event,
      Emitter<RoutePlannerState> emit,
      ) async {
    emit(RoutePlannerLoading());
    try {
      final List<RoutePlan> list = await _getRoutes();
      final saved = list
          .map((rp) => SavedRoute(name: rp.name, placeIds: rp.placeIds))
          .toList();
      emit(RoutePlannerLoaded(
        savedRoutes: saved,
        workingPlaceIds: List<int>.from(_workingIds),
      ));
    } catch (e) {
      emit(RoutePlannerError('Could not load saved routes.'));
    }
  }

  Future<void> _onAddPlace(
      AddPlaceToRoute event,
      Emitter<RoutePlannerState> emit,
      ) async {
    _workingIds.add(event.placeId);
    final loadedState = state as RoutePlannerLoaded;
    emit(RoutePlannerLoaded(
      savedRoutes: loadedState.savedRoutes,
      workingPlaceIds: List<int>.from(_workingIds),
    ));
  }

  Future<void> _onRemovePlace(
      RemovePlaceFromRoute event,
      Emitter<RoutePlannerState> emit,
      ) async {
    if (event.index >= 0 && event.index < _workingIds.length) {
      _workingIds.removeAt(event.index);
    }
    final loadedState = state as RoutePlannerLoaded;
    emit(RoutePlannerLoaded(
      savedRoutes: loadedState.savedRoutes,
      workingPlaceIds: List<int>.from(_workingIds),
    ));
  }

  Future<void> _onReorderPlaces(
      ReorderRoutePlaces event,
      Emitter<RoutePlannerState> emit,
      ) async {
    final oldIdx = event.oldIndex;
    var newIdx = event.newIndex;
    if (newIdx > oldIdx) newIdx -= 1;
    final item = _workingIds.removeAt(oldIdx);
    _workingIds.insert(newIdx, item);

    final loadedState = state as RoutePlannerLoaded;
    emit(RoutePlannerLoaded(
      savedRoutes: loadedState.savedRoutes,
      workingPlaceIds: List<int>.from(_workingIds),
    ));
  }

  Future<void> _onSaveRoute(
      SaveCurrentRoute event,
      Emitter<RoutePlannerState> emit,
      ) async {
    final name = event.name.trim();
    if (name.isEmpty || _workingIds.isEmpty) {
      // Nothing to save
      return;
    }
    final toSave = RoutePlan(name: name, placeIds: List<int>.from(_workingIds));
    await _saveRoute(toSave);

    // After saving, reload everything
    final list = await _getRoutes();
    final saved = list
        .map((rp) => SavedRoute(name: rp.name, placeIds: rp.placeIds))
        .toList();
    emit(RoutePlannerLoaded(
      savedRoutes: saved,
      workingPlaceIds: List<int>.from(_workingIds),
    ));
  }

  Future<void> _onDeleteRoute(
      DeleteSavedRoute event,
      Emitter<RoutePlannerState> emit,
      ) async {
    await _deleteRoute(event.name);

    if (state is RoutePlannerLoaded) {
      final loadedState = state as RoutePlannerLoaded;
      final updatedSaved = List<SavedRoute>.from(loadedState.savedRoutes)
        ..removeWhere((r) => r.name == event.name);
      emit(RoutePlannerLoaded(
        savedRoutes: updatedSaved,
        workingPlaceIds: List<int>.from(_workingIds),
      ));
    }
  }

  Future<void> _onSelectSavedRoute(
      SelectSavedRoute event,
      Emitter<RoutePlannerState> emit,
      ) async {
    final list = await _getRoutes();
    final match = list.firstWhere(
          (rp) => rp.name == event.name,
      orElse: () => RoutePlan(name: '', placeIds: []),
    );

    _workingIds
      ..clear()
      ..addAll(match.placeIds);

    final savedList = list
        .map((rp) => SavedRoute(name: rp.name, placeIds: rp.placeIds))
        .toList();
    emit(RoutePlannerLoaded(
      savedRoutes: savedList,
      workingPlaceIds: List<int>.from(_workingIds),
    ));
  }

  Future<void> _onClearWorkingRoute(
      ClearWorkingRoute event,
      Emitter<RoutePlannerState> emit,
      ) async {
    _workingIds.clear();
    if (state is RoutePlannerLoaded) {
      final loadedState = state as RoutePlannerLoaded;
      emit(RoutePlannerLoaded(
        savedRoutes: loadedState.savedRoutes,
        workingPlaceIds: [],
      ));
    }
  }
}
