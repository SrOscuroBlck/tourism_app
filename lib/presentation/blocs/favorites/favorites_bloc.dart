import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../../data/datasources/local/favorites_local_datasource.dart';
import '../../../domain/entities/place.dart';
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
      final List<int> ids = await _localDataSource.getFavoriteRoutes();
      final List<Place> loaded = [];

      for (final id in ids) {
        final result = await _getDetailUseCase(PlaceIdParams(id: id));
        result.fold(
              (failure) {
            // skip if one fails
          },
              (place) {
            loaded.add(place);
          },
        );
      }

      emit(FavoritesLoaded(loaded));
    } catch (_) {
      emit(const FavoritesError('Failed to load favorites'));
    }
  }
}
