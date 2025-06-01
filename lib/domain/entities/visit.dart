// lib/domain/entities/visit.dart
import 'package:equatable/equatable.dart';

import 'place.dart';

class Visit extends Equatable {
  final int id;
  final int userId;
  final int placeId;
  final DateTime visitedAt;
  final double? latitude;
  final double? longitude;
  final String? photoUrl;
  final Place? place;

  const Visit({
    required this.id,
    required this.userId,
    required this.placeId,
    required this.visitedAt,
    this.latitude,
    this.longitude,
    this.photoUrl,
    this.place,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    placeId,
    visitedAt,
    latitude,
    longitude,
    photoUrl,
    place,
  ];
}
