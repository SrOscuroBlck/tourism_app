// lib/data/models/tag_model.dart
import '../../domain/entities/tag.dart';
import 'user_model.dart';
import 'person_model.dart';

class TagModel extends Tag {
  const TagModel({
    required super.id,
    required super.userId,
    required super.personId,
    required super.comment,
    super.photoUrl,
    super.latitude,
    super.longitude,
    super.user,
    super.person,
  });

  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
      id: json['id'],
      userId: json['user_id'],
      personId: json['person_id'],
      comment: json['comment'],
      photoUrl: json['photo_url'],
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      person:
      json['person'] != null ? PersonModel.fromJson(json['person']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'person_id': personId,
      'comment': comment,
      'photo_url': photoUrl,
      'latitude': latitude,
      'longitude': longitude,
      'user': user != null ? (user as UserModel).toJson() : null,
      'person': person != null ? (person as PersonModel).toJson() : null,
    };
  }
}
