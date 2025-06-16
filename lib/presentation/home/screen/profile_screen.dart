import 'package:flutter/material.dart';
import 'package:roveeee/domain/models/user.dart';
import 'package:roveeee/domain/repositories/user_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roveeee/data/repositories/firebase_user_profile_repository.dart';
import 'package:roveeee/domain/models/user_profile.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class ProfileScreen extends StatefulWidget {
  final User user;
  final UserRepository userRepository;

  const ProfileScreen({
    Key? key,
    required this.user,
    required this.userRepository,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _profile;
  bool _isLoading = false;
  final _storage = FirebaseStorage.instance;
  String? _avatarEmoji;

  final List<String> _presetAvatars = [
    '🦊', '🐻', '🦁', '🐼', '🦄', '🐸', '🐵', '🐶', '🐱', '🐰',
    '🐯', '🐨', '🐙', '🐧', '🐢', '🦋', '🐞', '🦉', '🦕', '🦖',
    '🌵', '🌸', '🌻', '🌈', '⭐', '⚡', '🔥', '🍀', '🍕', '🍩',
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final repo = FirebaseUserProfileRepository();
      final profile = await repo.getUserProfile(widget.user.id);
      setState(() {
        _profile = profile;
        _avatarEmoji = null; // You can load from profile if you store it
      });
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  void _showAvatarPicker() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Choose an avatar'),
        children: _presetAvatars.map((emoji) => SimpleDialogOption(
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 32))),
          onPressed: () => Navigator.pop(context, emoji),
        )).toList(),
      ),
    );
    if (selected != null) {
      setState(() {
        _avatarEmoji = selected;
      });
      // Optionally, save to Firestore as a custom field
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Color(0xFF00FFB4))),
        backgroundColor: const Color(0xFF232A34),
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: const Color(0xFF00FFB4),
                        child: _avatarEmoji != null
                            ? Text(_avatarEmoji!, style: const TextStyle(fontSize: 40))
                            : (_profile?.avatarUrl != null && _profile!.avatarUrl!.isNotEmpty
                                ? null
                                : Text(
                                    widget.user.username.isNotEmpty ? widget.user.username[0].toUpperCase() : '?',
                                    style: const TextStyle(fontSize: 40, color: Colors.black),
                                  )),
                        backgroundImage: (_profile?.avatarUrl != null && _profile!.avatarUrl!.isNotEmpty && _avatarEmoji == null)
                            ? NetworkImage(_profile!.avatarUrl!)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _showAvatarPicker,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF00FFB4), width: 2),
                            ),
                            padding: const EdgeInsets.all(6),
                            child: const Icon(Icons.edit, color: Color(0xFF00FFB4), size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.user.username,
                    style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'UID: ${widget.user.id}',
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await widget.userRepository.signOut();
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(
                          context,
                          '/',
                          arguments: {'userRepository': widget.userRepository},
                        );
                      }
                    },
                    icon: const Icon(Icons.logout, color: Colors.black),
                    label: const Text('Sign Out', style: TextStyle(color: Colors.black)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00FFB4),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
} 