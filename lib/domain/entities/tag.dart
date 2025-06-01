// lib/domain/entities/tag.dart
import 'package:equatable/equatable.dart';

import 'user.dart';
import 'person.dart';

class Tag extends Equatable {
  final int id;
  final int userId;
  final int personId;
  final String comment;
  final String? photoUrl;
  final double? latitude;
  final double? longitude;
  final User? user;
  final Person? person;

  const Tag({
    required this.id,
    required this.userId,
    required this.personId,
    required this.comment,
    this.photoUrl,
    this.latitude,
    this.longitude,
    this.user,
    this.person,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    personId,
    comment,
    photoUrl,
    latitude,
    longitude,
    user,
    person,
  ];
}
