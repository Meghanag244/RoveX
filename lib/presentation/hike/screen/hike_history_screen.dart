import 'package:flutter/material.dart';
import 'package:roveeee/data/models/hike_model.dart';
import 'package:roveeee/domain/repositories/hike_repository.dart';

class HikeHistoryScreen extends StatefulWidget {
  final HikeRepository hikeRepository;
  final String userId;

  const HikeHistoryScreen({
    super.key,
    required this.hikeRepository,
    required this.userId,
  });

  @override
  State<HikeHistoryScreen> createState() => _HikeHistoryScreenState();
}

class _HikeHistoryScreenState extends State<HikeHistoryScreen> {
  bool _isLoading = false;
  List<HikeModel> _hikes = [];

  @override
  void initState() {
    super.initState();
    _loadHikes();
  }

  Future<void> _loadHikes() async {
    setState(() => _isLoading = true);
    try {
      final hikes = await widget.hikeRepository.getUserHikes(widget.userId);
      setState(() => _hikes = hikes);
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
        title: const Text('Hike History', 
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
                    'No hikes in history',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : ListView.builder(
                  itemCount: _hikes.length,
                  itemBuilder: (context, index) {
                    final hike = _hikes[index];
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
                          'Created: ${hike.createdAt.toString().split('.')[0]}\n'
                          'Members: ${hike.members.length}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: Icon(
                          hike.isPublic ? Icons.public : Icons.lock,
                          color: const Color(0xFF00FFB4),
                        ),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/ongoing-hike',
                            arguments: {'hike': hike},
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
} 