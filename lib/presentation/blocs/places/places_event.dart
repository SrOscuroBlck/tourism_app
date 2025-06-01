part of 'places_bloc.dart';

abstract class PlacesEvent extends Equatable {
  const PlacesEvent();

  @override
  List<Object?> get props => [];
}

/// Trigger loading of the list of places (optionally with filters).
class FetchPlaces extends PlacesEvent {
  final int? countryId;
  final int? cityId;
  final String? type;
  final String? search;

  const FetchPlaces({this.countryId, this.cityId, this.type, this.search});

  @override
  List<Object?> get props => [countryId, cityId, type, search];
}
