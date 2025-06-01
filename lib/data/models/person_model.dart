// lib/data/models/person_model.dart
import '../../domain/entities/person.dart';
import 'city_model.dart';
import 'country_model.dart';
import 'tag_model.dart';

class PersonModel extends Person {
  const PersonModel({
    required super.id,
    required super.name,
    required super.cityId,
    required super.countryId,
    required super.category,
    super.birthDate,
    super.biography,
    super.imageUrl,
    super.city,
    super.country,
    super.tags,
  });

  factory PersonModel.fromJson(Map<String, dynamic> json) {
    return PersonModel(
      id: json['id'],
      name: json['name'],
      cityId: json['city_id'],
      countryId: json['country_id'],
      category: json['category'],
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'])
          : null,
      biography: json['biography'],
      imageUrl: json['image_url'],
      city: json['city'] != null ? CityModel.fromJson(json['city']) : null,
      country:
      json['country'] != null ? CountryModel.fromJson(json['country']) : null,
      tags: json['tags'] != null
          ? List<TagModel>.from(
          (json['tags'] as List).map((e) => TagModel.fromJson(e)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city_id': cityId,
      'country_id': countryId,
      'category': category,
      'birth_date': birthDate?.toIso8601String(),
      'biography': biography,
      'image_url': imageUrl,
      'city': city != null ? (city as CityModel).toJson() : null,
      'country': country != null ? (country as CountryModel).toJson() : null,
      'tags': tags != null
          ? (tags as List<TagModel>).map((e) => e.toJson()).toList()
          : null,
    };
  }
}
