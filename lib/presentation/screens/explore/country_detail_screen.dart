// lib/presentation/screens/explore/country_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/usecases/places/get_places_uscase.dart';
import '../../widgets/cards/city_card.dart';
import '../../widgets/cards/place_card.dart';
import '../../widgets/cards/person_card.dart';
import '../../widgets/cards/dish_card.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../../domain/entities/city.dart';
import '../../../domain/entities/country.dart';
import '../../../domain/entities/person.dart';
import '../../../domain/entities/dish.dart';
import '../../../domain/repositories/city_repository.dart';
import '../../../domain/repositories/country_repository.dart';
import '../../../domain/repositories/person_repository.dart';
import '../../../domain/repositories/dish_repository.dart';
import '../../blocs/places/places_bloc.dart';

class CountryDetailScreen extends StatelessWidget {
  const CountryDetailScreen({Key? key}) : super(key: key);

  Future<Country> _fetchCountryById(int countryId) async {
    final repo = GetIt.I<CountryRepository>();
    final either = await repo.getCountryById(countryId);
    return either.fold(
          (failure) => throw Exception(failure.message),
          (country) => country,
    );
  }

  Future<List<City>> _fetchCities(int countryId) async {
    final repo = GetIt.I<CityRepository>();
    final either = await repo.getAllCities(countryId: countryId);
    return either.fold(
          (failure) => throw Exception(failure.message),
          (cities) => cities,
    );
  }

  Future<List<Person>> _fetchPeople(int countryId) async {
    final repo = GetIt.I<PersonRepository>();
    final either = await repo.getAllPeople(countryId: countryId);
    return either.fold(
          (failure) => throw Exception(failure.message),
          (people) => people,
    );
  }

  Future<List<Dish>> _fetchDishes(int countryId) async {
    final repo = GetIt.I<DishRepository>();
    final either = await repo.getAllDishes(countryId: countryId);
    return either.fold(
          (failure) => throw Exception(failure.message),
          (dishes) => dishes,
    );
  }

  @override
  Widget build(BuildContext context) {
    final countryId = ModalRoute.of(context)?.settings.arguments as int?;
    if (countryId == null) {
      return const Scaffold(
        body: Center(child: Text('No country ID provided.')),
      );
    }

    return FutureBuilder<Country>(
      future: _fetchCountryById(countryId),
      builder: (context, countrySnapshot) {
        if (countrySnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (countrySnapshot.hasError) {
          return Scaffold(
            appBar: const CustomAppBar(title: 'Country Detail'),
            body: Center(child: Text('Error: ${countrySnapshot.error}')),
          );
        } else if (countrySnapshot.hasData) {
          final country = countrySnapshot.data!;
          return DefaultTabController(
            length: 4,
            child: Scaffold(
              appBar: CustomAppBar(
                title: country.name,
                automaticallyImplyLeading: true,
                bottom: TabBar(
                  indicatorColor: AppColors.primary,
                  tabs: const [
                    Tab(text: 'Cities'),
                    Tab(text: 'Places'),
                    Tab(text: 'People'),
                    Tab(text: 'Dishes'),
                  ],
                ),
              ),
              body: Column(
                children: [
                  // ─── Country Header ───
                  Container(
                    color: AppColors.surface,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.public, size: 48, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                country.name,
                                style: AppTextStyles.headlineMedium.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Population: ${country.population ?? 'N/A'}',
                                style: AppTextStyles.bodyMedium,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Continent: ${country.continent}',
                                style: AppTextStyles.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ─── Tabs ───
                  Expanded(
                    child: TabBarView(
                      children: [
                        // ─── 1) Cities Tab ───
                        FutureBuilder<List<City>>(
                          future: _fetchCities(countryId),
                          builder: (context, citySnap) {
                            if (citySnap.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (citySnap.hasError) {
                              return Center(child: Text('Error: ${citySnap.error}'));
                            } else if (citySnap.hasData) {
                              final cities = citySnap.data!;
                              if (cities.isEmpty) {
                                return const Center(child: Text('No cities found.'));
                              }
                              return ListView.separated(
                                padding:
                                const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                itemCount: cities.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 8),
                                itemBuilder: (ctx, idx) {
                                  final city = cities[idx];
                                  return CityCard(
                                    cityId: city.id,
                                    name: city.name,
                                    population: city.population,
                                    latitude: city.latitude,
                                    longitude: city.longitude,
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/city_detail',
                                        arguments: city.id,
                                      );
                                    },
                                  );
                                },
                              );
                            } else {
                              return const Center(child: Text('No data.'));
                            }
                          },
                        ),

                        // ─── 2) Places Tab ───
                        BlocProvider(
                          create: (_) => PlacesBloc(
                            getPlacesUseCase: GetIt.I<GetPlacesUseCase>(),
                          )..add(FetchPlaces(countryId: countryId)),
                          child: const _PlacesByCountryTab(),
                        ),

                        // ─── 3) People Tab ───
                        FutureBuilder<List<Person>>(
                          future: _fetchPeople(countryId),
                          builder: (context, personSnap) {
                            if (personSnap.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (personSnap.hasError) {
                              return Center(child: Text('Error: ${personSnap.error}'));
                            } else if (personSnap.hasData) {
                              final people = personSnap.data!;
                              if (people.isEmpty) {
                                return const Center(child: Text('No famous people found.'));
                              }
                              return ListView.separated(
                                padding:
                                const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                itemCount: people.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 8),
                                itemBuilder: (ctx, idx) {
                                  final p = people[idx];
                                  return PersonCard(
                                    id: p.id,
                                    name: p.name,
                                    category: p.category,
                                    imageUrl: p.imageUrl ?? '',
                                    onTap: () {
                                      // TODO: push a PersonDetailScreen when implemented
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Clicked ${p.name}')),
                                      );
                                    },
                                  );
                                },
                              );
                            } else {
                              return const Center(child: Text('No data.'));
                            }
                          },
                        ),

                        // ─── 4) Dishes Tab ───
                        FutureBuilder<List<Dish>>(
                          future: _fetchDishes(countryId),
                          builder: (context, dishSnap) {
                            if (dishSnap.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (dishSnap.hasError) {
                              return Center(child: Text('Error: ${dishSnap.error}'));
                            } else if (dishSnap.hasData) {
                              final dishes = dishSnap.data!;
                              if (dishes.isEmpty) {
                                return const Center(child: Text('No dishes found.'));
                              }
                              return ListView.separated(
                                padding:
                                const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                itemCount: dishes.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 8),
                                itemBuilder: (ctx, idx) {
                                  final d = dishes[idx];
                                  return DishCard(
                                    id: d.id,
                                    name: d.name,
                                    price: d.price,
                                    imageUrl: d.imageUrl ?? '',
                                    onTap: () {
                                      // TODO: push a DishDetailScreen when implemented
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Clicked ${d.name}')),
                                      );
                                    },
                                  );
                                },
                              );
                            } else {
                              return const Center(child: Text('No data.'));
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const Scaffold(
            body: Center(child: Text('Unknown error.')),
          );
        }
      },
    );
  }
}

/// ─── “Places by Country” Tab ───
class _PlacesByCountryTab extends StatelessWidget {
  const _PlacesByCountryTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlacesBloc, PlacesState>(
      builder: (context, state) {
        if (state is PlacesLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is PlacesLoaded) {
          final places = state.places;
          if (places.isEmpty) {
            return const Center(child: Text('No places found.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            itemCount: places.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (ctx, idx) {
              final place = places[idx];
              return PlaceCard(
                place: place,
                onTap: () {
                  Navigator.pushNamed(context, '/place_detail', arguments: place.id);
                },
              );
            },
          );
        } else if (state is PlacesError) {
          return Center(child: Text('Error: ${state.message}'));
        } else {
          return const Center(child: Text('No data.'));
        }
      },
    );
  }
}
