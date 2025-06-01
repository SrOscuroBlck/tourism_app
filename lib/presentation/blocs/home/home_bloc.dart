import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../../domain/entities/place.dart';
import '../../../domain/usecases/places/get_places_uscase.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetPlacesUseCase _getPlacesUseCase;

  HomeBloc({required GetPlacesUseCase getPlacesUseCase})
      : _getPlacesUseCase = getPlacesUseCase,
        super(HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
  }

  Future<void> _onLoadHomeData(
      LoadHomeData event,
      Emitter<HomeState> emit,
      ) async {
    emit(HomeLoading());

    // For simplicity, we’ll just fetch all places, then sort by visitCount.
    final result = await _getPlacesUseCase(
      PlacesParams(countryId: null, cityId: null, type: null, search: null),
    );

    result.fold(
          (failure) => emit(HomeError(failure.message ?? 'Unknown error')),
          (places) {
        // Sort by the `visitCount` field descending, take top 10
        final sorted = List<Place>.from(places)
          ..sort((a, b) => (b.visitCount ?? 0).compareTo(a.visitCount ?? 0));
        final top10 = sorted.take(10).toList();

        emit(HomeLoaded(topVisited: top10));
      },
    );
  }
}
