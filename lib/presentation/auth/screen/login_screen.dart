import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:roveeee/domain/repositories/user_repository.dart';
import 'package:roveeee/domain/repositories/hike_repository.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  final UserRepository userRepository;
  
  const LoginScreen({
    super.key,
    required this.userRepository,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userCredential = await widget.userRepository.login(
        _usernameController.text,
        _passwordController.text,
      );

      if (userCredential == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid username or password')),
          );
        }
        return;
      }

      if (mounted) {
        final hikeRepository = Provider.of<HikeRepository>(context, listen: false);
        Navigator.pushReplacementNamed(
          context,
          '/home',
          arguments: {
            'username': userCredential.username,
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
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username';
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
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00FFB4),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 6,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                child: Text(_isLoading ? 'Logging in...' : 'Login'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/signup',
                    arguments: {'userRepository': widget.userRepository},
                  );
                },
                child: const Text(
                  'Don\'t have an account? Sign up',
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