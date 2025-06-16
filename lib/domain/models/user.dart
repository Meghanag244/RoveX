import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String username;
  final String email;
  final String name;
  final String password; // Note: In a real app, this should be hashed
  final DateTime createdAt;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.name,
    required this.password,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        username,
        email,
        name,
        password,
        createdAt,
      ];
} 