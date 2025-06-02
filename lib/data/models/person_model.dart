// lib/data/models/person_model.dart

import '../../domain/entities/person.dart';
import 'city_model.dart';
import 'country_model.dart';

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
    super.tags, // We’ll leave this null here
  });

  factory PersonModel.fromJson(Map<String, dynamic> json) {
    return PersonModel(
      id: json['id'] as int,
      name: json['name'] as String,
      cityId: json['city_id'] as int,
      countryId: json['country_id'] as int,
      category: json['category'] as String,
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'] as String)
          : null,
      biography: json['biography'] as String?,
      imageUrl: json['image_url'] as String?,
      city: json['city'] != null
          ? CityModel.fromJson(json['city'] as Map<String, dynamic>)
          : null,
      country: json['country'] != null
          ? CountryModel.fromJson(json['country'] as Map<String, dynamic>)
          : null,

      // We deliberately do NOT parse `tags` here. The API only returned “[{id:1}, …]”,
      // which doesn’t contain userId, personId, comment, etc. Those come from a separate endpoint.
      tags: null,
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
      // We omit `tags` here as well
    };
  }
}
