// lib/presentation/blocs/favorites/favorites_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../../domain/entities/place.dart';
import '../../../domain/repositories/place_repository.dart';
import '../../../data/datasources/local/favorites_local_datasource.dart';
import '../../../domain/usecases/places/get_place_detail_uscase.dart';

part 'favorites_event.dart';
part 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final FavoritesLocalDataSource _localDataSource;
  final GetPlaceDetailUseCase _getDetailUseCase;

  FavoritesBloc({
    required FavoritesLocalDataSource localDataSource,
    required GetPlaceDetailUseCase getDetailUseCase,
  })  : _localDataSource = localDataSource,
        _getDetailUseCase = getDetailUseCase,
        super(FavoritesInitial()) {
    on<LoadFavorites>(_onLoadFavorites);
  }

  Future<void> _onLoadFavorites(
      LoadFavorites event,
      Emitter<FavoritesState> emit,
      ) async {
    emit(FavoritesLoading());
    try {
      // Get favorite place IDs from local storage (which should be synced with backend)
      final List<int> favoriteIds = await _localDataSource.getFavoriteRoutes();

      print("🔍 [FavoritesBloc] Found favorite IDs: $favoriteIds");

      if (favoriteIds.isEmpty) {
        print("🔍 [FavoritesBloc] No favorites found");
        emit(const FavoritesLoaded([]));
        return;
      }

      final List<Place> loadedPlaces = [];

      // Fetch details for each favorite place
      for (final id in favoriteIds) {
        print("🔍 [FavoritesBloc] Fetching details for place $id");
        final result = await _getDetailUseCase(PlaceIdParams(id: id));
        result.fold(
              (failure) {
            print("❌ [FavoritesBloc] Failed to load place $id: ${failure.message}");
            // Skip this place if it fails to load
          },
              (place) {
            print("✅ [FavoritesBloc] Loaded place: ${place.name}");
            loadedPlaces.add(place);
          },
        );
      }

      print("🔍 [FavoritesBloc] Final loaded places count: ${loadedPlaces.length}");
      emit(FavoritesLoaded(loadedPlaces));
    } catch (e) {
      print("❌ [FavoritesBloc] Exception: $e");
      emit(const FavoritesError('Failed to load favorites'));
    }
  }
}