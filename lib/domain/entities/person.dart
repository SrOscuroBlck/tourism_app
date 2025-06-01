// lib/domain/entities/person.dart
import 'package:equatable/equatable.dart';

import 'city.dart';
import 'country.dart';
import 'tag.dart';

class Person extends Equatable {
  final int id;
  final String name;
  final int cityId;
  final int countryId;
  final String category;
  final DateTime? birthDate;
  final String? biography;
  final String? imageUrl;
  final City? city;
  final Country? country;
  final List<Tag>? tags;

  const Person({
    required this.id,
    required this.name,
    required this.cityId,
    required this.countryId,
    required this.category,
    this.birthDate,
    this.biography,
    this.imageUrl,
    this.city,
    this.country,
    this.tags,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    cityId,
    countryId,
    category,
    birthDate,
    biography,
    imageUrl,
    city,
    country,
    tags,
  ];
}
