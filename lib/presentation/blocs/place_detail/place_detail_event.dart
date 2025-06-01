part of 'place_detail_bloc.dart';

abstract class PlaceDetailEvent extends Equatable {
  const PlaceDetailEvent();

  @override
  List<Object?> get props => [];
}

/// Load the details for a single place by its `id`.
class FetchPlaceDetail extends PlaceDetailEvent {
  final int id;

  const FetchPlaceDetail(this.id);

  @override
  List<Object?> get props => [id];
}

/// Toggle favorite status for the place with the given `id`.
class ToggleFavoriteStatus extends PlaceDetailEvent {
  final int id;

  const ToggleFavoriteStatus(this.id);

  @override
  List<Object?> get props => [id];
}
