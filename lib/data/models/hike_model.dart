import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:roveeee/domain/models/hike.dart';
import 'package:roveeee/domain/models/beacon.dart';

class HikeModel {
  final String id;
  final String name;
  final String description;
  final String teamLeader;
  final bool isPublic;
  final LatLng startPoint;
  final LatLng endPoint;
  final DateTime scheduledDateTime;
  final List<String> members;
  final List<String> invitedUsers;
  final DateTime createdAt;
  final List<Beacon> beacons;
  final bool isActive;

  HikeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.teamLeader,
    required this.isPublic,
    required this.startPoint,
    required this.endPoint,
    required this.scheduledDateTime,
    required this.members,
    required this.invitedUsers,
    required this.createdAt,
    required this.beacons,
    this.isActive = false,
  });

  factory HikeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HikeModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      teamLeader: data['teamLeader'] ?? '',
      isPublic: data['isPublic'] ?? true,
      startPoint: LatLng(
        data['startLatitude'] ?? 0.0,
        data['startLongitude'] ?? 0.0,
      ),
      endPoint: LatLng(
        data['endLatitude'] ?? 0.0,
        data['endLongitude'] ?? 0.0,
      ),
      scheduledDateTime: (data['dateTime'] as Timestamp).toDate(),
      members: List<String>.from(data['members'] ?? []),
      invitedUsers: List<String>.from(data['invitedUsers'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      beacons: (data['beacons'] as List?)?.map((b) => Beacon.fromMap(b)).toList() ?? [],
      isActive: data['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'teamLeader': teamLeader,
      'isPublic': isPublic,
      'startLatitude': startPoint.latitude,
      'startLongitude': startPoint.longitude,
      'endLatitude': endPoint.latitude,
      'endLongitude': endPoint.longitude,
      'dateTime': Timestamp.fromDate(scheduledDateTime),
      'members': members,
      'invitedUsers': invitedUsers,
      'createdAt': Timestamp.fromDate(createdAt),
      'beacons': beacons.map((b) => b.toMap()).toList(),
      'isActive': isActive,
    };
  }

  HikeModel copyWith({
    String? name,
    String? description,
    bool? isPublic,
    LatLng? startPoint,
    LatLng? endPoint,
    DateTime? scheduledDateTime,
    List<String>? members,
    List<String>? invitedUsers,
    List<Beacon>? beacons,
    bool? isActive,
  }) {
    return HikeModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      teamLeader: teamLeader,
      isPublic: isPublic ?? this.isPublic,
      startPoint: startPoint ?? this.startPoint,
      endPoint: endPoint ?? this.endPoint,
      scheduledDateTime: scheduledDateTime ?? this.scheduledDateTime,
      members: members ?? this.members,
      invitedUsers: invitedUsers ?? this.invitedUsers,
      createdAt: createdAt,
      beacons: beacons ?? this.beacons,
      isActive: isActive ?? this.isActive,
    );
  }

  Hike toHike() {
    return Hike(
      id: id,
      name: name,
      description: description,
      startLatitude: startPoint.latitude,
      startLongitude: startPoint.longitude,
      endLatitude: endPoint.latitude,
      endLongitude: endPoint.longitude,
      userId: teamLeader,
      createdAt: createdAt,
      isPublic: isPublic,
      dateTime: scheduledDateTime,
      members: members,
      beacons: beacons,
    );
  }

  bool canInviteUsers(String userId) {
    return teamLeader == userId;
  }

  bool canRemoveUser(String userId, String userToRemove) {
    return teamLeader == userId && userToRemove != teamLeader;
  }

  bool isMember(String userId) {
    return members.contains(userId);
  }

  bool isInvited(String userId) {
    return invitedUsers.contains(userId);
  }

  bool canJoin(String userId) {
    return isPublic || isInvited(userId);
  }
} 