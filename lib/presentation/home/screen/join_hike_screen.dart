import 'package:flutter/material.dart';
import 'package:roveeee/data/models/hike_model.dart';
import 'package:roveeee/domain/repositories/hike_repository.dart';
import 'package:roveeee/data/repositories/firebase_user_profile_repository.dart';
import 'package:roveeee/domain/repositories/user_profile_repository.dart';

class JoinHikeScreen extends StatefulWidget {
  final HikeRepository hikeRepository;
  final String userId;

  const JoinHikeScreen({
    super.key,
    required this.hikeRepository,
    required this.userId,
  });

  @override
  State<JoinHikeScreen> createState() => _JoinHikeScreenState();
}

class _JoinHikeScreenState extends State<JoinHikeScreen> {
  bool _isLoading = false;
  List<HikeModel> _hikes = [];
  final UserProfileRepository _userProfileRepository = FirebaseUserProfileRepository();
  final Map<String, String> _leaderUsernames = {};

  @override
  void initState() {
    super.initState();
    _loadHikes();
  }

  Future<void> _loadHikes() async {
    setState(() => _isLoading = true);
    try {
      final hikes = await widget.hikeRepository.getPublicHikes();
      setState(() => _hikes = hikes);
      await _fetchLeaderUsernames(hikes);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchLeaderUsernames(List<HikeModel> hikes) async {
    for (final hike in hikes) {
      if (!_leaderUsernames.containsKey(hike.teamLeader)) {
        try {
          final profile = await _userProfileRepository.getUserProfile(hike.teamLeader);
          setState(() {
            _leaderUsernames[hike.teamLeader] = profile.username;
          });
        } catch (_) {
          setState(() {
            _leaderUsernames[hike.teamLeader] = 'Unknown';
          });
        }
      }
    }
  }

  Future<void> _joinHike(HikeModel hike) async {
    setState(() => _isLoading = true);
    try {
      await widget.hikeRepository.joinHike(hike.id, widget.userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully joined the hike')),
        );
        _loadHikes();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      appBar: AppBar(
        title: const Text('Join a Hike',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF00FFB4),
            fontSize: 24
          )
        ),
        backgroundColor: const Color(0xFF232A34),
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hikes.isEmpty
              ? const Center(
                  child: Text(
                    'No public hikes available',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : ListView.builder(
                  itemCount: _hikes.length,
                  itemBuilder: (context, index) {
                    final hike = _hikes[index];
                    final bool isJoined = hike.members.contains(widget.userId);
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      color: const Color(0xFF232A34),
                      child: ListTile(
                        title: Text(
                          hike.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Leader: ${_leaderUsernames[hike.teamLeader] ?? "Loading..."}\n'
                          'Scheduled: ${hike.scheduledDateTime.toString().split('.')[0]}\n'
                          'Members: ${hike.members.length}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: isJoined
                            ? const Icon(
                                Icons.check_circle,
                                color: Color(0xFF00FFB4),
                              )
                            : TextButton(
                                onPressed: () => _joinHike(hike),
                                style: TextButton.styleFrom(
                                  backgroundColor: const Color(0xFF00FFB4),
                                ),
                                child: const Text(
                                  'Join',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                      ),
                    );
                  },
                ),
    );
  }
} 