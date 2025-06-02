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
    // 1) Parse the simple fields
    final int id = json['id'] as int;
    final int userId = json['user_id'] as int;
    final int personId = json['person_id'] as int;
    final String comment = json['comment'] as String;
    final String? photoUrl = json['photo_url'] as String?;
    final double? latitude = json['latitude'] != null
        ? double.tryParse(json['latitude'].toString())
        : null;
    final double? longitude = json['longitude'] != null
        ? double.tryParse(json['longitude'].toString())
        : null;

    // 2) Try to parse the nested "user" ONLY if it has the fields that UserModel needs.
    UserModel? user;
    if (json['user'] != null) {
      try {
        user = UserModel.fromJson(json['user'] as Map<String, dynamic>);
      } catch (_) {
        // If parsing fails (e.g. missing required fields), just leave `user` as null.
        user = null;
      }
    }

    // 3) Parse the nested "person" if present
    PersonModel? person;
    if (json['person'] != null) {
      try {
        person = PersonModel.fromJson(json['person'] as Map<String, dynamic>);
      } catch (_) {
        person = null;
      }
    }

    return TagModel(
      id: id,
      userId: userId,
      personId: personId,
      comment: comment,
      photoUrl: photoUrl,
      latitude: latitude,
      longitude: longitude,
      user: user,
      person: person,
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
