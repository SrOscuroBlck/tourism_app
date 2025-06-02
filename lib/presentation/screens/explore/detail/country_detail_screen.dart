// lib/presentation/screens/explore/country_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:tourismapp/presentation/screens/explore/detail/person_detail_screen.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/country.dart';
import '../../../../domain/entities/city.dart';
import '../../../../domain/entities/place.dart';
import '../../../../domain/entities/person.dart';
import '../../../../domain/entities/dish.dart';
import '../../../../domain/repositories/city_repository.dart';
import '../../../../domain/repositories/place_repository.dart';
import '../../../../domain/repositories/person_repository.dart';
import '../../../../domain/repositories/dish_repository.dart';
import '../../../../injection_container.dart';
import '../../../widgets/cards/city_card.dart';
import '../../../widgets/cards/place_card.dart';
import '../../../widgets/cards/person_card.dart';
import '../../../widgets/cards/dish_card.dart';
import '../../../widgets/common/custom_app_bar.dart';
import '../../../widgets/common/loading_widget.dart';
import '../../../widgets/common/error_widget.dart' as AppError;
import '../../places/place_detail_screen.dart';
import 'city_detail_screen.dart';
import 'dish_detail_screen.dart';

class CountryDetailScreen extends StatefulWidget {
  final Country country;

  const CountryDetailScreen({
    Key? key,
    required this.country,
  }) : super(key: key);

  @override
  State<CountryDetailScreen> createState() => _CountryDetailScreenState();
}

class _CountryDetailScreenState extends State<CountryDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final CityRepository _cityRepository = sl<CityRepository>();
  final PlaceRepository _placeRepository = sl<PlaceRepository>();
  final PersonRepository _personRepository = sl<PersonRepository>();
  final DishRepository _dishRepository = sl<DishRepository>();

  List<City> _cities = [];
  List<Place> _places = [];
  List<Person> _people = [];
  List<Dish> _dishes = [];

  bool _isLoadingCities = true;
  bool _isLoadingPlaces = true;
  bool _isLoadingPeople = true;
  bool _isLoadingDishes = true;

  String? _citiesError;
  String? _placesError;
  String? _peopleError;
  String? _dishesError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadCities(),
      _loadPlaces(),
      _loadPeople(),
      _loadDishes(), // now calls getDishesByCountry
    ]);
  }

  Future<void> _loadCities() async {
    final result = await _cityRepository.getAllCities(
      countryId: widget.country.id,
    );
    result.fold(
          (failure) {
        setState(() {
          _citiesError = failure.message ?? 'Failed to load cities';
          _isLoadingCities = false;
        });
      },
          (cities) {
        setState(() {
          _cities = cities;
          _isLoadingCities = false;
        });
      },
    );
  }

  Future<void> _loadPlaces() async {
    final result = await _placeRepository.getAllPlaces(
      countryId: widget.country.id,
    );
    result.fold(
          (failure) {
        setState(() {
          _placesError = failure.message ?? 'Failed to load places';
          _isLoadingPlaces = false;
        });
      },
          (places) {
        setState(() {
          _places = places;
          _isLoadingPlaces = false;
        });
      },
    );
  }

  Future<void> _loadPeople() async {
    final result = await _personRepository.getAllPeople(
      countryId: widget.country.id,
    );
    result.fold(
          (failure) {
        setState(() {
          _peopleError = failure.message ?? 'Failed to load people';
          _isLoadingPeople = false;
        });
      },
          (people) {
        setState(() {
          _people = people;
          _isLoadingPeople = false;
        });
      },
    );
  }

  Future<void> _loadDishes() async {
    // ─────────────── CHANGED HERE ───────────────
    // Instead of getAllDishes(...), call getDishesByCountry(...) so that
    // the repository definitely hits “GET /api/dishes?country_id=<id>”
    final result = await _dishRepository.getDishesByCountry(widget.country.id);

    result.fold(
          (failure) {
        setState(() {
          _dishesError = failure.message ?? 'Failed to load dishes';
          _isLoadingDishes = false;
        });
      },
          (dishes) {
        setState(() {
          _dishes = dishes;
          _isLoadingDishes = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.country.name,
        automaticallyImplyLeading: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Cities'),
            Tab(text: 'Places'),
            Tab(text: 'People'),
            Tab(text: 'Dishes'),
          ],
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
        ),
      ),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ─── Country info header ───────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppColors.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.country.name,
                  style: AppTextStyles.headlineMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.public,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Continent: ${widget.country.continent}',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
                if (widget.country.population != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.people,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Population: ${widget.country.population}',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // ─── Tab contents ───────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCitiesTab(),
                _buildPlacesTab(),
                _buildPeopleTab(),
                _buildDishesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCitiesTab() {
    if (_isLoadingCities) {
      return const Center(child: LoadingWidget(size: 48));
    }
    if (_citiesError != null) {
      return Center(child: AppError.ErrorWidget(message: _citiesError!));
    }
    if (_cities.isEmpty) {
      return const Center(child: Text('No cities found'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _cities.length,
      itemBuilder: (context, index) {
        final city = _cities[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CityCard(
            cityId: city.id,
            name: city.name,
            population: city.population,
            latitude: city.latitude,
            longitude: city.longitude,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CityDetailScreen(city: city),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPlacesTab() {
    if (_isLoadingPlaces) {
      return const Center(child: LoadingWidget(size: 48));
    }
    if (_placesError != null) {
      return Center(child: AppError.ErrorWidget(message: _placesError!));
    }
    if (_places.isEmpty) {
      return const Center(child: Text('No places found'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _places.length,
      itemBuilder: (context, index) {
        final place = _places[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: PlaceCard(
            place: place,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => PlaceDetailScreen(placeId: place.id),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPeopleTab() {
    if (_isLoadingPeople) {
      return const Center(child: LoadingWidget(size: 48));
    }
    if (_peopleError != null) {
      return Center(child: AppError.ErrorWidget(message: _peopleError!));
    }
    if (_people.isEmpty) {
      return const Center(child: Text('No people found'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _people.length,
      itemBuilder: (context, index) {
        final person = _people[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: PersonCard(
            id: person.id,
            name: person.name,
            category: person.category,
            imageUrl: person.imageUrl,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => PersonDetailScreen(person: person),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDishesTab() {
    if (_isLoadingDishes) {
      return const Center(child: LoadingWidget(size: 48));
    }
    if (_dishesError != null) {
      return Center(child: AppError.ErrorWidget(message: _dishesError!));
    }
    if (_dishes.isEmpty) {
      return const Center(child: Text('No dishes found'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _dishes.length,
      itemBuilder: (context, index) {
        final dish = _dishes[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DishCard(
            id: dish.id,
            name: dish.name,
            price: dish.price,
            imageUrl: dish.imageUrl,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DishDetailScreen(dish: dish),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
