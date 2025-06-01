import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/place.dart';
import '../../../domain/usecases/places/get_places_uscase.dart';

part 'places_event.dart';
part 'places_state.dart';

class PlacesBloc extends Bloc<PlacesEvent, PlacesState> {
  final GetPlacesUseCase _getPlacesUseCase;

  PlacesBloc({required GetPlacesUseCase getPlacesUseCase})
      : _getPlacesUseCase = getPlacesUseCase,
        super(PlacesInitial()) {
    on<FetchPlaces>(_onFetchPlaces);
  }

  Future<void> _onFetchPlaces(
      FetchPlaces event,
      Emitter<PlacesState> emit,
      ) async {
    emit(PlacesLoading());

    final result = await _getPlacesUseCase(
      PlacesParams(
        countryId: event.countryId,
        cityId: event.cityId,
        type: event.type,
        search: event.search,
      ),
    );

    result.fold(
          (failure) => emit(PlacesError(failure.message ?? 'Unknown error')),
          (places) => emit(PlacesLoaded(places)),
    );
  }
}
