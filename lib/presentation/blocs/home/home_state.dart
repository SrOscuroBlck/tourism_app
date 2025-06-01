part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

/// Once home data is loaded, we provide a list of top‐visited places.
/// (You can expand this with additional fields as needed.)
class HomeLoaded extends HomeState {
  final List<Place> topVisited;

  const HomeLoaded({required this.topVisited});

  @override
  List<Object?> get props => [topVisited];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
