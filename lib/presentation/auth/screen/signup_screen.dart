import 'package:flutter/material.dart';
import 'package:roveeee/domain/repositories/user_repository.dart';
import 'package:roveeee/domain/repositories/hike_repository.dart';
import 'package:roveeee/domain/models/user.dart';
import 'package:provider/provider.dart';
import 'package:roveeee/domain/models/user_profile.dart';
import 'package:roveeee/data/repositories/firebase_user_profile_repository.dart';

class SignupScreen extends StatefulWidget {
  final UserRepository userRepository;
  
  const SignupScreen({
    super.key,
    required this.userRepository,
  });

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  bool _isUsernameAvailable = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _checkUsernameAvailability() async {
    if (_usernameController.text.isEmpty) return;
    
    final isAvailable = await widget.userRepository.isUsernameAvailable(_usernameController.text);
    setState(() => _isUsernameAvailable = isAvailable);
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isUsernameAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username is already taken')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = User(
        id: '',
        username: _usernameController.text,
        email: _emailController.text,
        name: _nameController.text,
        password: _passwordController.text,
        createdAt: DateTime.now(),
      );

      final createdUser = await widget.userRepository.signup(user);
      
      if (mounted) {
        final hikeRepository = Provider.of<HikeRepository>(context, listen: false);
        final userProfileRepository = FirebaseUserProfileRepository();
        await userProfileRepository.createUserProfile(UserProfile(
          uid: createdUser.id,
          username: createdUser.username,
          avatarUrl: null,
          bio: '',
          completedHikes: [],
          createdHikes: [],
          createdAt: createdUser.createdAt,
          lastUpdated: DateTime.now(),
        ));
        Navigator.pushReplacementNamed(
          context,
          '/home',
          arguments: {
            'username': createdUser.username,
            'userRepository': widget.userRepository,
            'hikeRepository': hikeRepository,
          },
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
    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'roveX',
                style: TextStyle(
                  color: Color(0xFF00FFB4),
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 48),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        prefixIcon: const Icon(Icons.person, color: Color(0xFF00FFB4)),
                        filled: true,
                        fillColor: const Color(0xFF232A34),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        labelStyle: const TextStyle(color: Colors.white70),
                        suffixIcon: _usernameController.text.isNotEmpty
                            ? Icon(
                                _isUsernameAvailable ? Icons.check_circle : Icons.cancel,
                                color: _isUsernameAvailable ? const Color(0xFF00FFB4) : Colors.red,
                              )
                            : null,
                      ),
                      style: const TextStyle(color: Colors.white),
                      onChanged: (_) => _checkUsernameAvailability(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a username';
                        }
                        if (!_isUsernameAvailable) {
                          return 'Username is already taken';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF00FFB4)),
                        filled: true,
                        fillColor: const Color(0xFF232A34),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        labelStyle: const TextStyle(color: Colors.white70),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email, color: Color(0xFF00FFB4)),
                        filled: true,
                        fillColor: const Color(0xFF232A34),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        labelStyle: const TextStyle(color: Colors.white70),
                      ),
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock, color: Color(0xFF00FFB4)),
                        filled: true,
                        fillColor: const Color(0xFF232A34),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        labelStyle: const TextStyle(color: Colors.white70),
                      ),
                      style: const TextStyle(color: Colors.white),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _signup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00FFB4),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 6,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                child: Text(_isLoading ? 'Creating account...' : 'Sign Up'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Already have an account? Login',
                  style: TextStyle(color: Color(0xFF00FFB4)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 