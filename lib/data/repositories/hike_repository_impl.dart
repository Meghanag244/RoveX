import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:roveeee/domain/models/hike.dart';
import 'package:roveeee/domain/models/beacon.dart';
import '../../data/models/hike_model.dart';
import 'package:roveeee/domain/repositories/hike_repository.dart';
import 'dart:math' as math;

class HikeRepositoryImpl implements HikeRepository {
  final FirebaseFirestore _firestore;

  HikeRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<HikeModel>> getHikes() async {
    final snapshot = await _firestore.collection('hikes').get();
    return snapshot.docs.map((doc) => HikeModel.fromFirestore(doc)).toList();
  }

  @override
  Future<HikeModel> createHike(HikeModel hike) async {
    final docRef = await _firestore.collection('hikes').add(hike.toFirestore());
    final doc = await docRef.get();
    return HikeModel.fromFirestore(doc);
  }

  @override
  Future<void> joinHike(String hikeId, String userId) async {
    await _firestore.collection('hikes').doc(hikeId).update({
      'members': FieldValue.arrayUnion([userId])
    });
  }

  @override
  Future<void> leaveHike(String hikeId, String userId) async {
    await _firestore.collection('hikes').doc(hikeId).update({
      'members': FieldValue.arrayRemove([userId])
    });
  }

  @override
  Future<List<HikeModel>> getUserHikes(String userId) async {
    final snapshot = await _firestore
        .collection('hikes')
        .where('members', arrayContains: userId)
        .get();
    return snapshot.docs.map((doc) => HikeModel.fromFirestore(doc)).toList();
  }

  @override
  Future<List<HikeModel>> getPublicHikes() async {
    final snapshot = await _firestore
        .collection('hikes')
        .where('isPublic', isEqualTo: true)
        .get();
    return snapshot.docs.map((doc) => HikeModel.fromFirestore(doc)).toList();
  }

  @override
  Future<void> updateHike(HikeModel hike) async {
    await _firestore.collection('hikes').doc(hike.id).update(hike.toFirestore());
  }

  @override
  Future<void> deleteHike(String hikeId) async {
    await _firestore.collection('hikes').doc(hikeId).delete();
  }

  @override
  Future<void> addBeacon(String hikeId, Beacon beacon) async {
    await _firestore.collection('hikes').doc(hikeId).update({
      'beacons': FieldValue.arrayUnion([beacon.toMap()]),
    });
  }

  @override
  Future<void> removeBeacon(String hikeId, String beaconId) async {
    final hikeDoc = await _firestore.collection('hikes').doc(hikeId).get();
    final hike = HikeModel.fromFirestore(hikeDoc);
    final updatedBeacons = hike.beacons.where((b) => b.id != beaconId).map((b) => b.toMap()).toList();
    await _firestore.collection('hikes').doc(hikeId).update({
      'beacons': updatedBeacons,
    });
  }

  @override
  Future<void> markBeaconAsFound(String hikeId, String beaconId, String userId) async {
    final hikeDoc = await _firestore.collection('hikes').doc(hikeId).get();
    final hike = HikeModel.fromFirestore(hikeDoc);
    final updatedBeacons = hike.beacons.map((b) {
      if (b.id == beaconId && !b.foundBy.contains(userId)) {
        return Beacon(
          id: b.id,
          name: b.name,
          description: b.description,
          latitude: b.latitude,
          longitude: b.longitude,
          createdBy: b.createdBy,
          createdAt: b.createdAt,
          foundBy: [...b.foundBy, userId],
        );
      }
      return b;
    }).map((b) => b.toMap()).toList();
    await _firestore.collection('hikes').doc(hikeId).update({
      'beacons': updatedBeacons,
    });
  }

  @override
  Future<List<Beacon>> getNearbyBeacons(String hikeId, double latitude, double longitude, double radiusInKm) async {
    final hikeDoc = await _firestore.collection('hikes').doc(hikeId).get();
    final hike = HikeModel.fromFirestore(hikeDoc);
    
    return hike.beacons.where((beacon) {
      final distance = _calculateDistance(
        latitude,
        longitude,
        beacon.latitude,
        beacon.longitude,
      );
      return distance <= radiusInKm;
    }).toList();
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Radius of the earth in km
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_deg2rad(lat1)) * math.cos(_deg2rad(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c; // Distance in km
  }

  double _deg2rad(double deg) {
    return deg * (math.pi / 180);
  }

  @override
  Future<void> inviteUser(String hikeId, String userId) async {
    await _firestore.collection('hikes').doc(hikeId).update({
      'invitedUsers': FieldValue.arrayUnion([userId]),
    });
  }

  @override
  Future<void> removeUser(String hikeId, String userId) async {
    final hikeDoc = await _firestore.collection('hikes').doc(hikeId).get();
    final hike = HikeModel.fromFirestore(hikeDoc);
    
    if (!hike.canRemoveUser(hike.teamLeader, userId)) {
      throw Exception('Only team leader can remove users');
    }

    await _firestore.collection('hikes').doc(hikeId).update({
      'members': FieldValue.arrayRemove([userId]),
      'invitedUsers': FieldValue.arrayRemove([userId]),
    });
  }

  @override
  Future<void> startHike(String hikeId) async {
    final hikeDoc = await _firestore.collection('hikes').doc(hikeId).get();
    final hike = HikeModel.fromFirestore(hikeDoc);
    
    if (!await isTeamLeader(hikeId, hike.teamLeader)) {
      throw Exception('Only team leader can start the hike');
    }

    await _firestore.collection('hikes').doc(hikeId).update({
      'isActive': true,
    });
  }

  @override
  Future<void> endHike(String hikeId) async {
    final hikeDoc = await _firestore.collection('hikes').doc(hikeId).get();
    final hike = HikeModel.fromFirestore(hikeDoc);
    
    if (!await isTeamLeader(hikeId, hike.teamLeader)) {
      throw Exception('Only team leader can end the hike');
    }

    await _firestore.collection('hikes').doc(hikeId).update({
      'isActive': false,
    });
  }

  @override
  Future<List<String>> getHikeMembers(String hikeId) async {
    final hikeDoc = await _firestore.collection('hikes').doc(hikeId).get();
    final hike = HikeModel.fromFirestore(hikeDoc);
    return hike.members;
  }

  @override
  Future<List<String>> getInvitedUsers(String hikeId) async {
    final hikeDoc = await _firestore.collection('hikes').doc(hikeId).get();
    final hike = HikeModel.fromFirestore(hikeDoc);
    return hike.invitedUsers;
  }

  @override
  Future<bool> isTeamLeader(String hikeId, String userId) async {
    final hikeDoc = await _firestore.collection('hikes').doc(hikeId).get();
    final hike = HikeModel.fromFirestore(hikeDoc);
    return hike.teamLeader == userId;
  }

  @override
  Future<List<HikeModel>> getInvitedHikes(String userId) async {
    final snapshot = await _firestore
        .collection('hikes')
        .where('invitedUsers', arrayContains: userId)
        .get();
    return snapshot.docs.map((doc) => HikeModel.fromFirestore(doc)).toList();
  }
} 