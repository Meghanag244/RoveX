import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/hike_model.dart';
import '../../../domain/repositories/hike_repository.dart';
import '../cubit/hike_cubit.dart';
import 'package:roveeee/data/repositories/firebase_user_profile_repository.dart';
import 'package:roveeee/domain/repositories/user_profile_repository.dart';

class HikeHistoryScreen extends StatelessWidget {
  final String userId;
  final HikeRepository hikeRepository;

  const HikeHistoryScreen({
    Key? key,
    required this.userId,
    required this.hikeRepository,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      appBar: AppBar(
        title: const Text('roveX', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00FFB4), fontSize: 28, letterSpacing: 2)),
        backgroundColor: const Color(0xFF232A34),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF232A34),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: BlocBuilder<HikeCubit, List<HikeModel>>(
            builder: (context, hikes) {
              if (hikes.isEmpty) {
                return const Center(child: Text('No hikes yet.', style: TextStyle(color: Colors.white70)));
              }
              return FutureBuilder<Map<String, String>>(
                future: _fetchLeaderUsernames(hikes),
                builder: (context, snapshot) {
                  final leaderUsernames = snapshot.data ?? {};
                  return ListView.builder(
                    itemCount: hikes.length,
                    itemBuilder: (context, i) {
                      final hike = hikes[i];
                      return Card(
                        color: const Color(0xFF232A34),
                        elevation: 6,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        child: ListTile(
                          leading: const Icon(Icons.terrain, color: Color(0xFF00FFB4), size: 28),
                          title: Text(hike.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            'Leader: ${leaderUsernames[hike.teamLeader] ?? "Loading..."}\n'
                            'Date: ${hike.scheduledDateTime}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<Map<String, String>> _fetchLeaderUsernames(List<HikeModel> hikes) async {
    final repo = FirebaseUserProfileRepository();
    final Map<String, String> usernames = {};
    for (final hike in hikes) {
      if (!usernames.containsKey(hike.teamLeader)) {
        try {
          final profile = await repo.getUserProfile(hike.teamLeader);
          usernames[hike.teamLeader] = profile.username;
        } catch (_) {
          usernames[hike.teamLeader] = 'Unknown';
        }
      }
    }
    return usernames;
  }
} 