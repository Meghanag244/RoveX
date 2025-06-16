import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:roveeee/data/models/hike_model.dart';
import 'package:roveeee/domain/repositories/user_profile_repository.dart';
import 'package:roveeee/domain/models/user_profile.dart';

class HikeDetailsScreen extends StatefulWidget {
  final HikeModel hike;
  final String currentUserId;
  final UserProfileRepository userProfileRepository;

  const HikeDetailsScreen({
    super.key,
    required this.hike,
    required this.currentUserId,
    required this.userProfileRepository,
  });

  @override
  State<HikeDetailsScreen> createState() => _HikeDetailsScreenState();
}

class _HikeDetailsScreenState extends State<HikeDetailsScreen> {
  final TextEditingController _messageController = TextEditingController();
  late final CollectionReference _messagesRef;
  UserProfile? _currentUserProfile;
  String? _leaderUsername;

  @override
  void initState() {
    super.initState();
    _messagesRef = FirebaseFirestore.instance
        .collection('hikes')
        .doc(widget.hike.id)
        .collection('messages');
    _loadCurrentUserProfile();
    _loadLeaderUsername();
  }

  Future<void> _loadCurrentUserProfile() async {
    try {
      final profile = await widget.userProfileRepository.getUserProfile(widget.currentUserId);
      setState(() => _currentUserProfile = profile);
    } catch (e) {
      if (e.toString().contains('User profile not found')) {
        // Create a default profile if one doesn't exist
        try {
          final now = DateTime.now();
          final defaultProfile = UserProfile(
            uid: widget.currentUserId,
            username: 'User ${widget.currentUserId.substring(0, 6)}',
            avatarUrl: null,
            bio: null,
            completedHikes: [],
            createdHikes: [],
            createdAt: now,
            lastUpdated: now,
          );
          await widget.userProfileRepository.createUserProfile(defaultProfile);
          setState(() => _currentUserProfile = defaultProfile);
        } catch (createError) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error creating profile: $createError')),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading profile: $e')),
          );
        }
      }
    }
  }

  Future<void> _loadLeaderUsername() async {
    try {
      final profile = await widget.userProfileRepository.getUserProfile(widget.hike.teamLeader);
      setState(() => _leaderUsername = profile.username);
    } catch (e) {
      setState(() => _leaderUsername = 'Unknown');
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message cannot be empty')),
      );
      return;
    }
    
    if (_currentUserProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please wait while your profile loads')),
      );
      return;
    }

    try {
      await _messagesRef.add({
        'text': text,
        'senderId': widget.currentUserId,
        'senderName': _currentUserProfile!.username,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _messageController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending message: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      appBar: AppBar(
        title: Text(widget.hike.name, style: const TextStyle(color: Color(0xFF00FFB4))),
        backgroundColor: const Color(0xFF232A34),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.hike.description, style: const TextStyle(color: Colors.white, fontSize: 16)),
                const SizedBox(height: 8),
                Text('Date: ${widget.hike.scheduledDateTime}', style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 8),
                Text('Leader: ${_leaderUsername ?? "Loading..."}', style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 8),
                Text('Members: ${widget.hike.members.length}', style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          const Divider(color: Color(0xFF00FFB4)),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Group Chat', style: TextStyle(color: Color(0xFF00FFB4), fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _messagesRef.orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading messages: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(child: Text('No messages yet.', style: TextStyle(color: Colors.white70)));
                }
                return ListView.builder(
                  reverse: true,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final msg = docs[index].data() as Map<String, dynamic>;
                    final isMe = msg['senderId'] == widget.currentUserId;
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe ? const Color(0xFF00FFB4) : const Color(0xFF232A34),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg['senderName'] ?? '',
                              style: TextStyle(
                                color: isMe ? Colors.black : Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              msg['text'] ?? '',
                              style: TextStyle(
                                color: isMe ? Colors.black : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: const Color(0xFF232A34),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF00FFB4)),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 