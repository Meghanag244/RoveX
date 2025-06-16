import 'package:flutter/material.dart';
import 'presentation/auth/screen/login_screen.dart';
import 'presentation/auth/screen/signup_screen.dart';
import 'presentation/home/screen/home_screen.dart';
import 'presentation/home/screen/create_hike_screen.dart';
import 'presentation/home/screen/join_hike_screen.dart';
import 'presentation/home/screen/hike_history_screen.dart';
import 'presentation/home/screen/ongoing_hike_screen.dart';
import 'domain/repositories/hike_repository.dart';
import 'domain/repositories/user_repository.dart';

// App navigation routes
// Add your screen routes here
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Add your routes here
      case '/':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => LoginScreen(
            userRepository: args?['userRepository'] as UserRepository,
          ),
        );
      case '/signup':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => SignupScreen(
            userRepository: args?['userRepository'] as UserRepository,
          ),
        );
      case '/home':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => HomeScreen(
            username: args?['username'] ?? 'User',
            hikeRepository: args?['hikeRepository'] as HikeRepository,
            userRepository: args?['userRepository'] as UserRepository,
          ),
        );
      case '/create-hike':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => CreateHikeScreen(teamLeader: args?['userId'] ?? ''),
        );
      case '/join-hike':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => JoinHikeScreen(
            userId: args?['userId'] ?? '',
            hikeRepository: args?['hikeRepository'] as HikeRepository,
          ),
        );
      case '/hike-history':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => HikeHistoryScreen(
            userId: args?['userId'] ?? '',
            hikeRepository: args?['hikeRepository'] as HikeRepository,
          ),
        );
      case '/ongoing-hike':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => OngoingHikeScreen(
            hike: args?['hike'],
            hikeRepository: args?['hikeRepository'] as HikeRepository,
            userRepository: args?['userRepository'] as UserRepository,
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
} 