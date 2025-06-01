// lib/domain/entities/place.dart
import 'package:equatable/equatable.dart';

import 'city.dart';
import 'country.dart';

class Place extends Equatable {
  final int id;
  final String name;
  final int cityId;
  final int countryId;
  final String type;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? description;
  final String? imageUrl;
  final City? city;
  final Country? country;
  final int? visitCount;
  final int? favoriteCount;
  final bool? isFavorite;

  const Place({
    required this.id,
    required this.name,
    required this.cityId,
    required this.countryId,
    required this.type,
    this.address,
    this.latitude,
    this.longitude,
    this.description,
    this.imageUrl,
    this.city,
    this.country,
    this.visitCount,
    this.favoriteCount,
    this.isFavorite,
  });

  String get typeDisplayName {
    switch (type) {
      case 'iglesia':
        return 'Church';
      case 'estadio':
        return 'Stadium';
      case 'museo':
        return 'Museum';
      case 'restaurante':
        return 'Restaurant';
      case 'hotel':
        return 'Hotel';
      case 'parque':
        return 'Park';
      case 'monumento':
        return 'Monument';
      case 'teatro':
        return 'Theater';
      case 'plaza':
        return 'Plaza';
      default:
        return 'Other';
    }
  }

  @override
  List<Object?> get props => [
    id,
    name,
    cityId,
    countryId,
    type,
    address,
    latitude,
    longitude,
    description,
    imageUrl,
    city,
    country,
    visitCount,
    favoriteCount,
    isFavorite,
  ];
}
