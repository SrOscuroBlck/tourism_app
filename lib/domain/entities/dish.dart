// lib/domain/entities/dish.dart
import 'package:equatable/equatable.dart';

import 'place.dart';
import 'country.dart';

class Dish extends Equatable {
  final int id;
  final String name;
  final int countryId;
  final int placeId;
  final String? description;
  final double price;
  final String? imageUrl;
  final Place? place;
  final Country? country;

  const Dish({
    required this.id,
    required this.name,
    required this.countryId,
    required this.placeId,
    this.description,
    required this.price,
    this.imageUrl,
    this.place,
    this.country,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    countryId,
    placeId,
    description,
    price,
    imageUrl,
    place,
    country,
  ];
}
