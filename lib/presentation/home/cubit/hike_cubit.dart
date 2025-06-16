import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/hike_model.dart';
import '../../../domain/repositories/hike_repository.dart';

class HikeCubit extends Cubit<List<HikeModel>> {
  final HikeRepository _repository;
  
  HikeCubit(this._repository) : super([]);

  Future<void> loadHikes() async {
    try {
      final hikes = await _repository.getHikes();
      emit(hikes);
    } catch (e) {
      emit([]);
    }
  }

  void addHike(HikeModel hike) {
    emit([...state, hike]);
  }

  Future<void> createHike({
    required String name,
    required String description,
    required String teamLeader,
    required bool isPublic,
    required LatLng startPoint,
    required LatLng endPoint,
    required DateTime scheduledDateTime,
  }) async {
    try {
      final hike = HikeModel(
        id: const Uuid().v4(),
        name: name,
        description: description,
        teamLeader: teamLeader,
        isPublic: isPublic,
        startPoint: startPoint,
        endPoint: endPoint,
        scheduledDateTime: scheduledDateTime,
        members: [teamLeader],
        invitedUsers: [],
        createdAt: DateTime.now(),
        beacons: [],
      );
      
      await _repository.createHike(hike);
      emit([...state, hike]);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> joinHike(String hikeId, String userId) async {
    try {
      await _repository.joinHike(hikeId, userId);
      final updatedHikes = state.map((hike) {
        if (hike.id == hikeId) {
          return HikeModel(
            id: hike.id,
            name: hike.name,
            description: hike.description,
            teamLeader: hike.teamLeader,
            isPublic: hike.isPublic,
            startPoint: hike.startPoint,
            endPoint: hike.endPoint,
            scheduledDateTime: hike.scheduledDateTime,
            members: [...hike.members, userId],
            invitedUsers: hike.invitedUsers,
            createdAt: hike.createdAt,
            beacons: hike.beacons,
          );
        }
        return hike;
      }).toList();
      emit(updatedHikes);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> leaveHike(String hikeId, String userId) async {
    try {
      await _repository.leaveHike(hikeId, userId);
      final updatedHikes = state.map((hike) {
        if (hike.id == hikeId) {
          return HikeModel(
            id: hike.id,
            name: hike.name,
            description: hike.description,
            teamLeader: hike.teamLeader,
            isPublic: hike.isPublic,
            startPoint: hike.startPoint,
            endPoint: hike.endPoint,
            scheduledDateTime: hike.scheduledDateTime,
            members: hike.members.where((member) => member != userId).toList(),
            invitedUsers: hike.invitedUsers,
            createdAt: hike.createdAt,
            beacons: hike.beacons,
          );
        }
        return hike;
      }).toList();
      emit(updatedHikes);
    } catch (e) {
      // Handle error
    }
  }
} 