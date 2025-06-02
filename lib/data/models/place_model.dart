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
    // Helper to safely parse an int (whether the JSON value is already an int,
    // or a stringified int, or null).
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    // Helper to safely parse a double (whether the JSON value is already a double,
    // or a stringified double, or null).
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? null;
      return null;
    }

    final id = parseInt(json['id']);
    final name = json['name']?.toString() ?? '';
    final cityId = parseInt(json['city_id']);
    final countryId = parseInt(json['country_id']);
    final type = json['type']?.toString() ?? '';
    final address = json['address']?.toString();
    final latitude = parseDouble(json['latitude']);
    final longitude = parseDouble(json['longitude']);
    final description = json['description']?.toString();
    final imageUrl = json['image_url']?.toString();

    // Manually construct a CityModel using the parent’s city_id:
    CityModel? city;
    if (json['city'] != null) {
      final cityJson = json['city'] as Map<String, dynamic>;
      city = CityModel(
        id: parseInt(cityJson['id']),
        name: cityJson['name']?.toString() ?? '',
        countryId: cityId, // use the parent’s city_id → countryId   (if you want the countryId embedded here)
      );
    }

    // Manually construct a CountryModel with an empty‐string for continent:
    CountryModel? country;
    if (json['country'] != null) {
      final countryJson = json['country'] as Map<String, dynamic>;
      country = CountryModel(
        id: parseInt(countryJson['id']),
        name: countryJson['name']?.toString() ?? '',
        // The nested "country" object from /api/places does NOT include "continent",
        // so we supply an empty string here to satisfy the non‐nullable constructor.
        continent: '',
      );
    }

    final visitCount = parseInt(json['visitCount']);
    final favoriteCount = parseInt(json['favoriteCount']);
    final isFavorite = (json['isFavorite'] is bool) ? (json['isFavorite'] as bool) : false;

    return PlaceModel(
      id: id,
      name: name,
      cityId: cityId,
      countryId: countryId,
      type: type,
      address: address,
      latitude: latitude,
      longitude: longitude,
      description: description,
      imageUrl: imageUrl,
      city: city,
      country: country,
      visitCount: visitCount,
      favoriteCount: favoriteCount,
      isFavorite: isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city_id': cityId,
      'country_id': countryId,
      'type': type,
      if (address != null) 'address': address,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (description != null) 'description': description,
      if (imageUrl != null) 'image_url': imageUrl,
      // We omit the nested city/country fields here since they're mainly for display;
      // if you do need them in your POST/PUT, you can re‐enable as needed.
      'visitCount': visitCount,
      'favoriteCount': favoriteCount,
      'isFavorite': isFavorite,
    };
  }
}
