import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:roveeee/domain/models/user.dart';

abstract class UserRepository {
  Future<User?> login(String username, String password);
  Future<User> signup(User user);
  Future<bool> isUsernameAvailable(String username);
  Future<User?> getUserById(String userId);
  Future<void> signOut();
  firebase_auth.User? get currentUser;
} 