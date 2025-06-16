import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:roveeee/domain/repositories/user_repository.dart';
import 'package:roveeee/domain/models/user.dart';

class UserRepositoryImpl implements UserRepository {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<User?> login(String username, String password) async {
    try {
      // First get the user document to verify credentials
      final userDoc = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (userDoc.docs.isEmpty) {
        return null;
      }

      final userData = userDoc.docs.first.data();
      final storedPassword = userData['password'] as String;
      final hashedPassword = _hashPassword(password);

      if (storedPassword != hashedPassword) {
        return null;
      }

      // Sign in with Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: userData['email'] as String,
        password: password,
      );

      return User(
        id: userCredential.user!.uid,
        username: username,
        email: userData['email'] as String,
        name: userData['name'] as String,
        password: hashedPassword,
        createdAt: (userData['createdAt'] as Timestamp).toDate(),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<User> signup(User user) async {
    try {
      // Check if username is available
      final isAvailable = await isUsernameAvailable(user.username);
      if (!isAvailable) {
        throw Exception('Username is already taken');
      }

      // Create user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: user.email,
        password: user.password,
      );

      // Hash password before storing
      final hashedPassword = _hashPassword(user.password);

      // Store user data in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'username': user.username,
        'email': user.email,
        'name': user.name,
        'password': hashedPassword,
        'createdAt': Timestamp.fromDate(user.createdAt),
      });

      return User(
        id: userCredential.user!.uid,
        username: user.username,
        email: user.email,
        name: user.name,
        password: hashedPassword,
        createdAt: user.createdAt,
      );
    } catch (e) {
      throw Exception('Signup failed: $e');
    }
  }

  @override
  Future<bool> isUsernameAvailable(String username) async {
    final result = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    return result.docs.isEmpty;
  }

  @override
  Future<User?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) {
        return null;
      }

      final data = doc.data()!;
      return User(
        id: userId,
        username: data['username'] as String,
        email: data['email'] as String,
        name: data['name'] as String,
        password: data['password'] as String,
        createdAt: (data['createdAt'] as Timestamp).toDate(),
      );
    } catch (e) {
      return null;
    }
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  firebase_auth.User? get currentUser => _auth.currentUser;
} 