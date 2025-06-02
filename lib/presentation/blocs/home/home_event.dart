part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Load whatever data is needed for the home screen (i.e. top‐visited places).
class LoadHomeData extends HomeEvent {}

/// (Optional) Load analytics data if it wasn’t fetched already.
class LoadAnalyticsData extends HomeEvent {}
