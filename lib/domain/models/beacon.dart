import 'package:cloud_firestore/cloud_firestore.dart';

class Beacon {
  final String id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final String createdBy;
  final DateTime createdAt;
  final List<String> foundBy;

  Beacon({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.createdBy,
    required this.createdAt,
    required this.foundBy,
  });

  factory Beacon.fromMap(Map<String, dynamic> map) {
    return Beacon(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      createdBy: map['createdBy'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      foundBy: List<String>.from(map['foundBy'] as List),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'foundBy': foundBy,
    };
  }
} 