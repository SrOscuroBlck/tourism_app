// lib/data/models/visit_model.dart
import '../../domain/entities/visit.dart';
import 'place_model.dart';

class VisitModel extends Visit {
  const VisitModel({
    required super.id,
    required super.userId,
    required super.placeId,
    required super.visitedAt,
    super.latitude,
    super.longitude,
    super.photoUrl,
    super.place,
  });

  factory VisitModel.fromJson(Map<String, dynamic> json) {
    return VisitModel(
      id: json['id'],
      userId: json['user_id'],
      placeId: json['place_id'],
      visitedAt: DateTime.parse(json['visited_at']),
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      photoUrl: json['photo_url'],
      place: json['place'] != null ? PlaceModel.fromJson(json['place']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'place_id': placeId,
      'visited_at': visitedAt.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'photo_url': photoUrl,
      'place': place != null ? (place as PlaceModel).toJson() : null,
    };
  }
}
