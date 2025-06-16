import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:roveeee/domain/models/user.dart';
import 'package:roveeee/data/models/hike_model.dart';
import 'package:roveeee/domain/models/beacon.dart';
import '../cubit/hike_cubit.dart';
import 'create_hike_screen.dart';
import 'hike_history_screen.dart';
import 'join_hike_screen.dart';
import 'ongoing_hike_screen.dart';
import '../../../domain/repositories/hike_repository.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:roveeee/domain/repositories/user_repository.dart';
import 'package:intl/intl.dart';
import 'profile_screen.dart';
import 'package:roveeee/presentation/hike/screen/hike_details_screen.dart';
import 'package:roveeee/data/repositories/firebase_user_profile_repository.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  final HikeRepository hikeRepository;
  final UserRepository userRepository;

  const HomeScreen({
    super.key,
    required this.username,
    required this.hikeRepository,
    required this.userRepository,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<HikeModel> _hikes = [];
  bool _isLoading = true;
  int _selectedTab = 0; // 0 = Your Hikes, 1 = Public Hikes, 2 = Invites
  int _selectedNavIndex = 0; // 0 = Home, 1 = Map, 2 = Notifications, 3 = Profile
  DateTime? _lastLoadTime;
  static const _cacheDuration = Duration(minutes: 1);
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
    _loadHikes();
  }

  Future<void> _fetchCurrentUser() async {
    final userId = widget.userRepository.currentUser?.uid;
    if (userId != null) {
      final user = await widget.userRepository.getUserById(userId);
      setState(() {
        _currentUser = user;
      });
    }
  }

  Future<void> _loadHikes() async {
    if (_lastLoadTime != null && 
        DateTime.now().difference(_lastLoadTime!) < _cacheDuration) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final userId = widget.userRepository.currentUser?.uid;
      if (userId != null) {
        final hikes = await widget.hikeRepository.getUserHikes(userId);
        setState(() {
          _hikes = hikes;
          _isLoading = false;
          _lastLoadTime = DateTime.now();
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading hikes: $e')),
      );
    }
  }

  Future<void> _loadPublicHikes() async {
    if (_lastLoadTime != null && 
        DateTime.now().difference(_lastLoadTime!) < _cacheDuration) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final hikes = await widget.hikeRepository.getPublicHikes();
      setState(() {
        _hikes = hikes;
        _isLoading = false;
        _lastLoadTime = DateTime.now();
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading public hikes: $e')),
      );
    }
  }

  Future<void> _loadInvitedHikes() async {
    setState(() => _isLoading = true);
    try {
      final userId = widget.userRepository.currentUser?.uid;
      if (userId != null) {
        final hikes = await widget.hikeRepository.getInvitedHikes(userId);
        setState(() {
          _hikes = hikes;
          _isLoading = false;
          _lastLoadTime = DateTime.now();
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading invited hikes: $e')),
      );
    }
  }

  Future<void> _inviteUser(String hikeId) async {
    final usernameController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invite User'),
        content: TextField(
          controller: usernameController,
          decoration: const InputDecoration(
            labelText: 'Enter username',
            hintText: 'e.g., hiker123',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, usernameController.text),
            child: const Text('Invite'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: result)
            .get();

        if (userDoc.docs.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not found')),
          );
          return;
        }

        final invitedUserId = userDoc.docs.first.id;
        await widget.hikeRepository.joinHike(hikeId, invitedUserId);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User invited successfully')),
        );
        _loadHikes();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error inviting user: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget mainContent;
    if (_selectedNavIndex == 3) {
      // Profile page
      if (_currentUser == null) {
        mainContent = const Center(child: CircularProgressIndicator(color: Color(0xFF00FFB4)));
      } else {
        mainContent = ProfileScreen(user: _currentUser!, userRepository: widget.userRepository);
      }
    } else {
      // Main hikes UI
      mainContent = _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00FFB4)))
          : RefreshIndicator(
              onRefresh: _selectedTab == 0 ? _loadHikes : _selectedTab == 1 ? _loadPublicHikes : _loadInvitedHikes,
              color: const Color(0xFF00FFB4),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildActionButton(
                            'Create Hike',
                            Icons.add,
                            () async {
                              await Navigator.pushNamed(
                                context,
                                '/create-hike',
                                arguments: {
                                  'userId': widget.userRepository.currentUser?.uid ?? '',
                                },
                              );
                              _loadHikes();
                            },
                          ),
                          _buildActionButton(
                            'Join Hike',
                            Icons.group_add,
                            () {
                              Navigator.pushNamed(
                                context,
                                '/join-hike',
                                arguments: {
                                  'userId': widget.userRepository.currentUser?.uid ?? '',
                                  'hikeRepository': widget.hikeRepository,
                                },
                              ).then((_) => _loadHikes());
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildTabButton('Your Hikes', 0),
                            const SizedBox(width: 16),
                            _buildTabButton('Public Hikes', 1),
                            const SizedBox(width: 16),
                            _buildTabButton('Invites', 2),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _hikes.isEmpty
                          ? const Center(
                              child: Text(
                                'No hikes yet. Create or join one!',
                                style: TextStyle(color: Colors.white70),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _hikes.length,
                              itemBuilder: (context, index) {
                                final hike = _hikes[index];
                                return _buildHikeCard(hike);
                              },
                            ),
                    ],
                  ),
                ),
              ),
            );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      appBar: AppBar(
        title: Text(
          _selectedNavIndex == 3
              ? 'Profile'
              : 'Welcome, ${widget.username}!',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF00FFB4),
            fontSize: 24,
          ),
        ),
        backgroundColor: const Color(0xFF232A34),
        elevation: 0,
        actions: _selectedNavIndex == 3
            ? []
            : [
                IconButton(
                  icon: const Icon(Icons.logout, color: Color(0xFF00FFB4)),
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
                ),
              ],
      ),
      body: mainContent,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedNavIndex,
        onTap: (index) {
          setState(() {
            _selectedNavIndex = index;
            if (index != 3) {
              // If returning to hikes, refresh hikes
              _fetchCurrentUser();
            }
          });
        },
        backgroundColor: const Color(0xFF232A34),
        selectedItemColor: const Color(0xFF00FFB4),
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.black),
      label: Text(text, style: const TextStyle(color: Colors.black)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00FFB4),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
          _isLoading = true;
          _lastLoadTime = null; // Force reload on tab switch
        });
        if (index == 0) {
          _loadHikes();
        } else if (index == 1) {
          _loadPublicHikes();
        } else if (index == 2) {
          _loadInvitedHikes();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00FFB4) : const Color(0xFF232A34),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildHikeCard(HikeModel hike) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF232A34),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HikeDetailsScreen(
                hike: hike,
                currentUserId: widget.userRepository.currentUser?.uid ?? '',
                userProfileRepository: FirebaseUserProfileRepository(),
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      hike.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (_selectedTab == 0)
                    IconButton(
                      icon: const Icon(Icons.person_add, color: Color(0xFF00FFB4)),
                      onPressed: () => _inviteUser(hike.id),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Start: ${DateFormat('MMM dd, yyyy - hh:mm a').format(hike.scheduledDateTime)}',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    hike.isPublic ? Icons.public : Icons.lock,
                    color: const Color(0xFF00FFB4),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    hike.isPublic ? 'Public Hike' : 'Private Hike',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.people,
                    color: const Color(0xFF00FFB4),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${hike.members.length} participants',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 