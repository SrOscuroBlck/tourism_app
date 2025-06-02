// lib/presentation/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../blocs/home/home_bloc.dart';
import '../../widgets/cards/category_card.dart';
import '../../widgets/cards/place_card.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/analytics/analytics_section.dart'; // NEW IMPORT
import '../../../domain/entities/place.dart';

// Repositories & use-cases
import '../../../domain/repositories/country_repository.dart';
import '../../../domain/repositories/city_repository.dart';
import '../../../domain/usecases/visits/get_user_visits_uscase.dart';

// Our GetIt "service locator" (sl) was set up in injection_container.dart:
import '../../../injection_container.dart';
import '../places/place_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// Simple data model for the three "quick stats":
class _StatsData {
  final int countryCount;
  final int cityCount;
  final int visitedCount;

  _StatsData({
    required this.countryCount,
    required this.cityCount,
    required this.visitedCount,
  });
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  /// We fetch:
  ///  • all countries (to get countryCount),
  ///  • all cities (to get cityCount),
  ///  • all user visits  (to get visitedCount).
  Future<_StatsData> _fetchStats() async {
    // 1) Country count:
    final countryRepo = sl<CountryRepository>();
    final countryEither = await countryRepo.getAllCountries();
    final countries =
    countryEither.fold<List>((fail) => <dynamic>[], (list) => list);

    // 2) City count:
    final cityRepo = sl<CityRepository>();
    // Passing no filters → fetch all cities across all countries:
    final cityEither = await cityRepo.getAllCities(countryId: null);
    final cities = cityEither.fold<List>((fail) => <dynamic>[], (list) => list);

    // 3) Visited count for this user:
    final getUserVisitsUseCase = sl<GetUserVisitsUseCase>();
    final visitsEither = await getUserVisitsUseCase();
    final visits = visitsEither.fold<List>((fail) => <dynamic>[], (list) => list);

    return _StatsData(
      countryCount: countries.length,
      cityCount: cities.length,
      visitedCount: visits.length,
    );
  }

  @override
  void initState() {
    super.initState();
    // Dispatch to load top-visited places AND analytics data
    context.read<HomeBloc>().add(LoadHomeData());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: AppColors.inputBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        textInputAction: TextInputAction.search,
        onSubmitted: (query) {
          // In a real app, you might dispatch to PlacesBloc or navigate to a search-results page:
          debugPrint('Search submitted: $query');
        },
      ),
    );
  }

  Widget _buildQuickStats() {
    return FutureBuilder<_StatsData>(
      future: _fetchStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a spinner while we wait for counts:
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          // If any error occurred, simply show "N/A"
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _StatTile(label: 'Countries', value: 'N/A'),
                _StatTile(label: 'Cities', value: 'N/A'),
                _StatTile(label: 'Visited', value: 'N/A'),
              ],
            ),
          );
        }

        // We have valid data:
        final stats = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatTile(
                label: 'Countries',
                value: stats.countryCount.toString(),
              ),
              _StatTile(
                label: 'Cities',
                value: stats.cityCount.toString(),
              ),
              _StatTile(
                label: 'Visited',
                value: stats.visitedCount.toString(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeaturedCarousel(List<Place> topVisited) {
    if (topVisited.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(child: Text('No featured places yet')),
      );
    }

    return SizedBox(
      height: 200,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.85),
        itemCount: topVisited.length,
        itemBuilder: (context, index) {
          final place = topVisited[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: PlaceCard(
              place: place,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlaceDetailScreen(placeId: place.id),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    final categories = [
      _CategoryData(
        label: 'Countries',
        imageUrl: '',
        routeName: '/countries_list',
      ),
      _CategoryData(
        label: 'Cities',
        imageUrl: '',
        routeName: '/cities_list',
      ),
      _CategoryData(
        label: 'People',
        imageUrl: '',
        routeName: '/people_list',
      ),
      _CategoryData(
        label: 'Dishes',
        imageUrl: '',
        routeName: '/dishes_list',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: categories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.8,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          final cat = categories[index];
          return CategoryCard(
            label: cat.label,
            imageUrl: cat.imageUrl,
            onTap: () {
              Navigator.pushNamed(context, cat.routeName);
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Explore',
        automaticallyImplyLeading: false,
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is HomeLoaded) {
            final topVisited = state.topVisited;
            final analytics = state.analytics; // NEW: Get analytics data

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchBar(),
                  _buildQuickStats(),

                  // Featured Destinations Section
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Featured Destinations',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildFeaturedCarousel(topVisited),
                  const SizedBox(height: 24),

                  // NEW: Analytics Section (THE 5 QUERIES)
                  if (analytics != null) AnalyticsSection(analytics: analytics),
                  const SizedBox(height: 24),

                  // Categories Section
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _buildCategoriesGrid(),
                  const SizedBox(height: 32),
                ],
              ),
            );
          } else if (state is HomeError) {
            return Center(child: Text('Error: ${state.message}'));
          } else {
            return const Center(child: Text('Loading...'));
          }
        },
      ),
    );
  }
}

/// A little helper widget for displaying label/value pairs:
class _StatTile extends StatelessWidget {
  final String label;
  final String value;

  const _StatTile({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.bodyMedium),
      ],
    );
  }
}

/// Tiny model to store each category's label/image/route:
class _CategoryData {
  final String label;
  final String imageUrl;
  final String routeName;

  const _CategoryData({
    required this.label,
    required this.imageUrl,
    required this.routeName,
  });
}