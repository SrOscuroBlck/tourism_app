import '../../domain/entities/city.dart';

class CityModel extends City {
  const CityModel({
    required super.id,
    required super.name,
    required super.countryId,
    super.population,
    super.latitude,
    super.longitude,
    super.country,
    super.people,
    super.places,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    // Helper to parse an int (in case JSON is string‐encoded, etc.)
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    // Helper to parse a double
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? null;
      return null;
    }

    return CityModel(
      id: parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      // The top‐level "city" object you get under /api/places/: it does NOT include "country_id"
      // so we default to 0 if missing. If you are calling GET /api/cities, that JSON _should_ include
      // 'country_id'—otherwise you might want to pass it in from your use case.
      countryId: parseInt(json['country_id']),
      population: json['population'] != null
          ? (int.tryParse(json['population'].toString()) ?? null)
          : null,
      latitude: parseDouble(json['latitude']),
      longitude: parseDouble(json['longitude']),
      // We leave nested country/people/places as null by default here
      country: null,
      people: null,
      places: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country_id': countryId,
      if (population != null) 'population': population,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      // Omit nested lists for simplicity; add back if you need them in a PUT/POST
    };
  }
}
