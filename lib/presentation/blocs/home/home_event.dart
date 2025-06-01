part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Load whatever data is needed for the “home” screen (e.g. top‐visited places).
class LoadHomeData extends HomeEvent {}
