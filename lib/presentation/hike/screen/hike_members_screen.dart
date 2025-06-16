import 'package:flutter/material.dart';
import 'package:roveeee/data/models/hike_model.dart';
import 'package:roveeee/domain/repositories/hike_repository.dart';
import 'package:roveeee/domain/repositories/user_profile_repository.dart';
import 'package:roveeee/domain/models/user_profile.dart';

class HikeMembersScreen extends StatefulWidget {
  final HikeModel hike;
  final HikeRepository hikeRepository;
  final UserProfileRepository userProfileRepository;
  final String currentUserId;

  const HikeMembersScreen({
    super.key,
    required this.hike,
    required this.hikeRepository,
    required this.userProfileRepository,
    required this.currentUserId,
  });

  @override
  State<HikeMembersScreen> createState() => _HikeMembersScreenState();
}

class _HikeMembersScreenState extends State<HikeMembersScreen> {
  bool _isLoading = false;
  List<UserProfile> _members = [];
  List<UserProfile> _invitedUsers = [];
  final TextEditingController _searchController = TextEditingController();
  List<UserProfile> _searchResults = [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMembers() async {
    setState(() => _isLoading = true);
    try {
      final members = <UserProfile>[];
      for (final id in widget.hike.members) {
        try {
          final profile = await widget.userProfileRepository.getUserProfile(id);
          members.add(profile);
        } catch (_) {}
      }
      final invited = <UserProfile>[];
      for (final id in widget.hike.invitedUsers) {
        try {
          final profile = await widget.userProfileRepository.getUserProfile(id);
          invited.add(profile);
        } catch (_) {}
      }
      setState(() {
        _members = members;
        _invitedUsers = invited;
      });
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

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _showSuggestions = false;
      });
      return;
    }

    try {
      final results = await widget.userProfileRepository.searchUsers(query);
      setState(() {
        _searchResults = results;
        _showSuggestions = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _inviteUser(String userId) async {
    setState(() => _isLoading = true);
    try {
      await widget.hikeRepository.inviteUser(widget.hike.id, userId);
      await _loadMembers();
      setState(() {
        _searchController.clear();
        _searchResults = [];
        _showSuggestions = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User invited successfully')),
        );
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

  Future<void> _removeUser(String userId) async {
    setState(() => _isLoading = true);
    try {
      await widget.hikeRepository.removeUser(widget.hike.id, userId);
      await _loadMembers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User removed successfully')),
        );
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
    final isTeamLeader = widget.hike.teamLeader == widget.currentUserId;

    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      appBar: AppBar(
        title: const Text('Hike Members',
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
          : Column(
              children: [
                if (isTeamLeader)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search users to invite...',
                            hintStyle: const TextStyle(color: Colors.white70),
                            prefixIcon: const Icon(Icons.search, color: Color(0xFF00FFB4)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF00FFB4)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF00FFB4)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF00FFB4)),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          onChanged: _searchUsers,
                        ),
                        if (_showSuggestions && _searchResults.isNotEmpty)
                          Container(
                            constraints: const BoxConstraints(maxHeight: 200),
                            margin: const EdgeInsets.only(top: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF232A34),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF00FFB4)),
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: _searchResults.length,
                              itemBuilder: (context, index) {
                                final user = _searchResults[index];
                                final isMember = _members.any((m) => m.uid == user.uid);
                                final isInvited = _invitedUsers.any((i) => i.uid == user.uid);
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: user.avatarUrl != null
                                        ? NetworkImage(user.avatarUrl!)
                                        : null,
                                    child: user.avatarUrl == null
                                        ? const Icon(Icons.person)
                                        : null,
                                  ),
                                  title: Text(
                                    user.username,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  subtitle: isMember
                                      ? const Text('Already a member', style: TextStyle(color: Colors.greenAccent))
                                      : isInvited
                                          ? const Text('Already invited', style: TextStyle(color: Colors.orangeAccent))
                                          : null,
                                  trailing: (!isMember && !isInvited)
                                      ? TextButton(
                                          onPressed: () => _inviteUser(user.uid),
                                          style: TextButton.styleFrom(
                                            backgroundColor: const Color(0xFF00FFB4),
                                          ),
                                          child: const Text(
                                            'Invite',
                                            style: TextStyle(color: Colors.black),
                                          ),
                                        )
                                      : null,
                                  onTap: (!isMember && !isInvited)
                                      ? () => _inviteUser(user.uid)
                                      : null,
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                if (!_showSuggestions || _searchResults.isEmpty)
                  Expanded(
                    child: DefaultTabController(
                      length: 2,
                      child: Column(
                        children: [
                          TabBar(
                            tabs: const [
                              Tab(text: 'Members'),
                              Tab(text: 'Invited'),
                            ],
                            labelColor: const Color(0xFF00FFB4),
                            unselectedLabelColor: Colors.white70,
                            indicatorColor: const Color(0xFF00FFB4),
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                _buildMembersList(_members, isTeamLeader),
                                _buildMembersList(_invitedUsers, isTeamLeader),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildMembersList(List<UserProfile> users, bool isTeamLeader) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final isCurrentUser = user.uid == widget.currentUserId;
        final isLeader = user.uid == widget.hike.teamLeader;

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: user.avatarUrl != null
                ? NetworkImage(user.avatarUrl!)
                : null,
            child: user.avatarUrl == null
                ? const Icon(Icons.person)
                : null,
          ),
          title: Text(
            user.username,
            style: const TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            isLeader ? 'Team Leader' : 'Member',
            style: const TextStyle(color: Colors.white70),
          ),
          trailing: isTeamLeader && !isCurrentUser && !isLeader
              ? IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: () => _removeUser(user.uid),
                )
              : null,
        );
      },
    );
  }
} 