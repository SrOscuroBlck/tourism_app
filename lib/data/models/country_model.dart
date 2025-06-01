// lib/data/models/country_model.dart
import '../../domain/entities/country.dart';
import 'city_model.dart';
import 'person_model.dart';
import 'place_model.dart';
import 'dish_model.dart';

class CountryModel extends Country {
  const CountryModel({
    required super.id,
    required super.name,
    super.population,
    required super.continent,
    super.cities,
    super.people,
    super.places,
    super.dishes,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      id: json['id'],
      name: json['name'],
      population: json['population'] != null
          ? (json['population'] as num).toInt()
          : null,
      continent: json['continent'],
      cities: json['cities'] != null
          ? List<CityModel>.from(
          (json['cities'] as List).map((e) => CityModel.fromJson(e)))
          : null,
      people: json['people'] != null
          ? List<PersonModel>.from(
          (json['people'] as List).map((e) => PersonModel.fromJson(e)))
          : null,
      places: json['places'] != null
          ? List<PlaceModel>.from(
          (json['places'] as List).map((e) => PlaceModel.fromJson(e)))
          : null,
      dishes: json['dishes'] != null
          ? List<DishModel>.from(
          (json['dishes'] as List).map((e) => DishModel.fromJson(e)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'population': population,
      'continent': continent,
      'cities': cities != null
          ? (cities as List<CityModel>).map((e) => e.toJson()).toList()
          : null,
      'people': people != null
          ? (people as List<PersonModel>).map((e) => e.toJson()).toList()
          : null,
      'places': places != null
          ? (places as List<PlaceModel>).map((e) => e.toJson()).toList()
          : null,
      'dishes': dishes != null
          ? (dishes as List<DishModel>).map((e) => e.toJson()).toList()
          : null,
    };
  }
}
