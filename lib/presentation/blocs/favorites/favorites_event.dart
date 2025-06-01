part of 'favorites_bloc.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

/// Load the list of favorite places from local storage.
class LoadFavorites extends FavoritesEvent {}
