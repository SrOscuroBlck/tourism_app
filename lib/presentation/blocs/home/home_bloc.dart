import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../../domain/entities/dish.dart';
import '../../../domain/entities/place.dart';
import '../../../domain/usecases/places/get_places_uscase.dart';
import '../../../domain/repositories/person_repository.dart';
import '../../../domain/repositories/dish_repository.dart';
import '../../../domain/repositories/visit_repository.dart';
import '../../../domain/repositories/tag_repository.dart';
import '../../../injection_container.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetPlacesUseCase _getPlacesUseCase;

  HomeBloc({ required GetPlacesUseCase getPlacesUseCase })
      : _getPlacesUseCase = getPlacesUseCase,
        super(HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<LoadAnalyticsData>(_onLoadAnalyticsData);
  }

  Future<void> _onLoadHomeData(
      LoadHomeData event,
      Emitter<HomeState> emit,
      ) async {
    emit(HomeLoading());

    // 1) Fetch all places (so we can sort by visitCount)
    final result = await _getPlacesUseCase(
      PlacesParams(countryId: null, cityId: null, type: null, search: null),
    );

    if (result.isLeft()) {
      // If failure, emit error state and return immediately
      final failureMessage = result.fold((f) => f.message ?? 'Unknown error', (_) => '');
      emit(HomeError(failureMessage));
      return;
    }

    // 2) Extract the list of places
    final places = result.fold((_) => <Place>[], (list) => list);

    // 3) Sort by visitCount descending and take top 10
    final sorted = <Place>[...places]
      ..sort((a, b) => (b.visitCount ?? 0).compareTo(a.visitCount ?? 0));
    final top10 = sorted.take(10).toList();

    // 4) Load analytic data (await this so that we can still emit in order)
    final analytics = await _loadAnalyticsData();

    // 5) Finally, emit “loaded” with both top‐visited and analytics
    emit(HomeLoaded(topVisited: top10, analytics: analytics));
  }

  Future<void> _onLoadAnalyticsData(
      LoadAnalyticsData event,
      Emitter<HomeState> emit,
      ) async {
    // Only if we’re already in a HomeLoaded state do we attempt to add analytics
    if (state is HomeLoaded) {
      final current = state as HomeLoaded;
      final analytics = await _loadAnalyticsData();
      emit(current.copyWith(analytics: analytics));
    }
  }

  /// Retries each subquery in turn. Always returns a non‐null AnalyticsData object.
  Future<AnalyticsData> _loadAnalyticsData() async {
    try {
      // ─── Query 1: People by category ─────────────────────
      final personRepo = sl<PersonRepository>();
      final peopleResult = await personRepo.getPeopleByCategory();
      final Map<String, int> peopleByCategory = {};
      peopleResult.fold(
            (_) => {},
            (categories) {
          for (final category in categories) {
            final key = category['category'] as String? ?? 'Unknown';
            final count = category['count'] as int? ?? 0;
            peopleByCategory[key] = count;
          }
        },
      );

      // ─── Query 2: Top visited places (reuse existing GetPlacesUseCase) ─
      final placesResult = await _getPlacesUseCase(
        PlacesParams(countryId: null, cityId: null, type: null, search: null),
      );
      final List<Place> topPlaces = [];
      placesResult.fold(
            (_) => {},
            (places) {
          final sorted = <Place>[...places]
            ..sort((a, b) => (b.visitCount ?? 0).compareTo(a.visitCount ?? 0));
          topPlaces.addAll(sorted.take(10));
        },
      );

      // ─── Query 3: User activity stats ────────────────────
      final visitRepo = sl<VisitRepository>();
      final tagRepo = sl<TagRepository>();

      final visitsResult = await visitRepo.getUserVisits();
      final tagsResult = await tagRepo.getUserTags();

      int totalVisits = 0;
      int totalTags = 0;
      int placesVisited = 0;
      String mostActiveMonth = 'January';

      visitsResult.fold(
            (_) => {},
            (visits) {
          totalVisits = visits.length;
          placesVisited = visits.map((v) => v.placeId).toSet().length;

          // Compute most active month
          final Map<int, int> monthCounts = {};
          for (final v in visits) {
            final m = v.visitedAt.month;
            monthCounts[m] = (monthCounts[m] ?? 0) + 1;
          }
          if (monthCounts.isNotEmpty) {
            final best = monthCounts.entries
                .reduce((a, b) => a.value > b.value ? a : b)
                .key;
            final months = [
              'January', 'February', 'March', 'April', 'May', 'June',
              'July', 'August', 'September', 'October', 'November', 'December'
            ];
            mostActiveMonth = months[best - 1];
          }
        },
      );

      tagsResult.fold(
            (_) => {},
            (tags) => totalTags = tags.length,
      );

      // ─── Query 4: Price analysis ────────────────────────
      final dishRepo = sl<DishRepository>();
      final dishesResult = await dishRepo.getAllDishes();
      double averagePrice = 0.0;
      String mostExpensiveDish = 'N/A';
      double mostExpensivePrice = 0.0;
      String cheapestDish = 'N/A';
      double cheapestPrice = 0.0;

      dishesResult.fold(
            (_) => {},
            (dishes) {
          if (dishes.isNotEmpty) {
            final prices = dishes.map((d) => d.price).toList();
            averagePrice = prices.reduce((a, b) => a + b) / prices.length;

            final sortedDishes = <Dish>[...dishes]
              ..sort((a, b) => b.price.compareTo(a.price));
            mostExpensiveDish = sortedDishes.first.name;
            mostExpensivePrice = sortedDishes.first.price;

            final cheapestList = <Dish>[...dishes]
              ..sort((a, b) => a.price.compareTo(b.price));
            cheapestDish = cheapestList.first.name;
            cheapestPrice = cheapestList.first.price;
          }
        },
      );

      // ─── Query 5: Geographic insights ───────────────────
      String mostTaggedCity = 'N/A';
      int mostTaggedCount = 0;
      String mostVisitedCity = 'N/A';
      int mostVisitedCount = 0;

      // Visits by city
      visitsResult.fold(
            (_) => {},
            (visits) {
          final Map<String, int> cityCounts = {};
          for (final v in visits) {
            final cityName = v.place?.city?.name ?? 'Unknown';
            cityCounts[cityName] = (cityCounts[cityName] ?? 0) + 1;
          }
          if (cityCounts.isNotEmpty) {
            final best = cityCounts.entries
                .reduce((a, b) => a.value > b.value ? a : b);
            mostVisitedCity = best.key;
            mostVisitedCount = best.value;
          }
        },
      );

      // Tags by city
      tagsResult.fold(
            (_) => {},
            (tags) {
          final Map<String, int> cityCounts = {};
          for (final t in tags) {
            final cityName = t.person?.city?.name ?? 'Unknown';
            cityCounts[cityName] = (cityCounts[cityName] ?? 0) + 1;
          }
          if (cityCounts.isNotEmpty) {
            final best = cityCounts.entries
                .reduce((a, b) => a.value > b.value ? a : b);
            mostTaggedCity = best.key;
            mostTaggedCount = best.value;
          }
        },
      );

      return AnalyticsData(
        peopleByCategory: peopleByCategory,
        topVisitedPlaces: topPlaces,
        userStats: UserActivityStats(
          totalVisits: totalVisits,
          totalTags: totalTags,
          mostActiveMonth: mostActiveMonth,
          placesVisited: placesVisited,
        ),
        priceAnalysis: PriceAnalysis(
          averagePrice: averagePrice,
          mostExpensiveDish: mostExpensiveDish,
          mostExpensivePrice: mostExpensivePrice,
          cheapestDish: cheapestDish,
          cheapestPrice: cheapestPrice,
        ),
        geoInsights: GeographicInsights(
          mostTaggedCity: mostTaggedCity,
          mostTaggedCount: mostTaggedCount,
          mostVisitedCity: mostVisitedCity,
          mostVisitedCount: mostVisitedCount,
        ),
      );
    } catch (_) {
      // On error, return an “empty” AnalyticsData
      return AnalyticsData(
        peopleByCategory: {},
        topVisitedPlaces: [],
        userStats: const UserActivityStats(
          totalVisits: 0,
          totalTags: 0,
          mostActiveMonth: 'N/A',
          placesVisited: 0,
        ),
        priceAnalysis: const PriceAnalysis(
          averagePrice: 0.0,
          mostExpensiveDish: 'N/A',
          mostExpensivePrice: 0.0,
          cheapestDish: 'N/A',
          cheapestPrice: 0.0,
        ),
        geoInsights: const GeographicInsights(
          mostTaggedCity: 'N/A',
          mostTaggedCount: 0,
          mostVisitedCity: 'N/A',
          mostVisitedCount: 0,
        ),
      );
    }
  }
}
