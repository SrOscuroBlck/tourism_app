// lib/data/models/city_model.dart
import '../../domain/entities/city.dart';
import 'country_model.dart';
import 'person_model.dart';
import 'place_model.dart';

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
    return CityModel(
      id: json['id'],
      name: json['name'],
      countryId: json['country_id'],
      population: json['population'],
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      country: json['country'] != null
          ? CountryModel.fromJson(json['country'])
          : null,
      people: json['people'] != null
          ? List<PersonModel>.from(
          (json['people'] as List).map((e) => PersonModel.fromJson(e)))
          : null,
      places: json['places'] != null
          ? List<PlaceModel>.from(
          (json['places'] as List).map((e) => PlaceModel.fromJson(e)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country_id': countryId,
      'population': population,
      'latitude': latitude,
      'longitude': longitude,
      'country': country != null ? (country as CountryModel).toJson() : null,
      'people': people != null
          ? (people as List<PersonModel>).map((e) => e.toJson()).toList()
          : null,
      'places': places != null
          ? (places as List<PlaceModel>).map((e) => e.toJson()).toList()
          : null,
    };
  }
}
