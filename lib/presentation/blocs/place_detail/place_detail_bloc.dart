import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/place.dart';
import '../../../domain/usecases/places/get_place_detail_uscase.dart';
import '../../../domain/usecases/places/toggle_favorite_uscase.dart';

part 'place_detail_event.dart';
part 'place_detail_state.dart';

class PlaceDetailBloc extends Bloc<PlaceDetailEvent, PlaceDetailState> {
  final GetPlaceDetailUseCase _getDetailUseCase;
  final ToggleFavoriteUseCase _toggleFavoriteUseCase;

  PlaceDetailBloc({
    required GetPlaceDetailUseCase getDetailUseCase,
    required ToggleFavoriteUseCase toggleFavoriteUseCase,
  })  : _getDetailUseCase = getDetailUseCase,
        _toggleFavoriteUseCase = toggleFavoriteUseCase,
        super(PlaceDetailInitial()) {
    on<FetchPlaceDetail>(_onFetchDetail);
    on<ToggleFavoriteStatus>(_onToggleFavorite);
  }

  Future<void> _onFetchDetail(
      FetchPlaceDetail event,
      Emitter<PlaceDetailState> emit,
      ) async {
    emit(PlaceDetailLoading());

    final result = await _getDetailUseCase(PlaceIdParams(id: event.id));
    result.fold(
          (failure) => emit(PlaceDetailError(failure.message ?? 'Unknown error')),
          (place) => emit(PlaceDetailLoaded(place)),
    );
  }

  Future<void> _onToggleFavorite(
      ToggleFavoriteStatus event,
      Emitter<PlaceDetailState> emit,
      ) async {
    if (state is PlaceDetailLoaded) {
      final currentPlace = (state as PlaceDetailLoaded).place;

      final result = await _toggleFavoriteUseCase(
        ToggleFavoriteParams(id: event.id),
      );

      result.fold(
            (failure) => emit(PlaceDetailError(failure.message ?? 'Unknown error')),
            (updatedPlace) {
          // Create a new place with updated favorite status but keep all other data
          final newPlace = Place(
            id: currentPlace.id,
            name: currentPlace.name,
            cityId: currentPlace.cityId,
            countryId: currentPlace.countryId,
            type: currentPlace.type,
            address: currentPlace.address,
            latitude: currentPlace.latitude,
            longitude: currentPlace.longitude,
            description: currentPlace.description,
            imageUrl: currentPlace.imageUrl,
            city: currentPlace.city,
            country: currentPlace.country,
            visitCount: currentPlace.visitCount,
            favoriteCount: currentPlace.favoriteCount,
            isFavorite: updatedPlace.isFavorite,
          );
          emit(PlaceDetailLoaded(newPlace));
        },
      );
    }
  }
}