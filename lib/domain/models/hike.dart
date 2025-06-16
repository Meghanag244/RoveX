import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:roveeee/domain/models/beacon.dart';

class Hike extends Equatable {
  final String id;
  final String name;
  final String description;
  final double startLatitude;
  final double startLongitude;
  final double endLatitude;
  final double endLongitude;
  final String userId;
  final DateTime createdAt;
  final bool isPublic;
  final DateTime dateTime;
  final List<String> members;
  final List<Beacon> beacons;

  const Hike({
    required this.id,
    required this.name,
    required this.description,
    required this.startLatitude,
    required this.startLongitude,
    required this.endLatitude,
    required this.endLongitude,
    required this.userId,
    required this.createdAt,
    required this.isPublic,
    required this.dateTime,
    required this.members,
    required this.beacons,
  });

  factory Hike.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Hike(
      id: doc.id,
      name: data['name'] as String,
      description: data['description'] as String,
      startLatitude: data['startLatitude'] as double,
      startLongitude: data['startLongitude'] as double,
      endLatitude: data['endLatitude'] as double,
      endLongitude: data['endLongitude'] as double,
      userId: data['userId'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isPublic: data['isPublic'] as bool,
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      members: List<String>.from(data['members'] as List),
      beacons: (data['beacons'] as List?)?.map((b) => Beacon.fromMap(b)).toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'startLatitude': startLatitude,
      'startLongitude': startLongitude,
      'endLatitude': endLatitude,
      'endLongitude': endLongitude,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'isPublic': isPublic,
      'dateTime': Timestamp.fromDate(dateTime),
      'members': members,
      'beacons': beacons.map((b) => b.toMap()).toList(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        startLatitude,
        startLongitude,
        endLatitude,
        endLongitude,
        userId,
        createdAt,
        isPublic,
        dateTime,
        members,
        beacons,
      ];
} 