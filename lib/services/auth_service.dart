import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:firebase_messaging/firebase_messaging.dart';  

 
 

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _auth.currentUser;
  bool get isAuthenticated => _auth.currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  AuthService() {
    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) {
      notifyListeners();
    });
  }

  Future<void> updateFCMToken() async {
  final user = _auth.currentUser;
  if (user == null) return;

  try {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    // Permission mangna
    await messaging.requestPermission();
    String? token = await messaging.getToken();

    if (token != null) {
      await _db.collection('users').doc(user.uid).set({
        'fcmToken': token,
        'lastActive': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  } catch (e) {
    debugPrint("Error updating token: $e");
  }
}

  // REGISTER: create auth user + Firestore user + send verification
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final normalizedEmail = email.trim().toLowerCase();

      final cred = await _auth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      // Create Firestore user doc
      await _db.collection('users').doc(cred.user!.uid).set({
        'name': name,
        'email': normalizedEmail,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Send verification email
      await cred.user!.sendEmailVerification();

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Registration failed.';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Registration failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // LOGIN: email & password
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      try {
        final normalizedEmail = email.trim().toLowerCase();
        final cred = await _auth.signInWithEmailAndPassword(
          email: normalizedEmail,
          password: password,
        );

        // Reload user to get latest emailVerified status from Firebase servers
        await cred.user?.reload();
        final refreshedUser = _auth.currentUser;

        if (refreshedUser != null && !refreshedUser.emailVerified) {
          _errorMessage = 'Please verify your email address before logging in.';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found' ||
            e.code == 'invalid-credential' ||
            e.code == 'INVALID_LOGIN_CREDENTIALS') {
          _errorMessage = 'Incorrect email or password. Please try again.';
        } else if (e.code == 'wrong-password') {
          _errorMessage = 'Incorrect password. Please try again.';
        } else if (e.code == 'invalid-email') {
          _errorMessage = 'Invalid email address format.';
        } else if (e.code == 'user-disabled') {
          _errorMessage = 'This user account has been disabled.';
        } else if (e.code == 'too-many-requests') {
          _errorMessage = 'Too many failed login attempts. Please try again later.';
        } else {
          _errorMessage = e.message ?? 'Authentication failed.';
        }
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await updateFCMToken();

      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Login failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    final user = _auth.currentUser;
  if (user != null) {
    // Logout se pehle token delete karo
    await _db.collection('users').doc(user.uid).update({
      'fcmToken': FieldValue.delete(),
    });
  }
  
    await _auth.signOut();
    _errorMessage = null;
    notifyListeners();
  }

  // RESET PASSWORD: Send reset link to email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final normalizedEmail = email.trim().toLowerCase();
      await _auth.sendPasswordResetEmail(email: normalizedEmail);

      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _errorMessage = 'No account found for this email address.';
      } else if (e.code == 'invalid-email') {
        _errorMessage = 'The email address format is invalid.';
      } else if (e.code == 'too-many-requests') {
        _errorMessage = 'Too many requests. Please try again later.';
      } else {
        _errorMessage = e.message ?? 'Failed to send password reset email.';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to send reset email. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
