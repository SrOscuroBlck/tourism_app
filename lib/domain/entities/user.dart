// lib/domain/entities/user.dart
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String email;
  final String name;
  final String role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.createdAt,
    this.updatedAt,
  });

  bool get isAdmin => role == 'admin';

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    role,
    createdAt,
    updatedAt,
  ];
}
