import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile extends Equatable {
  final String uid;
  final String username;
  final String? avatarUrl;
  final String? bio;
  final List<String> completedHikes;
  final List<String> createdHikes;
  final DateTime createdAt;
  final DateTime lastUpdated;

  const UserProfile({
    required this.uid,
    required this.username,
    this.avatarUrl,
    this.bio,
    this.completedHikes = const [],
    this.createdHikes = const [],
    required this.createdAt,
    required this.lastUpdated,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] as String,
      username: map['username'] as String,
      avatarUrl: map['avatarUrl'] as String?,
      bio: map['bio'] as String?,
      completedHikes: List<String>.from(map['completedHikes'] ?? []),
      createdHikes: List<String>.from(map['createdHikes'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastUpdated: (map['lastUpdated'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'completedHikes': completedHikes,
      'createdHikes': createdHikes,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  UserProfile copyWith({
    String? username,
    String? avatarUrl,
    String? bio,
    List<String>? completedHikes,
    List<String>? createdHikes,
    DateTime? lastUpdated,
  }) {
    return UserProfile(
      uid: uid,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      completedHikes: completedHikes ?? this.completedHikes,
      createdHikes: createdHikes ?? this.createdHikes,
      createdAt: createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
        uid,
        username,
        avatarUrl,
        bio,
        completedHikes,
        createdHikes,
        createdAt,
        lastUpdated,
      ];
} 