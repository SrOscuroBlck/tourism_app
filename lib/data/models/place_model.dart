// lib/data/models/place_model.dart
import '../../domain/entities/place.dart';
import 'city_model.dart';
import 'country_model.dart';

class PlaceModel extends Place {
  const PlaceModel({
    required super.id,
    required super.name,
    required super.cityId,
    required super.countryId,
    required super.type,
    super.address,
    super.latitude,
    super.longitude,
    super.description,
    super.imageUrl,
    super.city,
    super.country,
    super.visitCount,
    super.favoriteCount,
    super.isFavorite,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    return PlaceModel(
      id: json['id'],
      name: json['name'],
      cityId: json['city_id'],
      countryId: json['country_id'],
      type: json['type'],
      address: json['address'],
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      description: json['description'],
      imageUrl: json['image_url'],
      city: json['city'] != null ? CityModel.fromJson(json['city']) : null,
      country:
      json['country'] != null ? CountryModel.fromJson(json['country']) : null,
      visitCount: json['visitCount'],
      favoriteCount: json['favoriteCount'],
      isFavorite: json['isFavorite'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city_id': cityId,
      'country_id': countryId,
      'type': type,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'image_url': imageUrl,
      'city': city != null ? (city as CityModel).toJson() : null,
      'country': country != null ? (country as CountryModel).toJson() : null,
      'visitCount': visitCount,
      'favoriteCount': favoriteCount,
      'isFavorite': isFavorite,
    };
  }
}
