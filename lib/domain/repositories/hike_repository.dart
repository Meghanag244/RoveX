import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:roveeee/domain/models/hike.dart';
import 'package:roveeee/domain/models/beacon.dart';
import '../../data/models/hike_model.dart';

abstract class HikeRepository {
  Future<List<HikeModel>> getHikes();
  Future<HikeModel> createHike(HikeModel hike);
  Future<void> joinHike(String hikeId, String userId);
  Future<void> leaveHike(String hikeId, String userId);
  Future<List<HikeModel>> getUserHikes(String userId);
  Future<List<HikeModel>> getPublicHikes();
  Future<void> updateHike(HikeModel hike);
  Future<void> deleteHike(String hikeId);
  Future<void> addBeacon(String hikeId, Beacon beacon);
  Future<void> removeBeacon(String hikeId, String beaconId);
  Future<void> markBeaconAsFound(String hikeId, String beaconId, String userId);
  Future<List<Beacon>> getNearbyBeacons(String hikeId, double latitude, double longitude, double radiusInKm);
  
  // New member management methods
  Future<void> inviteUser(String hikeId, String userId);
  Future<void> removeUser(String hikeId, String userId);
  Future<void> startHike(String hikeId);
  Future<void> endHike(String hikeId);
  Future<List<String>> getHikeMembers(String hikeId);
  Future<List<String>> getInvitedUsers(String hikeId);
  Future<bool> isTeamLeader(String hikeId, String userId);
  Future<List<HikeModel>> getInvitedHikes(String userId);
} 