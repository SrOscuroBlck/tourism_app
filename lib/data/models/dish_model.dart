// lib/data/models/dish_model.dart
import '../../domain/entities/dish.dart';
import 'place_model.dart';
import 'country_model.dart';

class DishModel extends Dish {
  const DishModel({
    required super.id,
    required super.name,
    required super.countryId,
    required super.placeId,
    super.description,
    required super.price,
    super.imageUrl,
    super.place,
    super.country,
  });

  factory DishModel.fromJson(Map<String, dynamic> json) {
    return DishModel(
      id: json['id'],
      name: json['name'],
      countryId: json['country_id'],
      placeId: json['place_id'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'],
      place: json['place'] != null ? PlaceModel.fromJson(json['place']) : null,
      country:
      json['country'] != null ? CountryModel.fromJson(json['country']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country_id': countryId,
      'place_id': placeId,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'place': place != null ? (place as PlaceModel).toJson() : null,
      'country': country != null ? (country as CountryModel).toJson() : null,
    };
  }
}
