part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

/// Once home data is loaded, we provide:
///  • topVisited: the top 10 places by visitCount
///  • analytics: optional “5‐queries” analytics data
class HomeLoaded extends HomeState {
  final List<Place> topVisited;
  final AnalyticsData? analytics;

  const HomeLoaded({
    required this.topVisited,
    this.analytics,
  });

  @override
  List<Object?> get props => [topVisited, analytics];

  HomeLoaded copyWith({
    List<Place>? topVisited,
    AnalyticsData? analytics,
  }) {
    return HomeLoaded(
      topVisited: topVisited ?? this.topVisited,
      analytics: analytics ?? this.analytics,
    );
  }
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Analytics data model (returned by _loadAnalyticsData)
class AnalyticsData {
  final Map<String, int> peopleByCategory;
  final List<Place> topVisitedPlaces;
  final UserActivityStats userStats;
  final PriceAnalysis priceAnalysis;
  final GeographicInsights geoInsights;

  const AnalyticsData({
    required this.peopleByCategory,
    required this.topVisitedPlaces,
    required this.userStats,
    required this.priceAnalysis,
    required this.geoInsights,
  });

  @override
  List<Object?> get props => [
    peopleByCategory,
    topVisitedPlaces,
    userStats,
    priceAnalysis,
    geoInsights,
  ];
}

class UserActivityStats extends Equatable {
  final int totalVisits;
  final int totalTags;
  final String mostActiveMonth;
  final int placesVisited;

  const UserActivityStats({
    required this.totalVisits,
    required this.totalTags,
    required this.mostActiveMonth,
    required this.placesVisited,
  });

  @override
  List<Object?> get props => [totalVisits, totalTags, mostActiveMonth, placesVisited];
}

class PriceAnalysis extends Equatable {
  final double averagePrice;
  final String mostExpensiveDish;
  final double mostExpensivePrice;
  final String cheapestDish;
  final double cheapestPrice;

  const PriceAnalysis({
    required this.averagePrice,
    required this.mostExpensiveDish,
    required this.mostExpensivePrice,
    required this.cheapestDish,
    required this.cheapestPrice,
  });

  @override
  List<Object?> get props => [
    averagePrice,
    mostExpensiveDish,
    mostExpensivePrice,
    cheapestDish,
    cheapestPrice,
  ];
}

class GeographicInsights extends Equatable {
  final String mostTaggedCity;
  final int mostTaggedCount;
  final String mostVisitedCity;
  final int mostVisitedCount;

  const GeographicInsights({
    required this.mostTaggedCity,
    required this.mostTaggedCount,
    required this.mostVisitedCity,
    required this.mostVisitedCount,
  });

  @override
  List<Object?> get props => [mostTaggedCity, mostTaggedCount, mostVisitedCity, mostVisitedCount];
}
