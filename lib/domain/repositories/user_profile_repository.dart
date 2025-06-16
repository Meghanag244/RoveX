import '../models/user_profile.dart';

abstract class UserProfileRepository {
  Future<UserProfile> getUserProfile(String uid);
  Future<void> updateUserProfile(UserProfile profile);
  Future<void> updateAvatar(String uid, String avatarUrl);
  Future<List<UserProfile>> searchUsers(String query);
  Future<void> addCompletedHike(String uid, String hikeId);
  Future<void> addCreatedHike(String uid, String hikeId);
  Future<void> createUserProfile(UserProfile profile);
} 