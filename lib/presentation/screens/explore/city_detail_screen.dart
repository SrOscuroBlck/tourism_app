// lib/presentation/screens/explore/city_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/usecases/places/get_places_uscase.dart';
import '../../widgets/cards/place_card.dart';
import '../../widgets/cards/person_card.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../../domain/entities/city.dart';
import '../../../domain/entities/person.dart';
import '../../../domain/repositories/city_repository.dart';
import '../../../domain/repositories/person_repository.dart';
import '../../blocs/places/places_bloc.dart';

class CityDetailScreen extends StatelessWidget {
  const CityDetailScreen({Key? key}) : super(key: key);

  Future<City> _fetchCityById(int cityId) async {
    final repo = GetIt.I<CityRepository>();
    final either = await repo.getCityById(cityId);
    return either.fold(
          (failure) => throw Exception(failure.message),
          (city) => city,
    );
  }

  Future<List<Person>> _fetchPeopleInCity(int cityId) async {
    final repo = GetIt.I<PersonRepository>();
    // Notice: we call getAllPeople(cityId: …) since getPeopleByCityId() doesn’t exist.
    final either = await repo.getAllPeople(cityId: cityId);
    return either.fold(
          (failure) => throw Exception(failure.message),
          (people) => people,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cityId = ModalRoute.of(context)?.settings.arguments as int?;
    if (cityId == null) {
      return const Scaffold(
        body: Center(child: Text('No city ID provided.')),
      );
    }

    return FutureBuilder<City>(
      future: _fetchCityById(cityId),
      builder: (context, citySnapshot) {
        if (citySnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (citySnapshot.hasError) {
          return Scaffold(
            appBar: const CustomAppBar(title: 'City Detail'),
            body: Center(child: Text('Error: ${citySnapshot.error}')),
          );
        } else if (citySnapshot.hasData) {
          final city = citySnapshot.data!;
          return Scaffold(
            appBar: CustomAppBar(
              title: city.name,
              automaticallyImplyLeading: true,
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Map Preview (placeholder) ───
                  Container(
                    height: 200,
                    color: Colors.grey.shade300,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.map, size: 48, color: Colors.grey),
                          SizedBox(width: 8),
                          Text('Map Preview', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),

                  // ─── City Info ───
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          city.name,
                          style: AppTextStyles.headlineMedium.copyWith(
                              color: AppColors.primary),
                        ),
                        const SizedBox(height: 8),
                        if (city.population != null)
                          Text(
                            'Population: ${city.population}',
                            style: AppTextStyles.bodyMedium,
                          ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              '${city.latitude?.toStringAsFixed(3) ?? '—'}, '
                                  '${city.longitude?.toStringAsFixed(3) ?? '—'}',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Divider(),

                  // ─── Places in this City ───
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Text(
                      'Places in ${city.name}',
                      style: AppTextStyles.headlineSmall,
                    ),
                  ),
                  BlocProvider(
                    create: (_) => PlacesBloc(
                      getPlacesUseCase: GetIt.I<GetPlacesUseCase>(),
                    )..add(FetchPlaces(cityId: cityId)),
                    child: const _PlacesByCityTab(),
                  ),

                  const SizedBox(height: 16),

                  // ─── Famous People in this City ───
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Text(
                      'Famous People from ${city.name}',
                      style: AppTextStyles.headlineSmall,
                    ),
                  ),
                  FutureBuilder<List<Person>>(
                    future: _fetchPeopleInCity(cityId),
                    builder: (context, personSnap) {
                      if (personSnap.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (personSnap.hasError) {
                        return Center(
                            child: Text('Error: ${personSnap.error}'));
                      } else if (personSnap.hasData) {
                        final people = personSnap.data!;
                        if (people.isEmpty) {
                          return const Center(
                              child: Text('No famous people found.'));
                        }
                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: people.length,
                          separatorBuilder: (_, __) =>
                          const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final p = people[index];
                            return PersonCard(
                              id: p.id,
                              name: p.name,
                              category: p.category,
                              imageUrl: p.imageUrl ?? '',
                              onTap: () {
                                // TODO: push PersonDetailScreen if implemented
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Tapped ${p.name}')),
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

                  const SizedBox(height: 32),
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

class _PlacesByCityTab extends StatelessWidget {
  const _PlacesByCityTab({Key? key}) : super(key: key);

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
          // Display horizontally
          return SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: places.length,
              itemBuilder: (ctx, idx) {
                final place = places[idx];
                return Padding(
                  padding: EdgeInsets.only(
                    left: idx == 0 ? 16 : 8,
                    right: idx == places.length - 1 ? 16 : 8,
                  ),
                  child: SizedBox(
                    width: 160,
                    child: PlaceCard(
                      place: place,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/place_detail',
                          arguments: place.id,
                        );
                      },
                    ),
                  ),
                );
              },
            ),
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
