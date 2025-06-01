// lib/domain/entities/city.dart
import 'package:equatable/equatable.dart';

import 'country.dart';
import 'person.dart';
import 'place.dart';

class City extends Equatable {
  final int id;
  final String name;
  final int countryId;
  final int? population;
  final double? latitude;
  final double? longitude;
  final Country? country;
  final List<Person>? people;
  final List<Place>? places;

  const City({
    required this.id,
    required this.name,
    required this.countryId,
    this.population,
    this.latitude,
    this.longitude,
    this.country,
    this.people,
    this.places,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    countryId,
    population,
    latitude,
    longitude,
    country,
    people,
    places,
  ];
}
