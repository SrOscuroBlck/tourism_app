// lib/domain/entities/country.dart
import 'package:equatable/equatable.dart';

import 'city.dart';
import 'person.dart';
import 'place.dart';
import 'dish.dart';

class Country extends Equatable {
  final int id;
  final String name;
  final int? population;
  final String continent;
  final List<City>? cities;
  final List<Person>? people;
  final List<Place>? places;
  final List<Dish>? dishes;

  const Country({
    required this.id,
    required this.name,
    this.population,
    required this.continent,
    this.cities,
    this.people,
    this.places,
    this.dishes,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    population,
    continent,
    cities,
    people,
    places,
    dishes,
  ];
}
