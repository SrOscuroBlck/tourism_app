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
    // 1) Grab the raw value from JSON:
    final rawPrice = json['price'];

    // 2) Convert it into a double no matter whether it's already a num or is a String:
    double parsedPrice;
    if (rawPrice is num) {
      parsedPrice = rawPrice.toDouble();
    } else if (rawPrice is String) {
      parsedPrice = double.parse(rawPrice);
    } else {
      // In case something unexpected arrives, you can choose a default or throw.
      parsedPrice = 0.0;
    }

    return DishModel(
      id: json['id'] as int,
      name: json['name'] as String,
      countryId: json['country_id'] as int,
      placeId: json['place_id'] as int,
      description: json['description'] as String?,
      price: parsedPrice,
      imageUrl: json['image_url'] as String?,
      place: json['place'] != null
          ? PlaceModel.fromJson(json['place'] as Map<String, dynamic>)
          : null,
      country: json['country'] != null
          ? CountryModel.fromJson(json['country'] as Map<String, dynamic>)
          : null,
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
